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
    import terminado
    import tornado_xstatic
    HAS_LIBS = True
except ImportError:
    raise
    HAS_LIBS = False
    TermSocket = object  # A stub for MyTermSocket inheritance.

__virtualname__ = 'asterisk_cli'

log = logging.getLogger(__name__)

STATIC_DIR = os.path.join(os.path.dirname(terminado.__file__), "_static")

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
        # TODO: AUTH
        # auth = self.get_argument('auth')        
        try:
            return super(TermSocket, self).get(*args, **kwargs)
        except Exception:
            log.exception('TermSocker errror:')


class TerminalPageHandler(salt.ext.tornado.web.RequestHandler):
    def get(self):
        return self.render("termpage.html", static=self.static_url,
                           xstatic=self.application.settings['xstatic_url'],
                           ws_url_path="/ws")


def start(
        listen_address='127.0.0.1',
        listen_port=8001,
        ssl_crt = None,
        ssl_key = None,
        asterisk_binary='/usr/sbin/asterisk',
        asterisk_options='-vvvvvr'):
    salt.utils.process.appendproctitle('AsteriskCLI')
    log.info('Starting Asterisk CLI server at %s:%s.',
             listen_address, listen_port)
    io_loop = salt.ext.tornado.ioloop.IOLoop(make_current=False)
    io_loop.make_current()
    term_manager = UniqueTermManager(
        shell_command=[asterisk_binary, asterisk_options],
        ioloop=io_loop)
    handlers = [
        (r'/ws', MyTermSocket, {'term_manager': term_manager}),
        (r"/xstatic/(.*)", tornado_xstatic.XStaticFileHandler,
            {'allowed_modules': ['termjs']})
    ]
    # Init app.
    app = salt.ext.tornado.web.Application(
        handlers, static_path=STATIC_DIR,
        xstatic_url=tornado_xstatic.url_maker('/xstatic/'))
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
