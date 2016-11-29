# -*- coding: utf-8 -*-

__author__ = 'minamoto'
__ver__ = '0.1'
__doc__ = 'tornado web handler rewrite'

import tornado
import time
import os
import mxpsu as mx
import zlib
import base64


class MXRequestHandler(tornado.web.RequestHandler):

    url_pattern = None
    keep_name_case = False

    def computing_security_code(self, scode):
        x = set([mx.getMD5('{0}3a533ba0'.format(mx.stamp2time(time.time(),
                                                              format_type='%Y%m%d%H')))])
        if time.localtime()[4] >= 55:
            x.add(mx.getMD5('{0}3a533ba0'.format(mx.stamp2time(time.time() + 360,
                                                               format_type='%Y%m%d%H'))))
        elif time.localtime()[4] < 5:
            x.add(mx.getMD5('{0}3a533ba0'.format(mx.stamp2time(time.time() - 360,
                                                               format_type='%Y%m%d%H'))))

        return 1 if scode.lower() in x else 0


def load_handler_module(handler_module, perfix=".*$"):
    is_handler = lambda cls: isinstance(cls, type) and issubclass(cls, MXRequestHandler)
    has_pattern = lambda cls: hasattr(cls, 'url_pattern') and cls.url_pattern
    handlers = []
    for i in dir(handler_module):
        cls = getattr(handler_module, i)
        if is_handler(cls) and has_pattern(cls):
            handlers.append((cls.url_pattern, cls, handler_module.__name__))
    # self.handlers.extend(handlers)
    # self.add_handlers(perfix, handlers)
    return handlers


def route():

    def handler_wapper(cls):
        assert (issubclass(cls, MXRequestHandler))
        if cls.__name__ == 'MainHandler':
            cls.url_pattern = r'/'
        else:
            if cls.keep_name_case:
                cls.url_pattern = r'/' + cls.__name__[:-7]
            else:
                cls.url_pattern = r'/' + cls.__name__[:-7].lower()
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
