'''
This is Asterisk PBX CLI engine.
'''
from __future__ import absolute_import, print_function, unicode_literals
import logging
import os
from urllib.parse import urljoin
import requests
from salt.ext.tornado.web import HTTPError
import salt.ext.tornado.web
import salt.utils.process
try:
    from terminado import TermSocket, UniqueTermManager
    HAS_LIBS = True
except ImportError:
    HAS_LIBS = False
    TermSocket = object  # A stub for MyTermSocket inheritance.

__virtualname__ = 'asterisk_cli'

log = logging.getLogger(__name__)


def __virtual__():
    # Check if asterisk binary is available.
    try:
        conf = [k for k in __salt__['config.get']('engines', [])
                if type(k) is dict and k.get(
                    'asterisk_cli')][0]['asterisk_cli']
    except IndexError:
        err_msg = 'Reactor config for asterisk_cli not found! CLI not started.'
        log.error(err_msg)
        return False, err_msg
    asterisk_binary = conf.get('asterisk_binary', '/usr/sbin/asterisk')
    if not os.path.exists(asterisk_binary):
        err_msg = 'Asterisk binary {} not found!'.format(asterisk_binary)
        log.error(err_msg)
        return False, err_msg
    if not HAS_LIBS:
        err_msg = 'Terminado lib not found, Asterisk CLI module not available.'
        log.error(err_msg)
        return False, err_msg
    return True


class MyTermSocket(TermSocket):

    def check_origin(self, origin):
        return True

    def get(self, *args, **kwargs):
        server_id = self.get_argument('server')
        db = self.get_argument('db')
        if not server_id:
            raise HTTPError(404)
        # Check auth token
        auth = self.get_argument('auth')        
        url = urljoin(
            os.environ['ODOO_URL'],
            '/asterisk_base/console/{}/{}/{}'.format(db, server_id, auth))
        try:
            res = requests.get(url)
            res.raise_for_status()
            if res.text != 'ok':
                raise HTTPError(403)            
        except Exception as e:
            log.error('Odoo fetch request error: %s', e)
        try:
            return super(TermSocket, self).get(*args, **kwargs)
        except Exception:
            log.exception('TermSocker errror:')


def start(
        listen_address='127.0.0.1',
        listen_port=8001,
        ssl_crt = None,
        ssl_key = None,
        odoo_url='http://127.0.0.1:8069',
        asterisk_binary='/usr/sbin/asterisk',
        asterisk_options='-vvvvvr'):
    salt.utils.process.appendproctitle('AsteriskCLI')
    log.info('Starting Asterisk CLI server at %s:%s.',
             listen_address, listen_port)
    log.info('CLI Server: Odoo configured on %s.', odoo_url)
    io_loop = salt.ext.tornado.ioloop.IOLoop(make_current=False)
    io_loop.make_current()
    # Set ODOO_URL envvar for MyTermSocket:get().
    os.environ['ODOO_URL'] = odoo_url
    term_manager = UniqueTermManager(
        shell_command=[asterisk_binary, asterisk_options],
        ioloop=io_loop)
    handlers = [
        (r'/', MyTermSocket, {'term_manager': term_manager})]
    # Init app.
    app = salt.ext.tornado.web.Application(handlers)
    ssl_options = None
    if all([ssl_crt, ssl_key]):
        ssl_options = {"certfile": ssl_crt, "keyfile": ssl_key}
    http_server = salt.ext.tornado.httpserver.HTTPServer(
        app, ssl_options=ssl_options)
    http_server.listen(listen_port, address=listen_address)
    try:
        if not io_loop._running:
            io_loop.start()
    finally:
        term_manager.shutdown()


if __name__ == '__main__':
    logging.basicConfig(
        level=logging.DEBUG if os.getenv('DEBUG') else logging.INFO,
        format='%(asctime)s - %(name)s:%(lineno)s - %(levelname)s - %(message)s')
    start(listen_address='0.0.0.0')
