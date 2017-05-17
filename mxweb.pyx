# -*- coding: utf-8 -*-

__author__ = 'minamoto'
__ver__ = '0.1'
__doc__ = 'tornado web handler rewrite'

import tornado
import time
import os
import json
import mxpsu as mx
import zlib
import codecs
import logging
import base64

__salt = ''
__sd = 0
p = os.path.join(mx.SCRIPT_DIR, '.sd')
if os.path.isfile(p):
    __sd = 1
p = os.path.join(mx.SCRIPT_DIR, '.salt')
if os.path.isfile(p):
    try:
        with codecs.open(p, 'r', 'utf-8') as f:
            __salt = f.readline().replace('\r', '').replace('\n', '')
            f.close()
    except:
        pass
if len(__salt) == 0:
    __salt = '3a533ba0'

del p


class MXRequestHandler(tornado.web.RequestHandler):

    url_pattern = None
    salt = None
    cache_dir = mx.SCRIPT_DIR

    keep_name_case = False
    help_doc = ''
    root_path = r'/'

    sd = 0

    # post_log_msg = []

    def initialize(self, help_doc=''):
        self.help_doc = help_doc
    #     self.salt = ''
    #     if os.path.isfile('.salt'):
    #         try:
    #             with codecs.open('.salt', 'r', 'utf-8') as f:
    #                 self.salt = f.readline().replace('\r', '').replace('\n', '')
    #                 f.close()
    #         except:
    #             pass
    #     if len(self.salt) == 0:
    #         self.salt = '3a533ba0'

    def write(self, chunk):
        if self.sd:
            chunk = ''
        super(MXRequestHandler, self).write(chunk)
        if self.request.method == 'POST':
            logging.debug(self.format_log(self.request.remote_ip, chunk, self.request.path, 'REP'))

    # def on_finish(self):
    #     if self.request.method == 'POST' and len(self.post_log_msg) > 0:
    #         logging.info(self.format_log(self.request.remote_ip,
    #                                      ','.join(self.post_log_msg),
    #                                      self.request.path,
    #                                      is_req=0))
    #     self.post_log_msg = []

    def prepare(self):
        if self.request.method == 'POST':
            x = ','.join(self.get_arguments('pb2')).replace('\r', '').replace('\n', '')
            if len(x) > 0:
                logging.debug(self.format_log(self.request.remote_ip, x, self.request.path, 'REQ'))
            else:
                logging.debug(self.format_log(self.request.remote_ip,
                                              json.dumps(self.request.arguments,
                                                         separators=(',', ':')),
                                              self.request.path,
                                              'REQ'))
            del x
        elif self.request.method == 'GET':
            jobs = self.get_arguments('do')
            for do in jobs:
                if do == 'shutdown':
                    if self.sd == 0:
                        self.sd = 1
                        try:
                            with codecs.open(os.path.join(mx.SCRIPT_DIR, '.sd'), 'w', 'utf-8') as f:
                                f.write(str(time.time()))
                                f.close()
                        except:
                            pass
                    break

    def format_log(self, remote_ip, msg, path='', method=''):
        return '{3} {1} ({0}) {2}'.format(remote_ip, path, msg, method)

    def computing_security_code(self, scode):
        x = set([mx.getMD5('{0}{1}'.format(
            mx.stamp2time(time.time(),
                          format_type='%Y%m%d%H'),
            self.salt))])
        if time.localtime()[4] >= 55:
            x.add(mx.getMD5('{0}{1}'.format(
                mx.stamp2time(time.time() + 360,
                              format_type='%Y%m%d%H'),
                self.salt)))
        elif time.localtime()[4] < 5:
            x.add(mx.getMD5('{0}{1}'.format(
                mx.stamp2time(time.time() - 360,
                              format_type='%Y%m%d%H'),
                self.salt)))

        return 1 if scode.lower() in x else 0


def load_handler_module(handler_module, perfix=".*$"):
    is_handler = lambda cls: isinstance(cls, type) and issubclass(cls, MXRequestHandler)
    has_pattern = lambda cls: hasattr(cls, 'url_pattern') and cls.url_pattern
    handlers = []
    for i in dir(handler_module):
        cls = getattr(handler_module, i)
        if is_handler(cls) and has_pattern(cls):
            handlers.append((cls.url_pattern, cls, handler_module.__name__, cls.help_doc))
    # self.handlers.extend(handlers)
    # self.add_handlers(perfix, handlers)
    return handlers


def route():

    def handler_wapper(cls):
        assert (issubclass(cls, MXRequestHandler))
        if cls.salt is None:
            cls.salt = __salt
            cls.sd = __sd
        if cls.url_pattern is None or not cls.url_pattern.startswith(r'/'):
            if cls.__name__ == 'MainHandler':
                cls.url_pattern = cls.root_path
            else:
                if cls.keep_name_case:
                    cls.url_pattern = cls.root_path + cls.__name__[:-7]
                else:
                    cls.url_pattern = cls.root_path + cls.__name__[:-7].lower()
        return cls

    return handler_wapper


def load_lic_for_nt(lic_file='lic.dll'):
    lst_func = []
    if os.name == 'posix':
        lst_func = [r'/all']
    elif os.name == 'nt':
        if os.path.isfile(os.path.join(mx.SCRIPT_DIR, lic_file)):
            with open(os.path.join(mx.SCRIPT_DIR, lic_file), 'r') as f:
                x = f.readlines()
                f.close()
            y = x[1:len(x) - 1]
            z = ''.join(y).replace('\n', '').swapcase()
            a = zlib.decompress(base64.b64decode(z))
            l = int(a[8])
            ll = int(a[22:22 + int(l)])
            b = a[ll + l + 1:].split(',')

            import wmi
            c = wmi.WMI()
            d = c.Win32_Processor()[0]
            e = mx.getMD5(d)

            if b[0] == e:
                lst_func = [r'/{0}'.format(h) for h in b[1:]]
            else:
                lst_func = []
            del x, y, z, a, b, c, d, e, l, ll
        else:
            lst_func = []
    return set(lst_func)
