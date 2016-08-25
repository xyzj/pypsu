# -*- coding: utf-8 -*-

__version__ = "0.9"
__author__ = 'minamoto'
__doc__ = 'Perhaps something useful'

try:
    import threading as _threading
except ImportError:
    import dummy_threading as _threading
import base64 as _base64
import zlib as _zlib
import time as _time
import datetime as _datetime
import random as _random
import math as _math
import socket as _socket
import struct as _struct
import os as _os
import hashlib
# import uuid as _uuid
# import logging
# import logging.handlers
# import Image as _Image
# import platform as _platform
import sys as _sys
reload(_sys)
_sys.setdefaultencoding(_sys.getfilesystemencoding())

_PLATFORM = _sys.platform

OURHISTORY = [
    0x2, 0x18, 0x18, 0x18, 0x18, 0x2a, 0x28, 0x28, 0x2f, 0x25, 0x29, 0x2a, 0x25, 0x28, 0x2f, 0x18,
    0x18, 0x4f, 0x5d, 0x18, 0x65, 0x5d, 0x6c, 0x18, 0x26, 0x26, 0x26, 0x2, 0x18, 0x18, 0x18, 0x18,
    0x2a, 0x28, 0x28, 0x31, 0x25, 0x28, 0x29, 0x25, 0x2a, 0x30, 0x18, 0x18, 0x4f, 0x5d, 0x18, 0x5b,
    0x67, 0x66, 0x5c, 0x6d, 0x5b, 0x6c, 0x5d, 0x5c, 0x18, 0x6c, 0x60, 0x5d, 0x18, 0x5e, 0x61, 0x6a,
    0x6b, 0x6c, 0x18, 0x6c, 0x6a, 0x61, 0x68, 0x18, 0x26, 0x26, 0x26, 0x2, 0x18, 0x18, 0x18, 0x18,
    0x2a, 0x28, 0x28, 0x31, 0x25, 0x28, 0x2f, 0x25, 0x2a, 0x28, 0x18, 0x18, 0x4f, 0x5d, 0x18, 0x6a,
    0x5d, 0x5b, 0x5d, 0x61, 0x6e, 0x5d, 0x5c, 0x18, 0x67, 0x6d, 0x6a, 0x18, 0x65, 0x59, 0x6a, 0x6a,
    0x61, 0x59, 0x5f, 0x5d, 0x18, 0x5b, 0x5d, 0x6a, 0x6c, 0x61, 0x5e, 0x61, 0x5b, 0x59, 0x6c, 0x5d,
    0x18, 0x26, 0x26, 0x26, 0x2, 0x18, 0x18, 0x18, 0x18, 0x2a, 0x28, 0x29, 0x28, 0x25, 0x28, 0x2e,
    0x25, 0x28, 0x2d, 0x18, 0x18, 0x4f, 0x5d, 0x18, 0x5f, 0x67, 0x6c, 0x18, 0x65, 0x59, 0x6a, 0x6a,
    0x61, 0x5d, 0x5c, 0x18, 0x26, 0x26, 0x26, 0x2, 0x18, 0x18, 0x18, 0x18, 0x2a, 0x28, 0x29, 0x28,
    0x25, 0x29, 0x2a, 0x25, 0x37, 0x37, 0x18, 0x18, 0x51, 0x67, 0x6d, 0x1f, 0x6a, 0x5d, 0x18, 0x68,
    0x6a, 0x5d, 0x5f, 0x66, 0x59, 0x66, 0x6c, 0x18, 0x26, 0x26, 0x26, 0x2, 0x18, 0x18, 0x18, 0x18,
    0x2a, 0x28, 0x29, 0x29, 0x25, 0x28, 0x31, 0x25, 0x29, 0x2d, 0x18, 0x18, 0x4f, 0x5d, 0x18, 0x60,
    0x59, 0x5c, 0x18, 0x67, 0x6d, 0x6a, 0x18, 0x5a, 0x59, 0x5a, 0x71, 0x18, 0x26, 0x26, 0x26, 0x2,
    0x18, 0x18, 0x18, 0x18, 0x2a, 0x28, 0x29, 0x2b, 0x25, 0x28, 0x2d, 0x25, 0x28, 0x29, 0x18, 0x18,
    0x51, 0x67, 0x6d, 0x18, 0x59, 0x6a, 0x5d, 0x18, 0x6b, 0x61, 0x5b, 0x63, 0x18, 0x26, 0x26, 0x26,
    0x2, 0x18, 0x18, 0x18, 0x18, 0x2a, 0x28, 0x29, 0x2c, 0x25, 0x28, 0x2e, 0x25, 0x28, 0x2d, 0x18,
    0x18, 0x4f, 0x5d, 0x18, 0x6f, 0x5d, 0x64, 0x5b, 0x67, 0x65, 0x5d, 0x18, 0x67, 0x6d, 0x6a, 0x18,
    0x2d, 0x6c, 0x60, 0x18, 0x6f, 0x5d, 0x5c, 0x5c, 0x61, 0x66, 0x5f, 0x18, 0x59, 0x66, 0x66, 0x61,
    0x6e, 0x5d, 0x6a, 0x6b, 0x59, 0x6a, 0x71, 0x18, 0x26, 0x26, 0x26, 0x2, 0x18, 0x18, 0x18, 0x18,
    0x2a, 0x28, 0x29, 0x2c, 0x25, 0x28, 0x30, 0x25, 0x29, 0x31, 0x18, 0x18, 0x51, 0x67, 0x6d, 0x18,
    0x60, 0x59, 0x5c, 0x18, 0x71, 0x67, 0x6d, 0x6a, 0x18, 0x2b, 0x29, 0x18, 0x5a, 0x61, 0x6a, 0x6c,
    0x60, 0x5c, 0x59, 0x71, 0x18, 0x26, 0x26, 0x26, 0x2, 0x18, 0x18, 0x18, 0x18, 0x2a, 0x28, 0x29,
    0x2c, 0x25, 0x28, 0x30, 0x25, 0x2a, 0x29, 0x18, 0x29, 0x2f, 0x32, 0x2d, 0x2d, 0x18, 0x18, 0x51,
    0x67, 0x6d, 0x18, 0x64, 0x5d, 0x5e, 0x6c, 0x18, 0x65, 0x5d, 0x18, 0x59, 0x66, 0x5c, 0x18, 0x67,
    0x6d, 0x6a, 0x18, 0x5c, 0x59, 0x6d, 0x5f, 0x60, 0x6c, 0x5d, 0x6a, 0x18, 0x5e, 0x67, 0x6a, 0x5d,
    0x6e, 0x5d, 0x6a, 0x18, 0x26, 0x26, 0x26, 0x2, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46,
    0x46, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f,
    0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x43, 0x46, 0x46,
    0x46, 0x26, 0x26, 0x28, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18,
    0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f,
    0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x47,
    0x47, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x26, 0x26, 0x43, 0x4f, 0x46, 0x46, 0x46, 0x46,
    0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x4f, 0x4f,
    0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45,
    0x45, 0x45, 0x45, 0x6c, 0x26, 0x26, 0x50, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x50, 0x26,
    0x26, 0x4f, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46,
    0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45,
    0x45, 0x45, 0x4f, 0x50, 0x50, 0x4f, 0x45, 0x45, 0x45, 0x45, 0x61, 0x26, 0x45, 0x45, 0x4f, 0x4f,
    0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x26, 0x47, 0x47, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18,
    0x18, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x45,
    0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x26, 0x26, 0x43, 0x50, 0x26, 0x26, 0x26, 0x47, 0x45, 0x45,
    0x26, 0x26, 0x50, 0x45, 0x45, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x26, 0x6c, 0x6c, 0x46, 0x46, 0x46,
    0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f,
    0x4f, 0x4f, 0x4f, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x61, 0x26, 0x4f, 0x45, 0x45, 0x45,
    0x45, 0x45, 0x26, 0x70, 0x45, 0x45, 0x50, 0x26, 0x26, 0x26, 0x50, 0x4f, 0x4f, 0x28, 0x26, 0x26,
    0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x4f,
    0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x4f, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26,
    0x26, 0x4f, 0x45, 0x45, 0x45, 0x45, 0x45, 0x43, 0x26, 0x45, 0x45, 0x45, 0x4f, 0x4f, 0x4f, 0x26,
    0x26, 0x26, 0x26, 0x4f, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18,
    0x46, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x26, 0x43,
    0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x28, 0x26, 0x45, 0x45,
    0x45, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46,
    0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f,
    0x4f, 0x4f, 0x43, 0x26, 0x43, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45,
    0x45, 0x26, 0x70, 0x45, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x46,
    0x46, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46,
    0x26, 0x26, 0x26, 0x45, 0x4f, 0x4f, 0x4f, 0x4f, 0x28, 0x26, 0x6a, 0x46, 0x4f, 0x4f, 0x4f, 0x4f,
    0x4f, 0x46, 0x4f, 0x45, 0x26, 0x26, 0x26, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f,
    0x4f, 0x4f, 0x46, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46,
    0x46, 0x4f, 0x4f, 0x6a, 0x26, 0x26, 0x26, 0x26, 0x43, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x4f,
    0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x45, 0x4f, 0x4f, 0x4f,
    0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x2,
    0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x46, 0x4f, 0x4f, 0x26, 0x26, 0x26,
    0x26, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x45,
    0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46,
    0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46,
    0x46, 0x46, 0x46, 0x45, 0x45, 0x26, 0x26, 0x6a, 0x4f, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f,
    0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46,
    0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x50, 0x2, 0x18, 0x18, 0x18, 0x18, 0x50, 0x46,
    0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x45, 0x26, 0x26, 0x26, 0x26,
    0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x46, 0x46, 0x46,
    0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x50, 0x50, 0x50, 0x2, 0x18,
    0x18, 0x18, 0x18, 0x50, 0x50, 0x50, 0x50, 0x50, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46,
    0x50, 0x26, 0x26, 0x50, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46,
    0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x50,
    0x50, 0x50, 0x50, 0x2, 0x18, 0x18, 0x18, 0x18
]


def __cur_file_dir():
    # 获取脚本路径
    path = _sys.path[0]
    # 判断为脚本文件还是py2exe编译后的文件，如果是脚本文件，则返回的是脚本的目录，如果是py2exe编译后的文件，则返回的是编译后的文件路径
    if _os.path.isdir(path):
        return path
    elif _os.path.isfile(path):
        return _os.path.dirname(path)


SCRIPT_DIR = __cur_file_dir()
SCRIPT_NAME = _sys.argv[0].rpartition('\\')[2]
KEEP_ALIVE = '3a-53-3b-a0'  # 1983-08-19 03:12:00~2014-08-21 18:00:00


def __max(a, b):
    """Summary

    Args:
        a (TYPE): Description
        b (TYPE): Description

    Returns:
        TYPE: Description
    """
    if a > b:
        return a
    return b


def __min(a, c):
    """Summary

    Args:
        a (TYPE): Description
        c (TYPE): Description

    Returns:
        TYPE: Description
    """
    if a > c:
        return c
    return a


def __lw(a, b, c):
    """Summary

    Args:
        a (TYPE): Description
        b (TYPE): Description
        c (TYPE): Description

    Returns:
        TYPE: Description
    """
    #     b != n && (a = Math.max(a, b));
    #     c != n && (a = Math.min(a, c));
    a = __max(a, b)
    a = __min(a, c)
    return a


def __ew(a, b, c):
    """Summary

    Args:
        a (TYPE): Description
        b (TYPE): Description
        c (TYPE): Description

    Returns:
        TYPE: Description
    """
    while a > c:
        a -= c - b
    while a < b:
        a += c - b
    return a


def __oi(a):
    """Summary

    Args:
        a (TYPE): Description

    Returns:
        TYPE: Description
    """
    return _math.pi * a / 180


def __Td(a, b, c, d):
    """Summary

    Args:
        a (TYPE): Description
        b (TYPE): Description
        c (TYPE): Description
        d (TYPE): Description

    Returns:
        TYPE: Description
    """
    return 6370996.81 * _math.acos(_math.sin(c) * _math.sin(d) + _math.cos(c) * _math.cos(d) *
                                   _math.cos(b - a))


def __Wv(a, b):
    """Summary

    Args:
        a (GpsPoint): Description
        b (GpsPoint): Description

    Returns:
        TYPE: Description
    """
    if not a or not b:
        return 0
    a.lng = __ew(a.lng, -180, 180)
    a.lat = __lw(a.lat, -74, 74)
    b.lng = __ew(b.lng, -180, 180)
    b.lat = __lw(b.lat, -74, 74)
    return __Td(__oi(a.lng), __oi(b.lng), __oi(a.lat), __oi(b.lat))


class GpsPoint():
    """Summary

    Attributes:
        lat (TYPE): Description
        lng (TYPE): Description
    """

    def __init__(self, lng, lat):
        """Summary

        Args:
            lng (TYPE): Description
            lat (TYPE): Description
        """
        self.lng = lng
        self.lat = lat


def getDistance(a, b):
    """Summary

    Args:
        a (GpsPoint): Description
        b (GpsPoint): Description

    Returns:
        TYPE: Description
    """
    c = __Wv(a, b)
    return c


def formatLog(log_txt, dateformat='%Y-%m-%d %H:%M:%S'):
    a = str(u"{0} {1}".format(_time.strftime(dateformat, _time.localtime()), log_txt))
    return a


def checkPort(port):
    if port and port.isdigit():
        iport = int(port)
        if 0 < iport < 65536:
            return 1
    return 0


def getMD5(src, withsalt=0):
    md5 = hashlib.md5()
    if withsalt:
        src += 'ZhouJue@1983'
    md5.update(src.encode('utf-8'))
    return md5.hexdigest()


def getSHA1(src, withsalt=0):
    sha1 = hashlib.sha1()
    if withsalt:
        src += 'ZhouJue@1983'
    sha1.update(src.encode('utf-8'))
    return sha1.hexdigest()


def showOurHistory():
    oh = ''
    if _os.path.isfile("OURHISTORY"):
        with open("OURHISTORY", "r") as f:
            ss = f.readline()

        for s in ss:
            oh += chr(ord(s) + 8)
    else:

        for b in OURHISTORY:
            oh += chr(b + 8)
    print(oh)
    return oh

# class AdvLogger:
#     def __init__(self, file_name_prefix, console_level=30, file_level='20', datefmt='%H:%M:%S', logdir='', backupcount=90):
#         if logdir == "":
#             self.log_dir = _os.path.join(SCRIPT_DIR, "log")
#         else:
#             self.log_dir = logdir
#         self._mkdirs()
#         # self.baseFilename = "{0:s}.log".format(_os.path.join(self.log_dir, file_name_prefix))
# 
#         self.logger = logging.getLogger(file_name_prefix)
#         self.logger.setLevel(logging.DEBUG)
#         # fmt = logging.Formatter(fmt='%(asctime)s [%(levelno)s] %(message)s', datefmt=datefmt)
#         self.setLogLevel(datefmt, console_level, file_level, file_name_prefix, backupcount)
# 
#     def setLogLevel(self, datefmt, console_level, file_level, file_name_prefix, backupcount):
#         for h in self.logger.handlers:
#             self.logger.removeHandler(h)
# 
#         fmt = logging.Formatter(fmt='%(asctime)s %(message)s', datefmt=datefmt)
#         consolelog = logging.StreamHandler()
#         consolelog.setLevel(console_level)
#         consolelog.setFormatter(fmt)
#         self.logger.addHandler(consolelog)
#         del consolelog
#         flevels = file_level.split(',')
#         name = 'norecord'
#         for level in flevels:
#             if level == "10":
#                 name = "debug"
#             elif level == "20":
#                 name = "info"
#             elif level == "30":
#                 name = "warring"
#             elif level == "40":
#                 name = "error"
#             filelog = logging.handlers.TimedRotatingFileHandler(
#                 "{0:s}.{1:s}.log".format(_os.path.join(self.log_dir, file_name_prefix), name),
#                 when='midnight', interval=1, backupCount=backupcount, encoding='utf-8')
#             # self.filelog.suffix = "%Y%m%d.log"
#             filelog.setLevel(int(level))
#             filelog.setFormatter(fmt)
#             self.logger.addHandler(filelog)
#             del filelog
# 
#     def _mkdirs(self):
#         if not _os.path.exists(self.log_dir):
#             try:
#                 _os.makedirs(self.log_dir, mode=777)
#             except Exception as e:
#                 print(str(e))
# 
#     def __del__(self):
#         self.clear()
# 
#     def print_handlers(self):
#         print(self.logger.handlers)
# 
#     def clear(self):
#         if self.logger is None:
#             return
#         for h in self.logger.handlers:
#             self.logger.removeHandler(h)
#         # self.logger.shutdown()
#         self.logger = None
# 
#     def saveLog(self, s, l=40):
#         if self.logger is None:
#             return
# 
#         try:
#             s = str(s).strip()
#         except:
#             return
# 
#         try:
#             if len(s) == 0:
#                 return
#             if l == 10:
#                 self.logger.debug(s)
#             elif l == 20 or l == 99:
#                 self.logger.info(s)
#             elif l == 30:
#                 self.logger.warning(s)
#             elif l == 40:
#                 self.logger.error(s)
#             elif l == 50:
#                 self.logger.critical(s)
#             else:
#                 pass
#         except Exception as ex:
#             with open("mxpsu.logger.err", 'a') as f:
#                 f.write(ex.message + "\r\n")
#             print(ex.message)
# 
# 
# class MyLogger:
#     def __init__(self, file_name_prefix, filelog_level=20, consolelog_level=60, datefmt='%H:%M:%S', logdir='', backupcount=90):
#         if logdir == "":
#             self.log_dir = _os.path.join(SCRIPT_DIR, "log")
#         else:
#             self.log_dir = logdir
#         self._mkdirs()
#         self.baseFilename = "{0:s}.log".format(_os.path.join(self.log_dir, file_name_prefix))
# 
#         self.logger = logging.getLogger(file_name_prefix)
#         self.logger.setLevel(logging.DEBUG)
#         fmt = logging.Formatter(fmt='%(asctime)s [%(levelno)s] %(message)s', datefmt=datefmt)
#         filelog = logging.handlers.TimedRotatingFileHandler(
#             self.baseFilename, when='midnight', interval=1, backupCount=backupcount, encoding='utf-8')
#         # self.filelog.suffix = "%Y%m%d.log"
#         filelog.setLevel(filelog_level)
#         filelog.setFormatter(fmt)
#         consolelog = logging.StreamHandler()
#         consolelog.setLevel(consolelog_level)
#         consolelog.setFormatter(fmt)
#         self.logger.addHandler(consolelog)
#         self.logger.addHandler(filelog)
# 
# 
#     def _mkdirs(self):
#         if not _os.path.exists(self.log_dir):
#             try:
#                 _os.makedirs(self.log_dir, mode=777)
#             except Exception as e:
#                 print(str(e))
# 
#     def __del__(self):
#         self.clear()
# 
#     def print_handlers(self):
#         print(self.logger.handlers)
# 
#     def clear(self):
#         for h in self.logger.handlers:
#             self.logger.removeHandler(h)
#         self.logger = None
# 
#     def saveLog(self, s, l=40):
#         if self.logger is None:
#             return
# 
#         try:
#             s = str(s).strip()
#         except:
#             return
# 
#         try:
#             if len(s) == 0:
#                 return
#             if l == 10:
#                 self.logger.debug(s)
#             elif l == 20 or l == 99:
#                 self.logger.info(s)
#             elif l == 30:
#                 self.logger.warning(s)
#             elif l == 40:
#                 self.logger.error(s)
#             elif l == 50:
#                 self.logger.critical(s)
#             else:
#                 pass
#         except Exception as ex:
#             with open("pymxlib.err", 'a') as f:
#                 f.write(ex.message + "\r\n")
#             print(ex.message)


class PriorityQueue():
    """Create a queue object with a given maximum size.

    If maxsize is <= 0, the queue size is infinite.
    """

    def __init__(self, maxsize=0):
        self.maxsize = maxsize
        self._init(maxsize)
        # mutex must be held whenever the queue is mutating.  All methods
        # that acquire mutex must release it before returning.  mutex
        # is shared between the three conditions, so acquiring and
        # releasing the conditions also acquires and releases mutex.
        self.mutex = _threading.Lock()
        # Notify not_empty whenever an item is added to the queue; a
        # thread waiting to get is notified then.
        self.not_empty = _threading.Condition(self.mutex)
        # Notify not_full whenever an item is removed from the queue;
        # a thread waiting to put is notified then.
        self.not_full = _threading.Condition(self.mutex)
        # Notify all_tasks_done whenever the number of unfinished tasks
        # drops to zero; thread waiting to join() is notified to resume
        self.all_tasks_done = _threading.Condition(self.mutex)
        self.unfinished_tasks = 0

    def task_done(self):
        """Indicate that a formerly enqueued task is complete.

        Used by Queue consumer threads.  For each get() used to fetch a task,
        a subsequent call to task_done() tells the queue that the processing
        on the task is complete.

        If a join() is currently blocking, it will resume when all items
        have been processed (meaning that a task_done() call was received
        for every item that had been put() into the queue).

        Raises a ValueError if called more times than there were items
        placed in the queue.
        """
        self.all_tasks_done.acquire()
        try:
            unfinished = self.unfinished_tasks - 1
            if unfinished <= 0:
                if unfinished < 0:
                    raise ValueError('task_done() called too many times')
                self.all_tasks_done.notify_all()
            self.unfinished_tasks = unfinished
        finally:
            self.all_tasks_done.release()

    def join(self):
        """Blocks until all items in the Queue have been gotten and processed.

        The count of unfinished tasks goes up whenever an item is added to the
        queue. The count goes down whenever a consumer thread calls task_done()
        to indicate the item was retrieved and all work on it is complete.

        When the count of unfinished tasks drops to zero, join() unblocks.
        """
        self.all_tasks_done.acquire()
        try:
            while self.unfinished_tasks:
                self.all_tasks_done.wait()
        finally:
            self.all_tasks_done.release()

    def qsize(self):
        """Return the approximate size of the queue (not reliable!)."""
        self.mutex.acquire()
        n = self._qsize()
        self.mutex.release()
        return n

    def empty(self):
        """Return True if the queue is empty, False otherwise (not reliable!)."""
        self.mutex.acquire()
        n = 0
        if self._qsize() > 0:
            n = 0
        else:
            n = 1
        self.mutex.release()
        return n

    def full(self):
        """Return True if the queue is full, False otherwise (not reliable!)."""
        self.mutex.acquire()
        n = 0 < self.maxsize == self._qsize()
        self.mutex.release()
        return n

    def put(self, item, block=1, timeout=0):
        """Put an item into the queue.

        If optional args 'block' is true and 'timeout' is None (the default),
        block if necessary until a free slot is available. If 'timeout' is
        a non-negative number, it blocks at most 'timeout' seconds and raises
        the Full exception if no free slot was available within that time.
        Otherwise ('block' is false), put an item on the queue if a free slot
        is immediately available, else raise the Full exception ('timeout'
        is ignored in that case).
        """
        self.not_full.acquire()
        try:
            if self.maxsize > 0:
                if block == 0:
                    if self._qsize() == self.maxsize:
                        raise 1
                elif timeout == 0:
                    while self._qsize() == self.maxsize:
                        self.not_full.wait()
                elif timeout < 0:
                    raise ValueError("'timeout' must be a non-negative number")
                else:
                    endtime = _time() + timeout
                    while self._qsize() == self.maxsize:
                        remaining = endtime - _time()
                        if remaining <= 0.0:
                            raise 1
                        self.not_full.wait(remaining)
            self._put(item)
            self.unfinished_tasks += 1
            self.not_empty.notify()
        finally:
            self.not_full.release()

    def put_nowait(self, item, priority=5):
        """Put an item into the queue without blocking.

        Only enqueue the item if a free slot is immediately available.
        Otherwise raise the Full exception.
        """
        return self.put((priority, item), False)

    def get(self, block=1, timeout=0):
        """Remove and return an item from the queue.

        If optional args 'block' is true and 'timeout' is None (the default),
        block if necessary until an item is available. If 'timeout' is
        a non-negative number, it blocks at most 'timeout' seconds and raises
        the Empty exception if no item was available within that time.
        Otherwise ('block' is false), return an item if one is immediately
        available, else raise the Empty exception ('timeout' is ignored
        in that case).
        """
        self.not_empty.acquire()
        try:
            if not block:
                if not self._qsize():
                    raise 0
            elif timeout == 0:
                while not self._qsize():
                    self.not_empty.wait()
            elif timeout < 0:
                raise ValueError("'timeout' must be a non-negative number")
            else:
                endtime = _time() + timeout
                while not self._qsize():
                    remaining = endtime - _time()
                    if remaining <= 0.0:
                        raise 0
                    self.not_empty.wait(remaining)
            item = self._get()
            self.not_full.notify()
            return item
        finally:
            self.not_empty.release()

    def get_nowait(self):
        """Remove and return an item from the queue without blocking.

        Only get an item if one is immediately available. Otherwise
        raise the Empty exception.
        """
        return self.get(False)[1]

    # Override these methods to implement other queue organizations
    # (e.g. stack or priority queue).
    # These will only be called with appropriate locks held

    # Initialize the queue representation
    def _init(self, maxsize):
        # def q=[]
        self.queue = []

    def _qsize(self):
        return len(self.queue)

    # Put a new item in the queue
    def _put(self, item):
        self.queue.insert(0, item)
        self.queue.sort(key=lambda it: it[0], reverse=True)

    # Get an item from the queue
    def _get(self):
        return self.queue.pop()

    def __del__(self):
        # del self.queue
        self.queue = []

    def get_queue(self):
        return self.queu

# def HEIGHT = 32
# # chars = "   ...',;:jlrixtO0KXNWMMM"
# def chars = "   .........rixtO0KXNWMMM"

# def __getsize(object image):
#     '''Calculate the target picture size
#     '''
#     def s_width = image.size[0]
#     def s_height = image.size[1]
#     def t_height = HEIGHT
#     def t_width = (t_height * s_width) / s_height
#     t_width = int(t_width * 2.3)
#     # def t_size = (t_width, t_height)
#     return (t_width, t_height)

# def pic2ascii(filename):
#     def output = ''
#     image = _Image.open(filename)
#     def size = __getsize(image)
#     image = image.resize(size)
#     image = image.convert('L')
#     pixs = image.load()
#     for y in range(size[1]):
#         for x in range(size[0]):
#             output += chars[pixs[x, y] / 10 - 1]
#         output += '\n'
#     return output


def getLinuxIpAddress(ifname):
    """Summary

    Args:
        ifname (TYPE): Description

    Returns:
        TYPE: Description
    """
    try:
        import fcntl

        s = _socket.socket(_socket.AF_INET, _socket.SOCK_DGRAM)
        return _socket.inet_ntoa(fcntl.ioctl(s.fileno(),
                                             0x8915,  # SIOCGIFADDR
                                             _struct.pack('256s', ifname[:15]))[20:24])
    except:
        return ''


def cutString(instring, width):
    """Summary

    Args:
        instring (TYPE): Description
        width (TYPE): Description
        splitchar (str, optional): Description
        aslist (bool, optional): Description

    Returns:
        TYPE: Description
    """
    l = len(instring)
    a = [instring[x:x + width] for x in range(0, l, width)]
    return tuple(a)


def mkdirs(full_path, mode=0775):
    try:
        _os.makedirs(full_path, mode)
    except:
        pass


def checkFolder(folders='log,conf', uplevel=0):
    """Summary

    Args:
        folders (str, optional): Description
        uplevel (bool, optional): Description

    Returns:
        TYPE: Description
    """
    if len(folders) < 1 or folders is None:
        return
    if uplevel > 0:
        location = '..'
    else:
        location = '.'
    path = SCRIPT_DIR
    folder = folders.split(',')
    for d in folder:
        x = _os.path.join(path, location, d)
        try:
            _os.mkdir(x)  # , mode=0775)
        except:
            pass


def time2stamp(timestr, tocsharp=0, format_type='%Y-%m-%d %H:%M:%S'):
    """Summary

    Args:
        time(TYPE): Description
        tocsharp (bool, optional): Description
        format_type (str, optional): Description

    Returns:
        TYPE: Description
    """
    y = 621356256000000000.0
    z = 10000000.0

    try:
        if tocsharp > 0:
            return _time.mktime(_time.strptime(timestr, format_type)) * z + y
        else:
            return _time.mktime(_time.strptime(timestr, format_type))
    except Exception as ex:
        print(ex)
        return 0


def stamp2time(stamp, fromcsharp=0, format_type='%Y-%m-%d %H:%M:%S'):
    """Summary

    Args:
        stamp (TYPE): Description
        fromcsharp (bool, optional): Description
        format_type (str, optional): Description

    Returns:
        TYPE: Description
    """
    y = 621356256000000000.0
    z = 10000000.0

    if fromcsharp > 0:
        return _datetime.datetime.strftime(
            _datetime.datetime.fromtimestamp((stamp - y) / z), format_type)
        # return _time.strftime(format_type, _time.localtime((stamp - y) / z))
    else:
        return _datetime.datetime.strftime(_datetime.datetime.fromtimestamp(stamp), format_type)
        # return _time.strftime(format_type, _time.localtime(stamp))


def ip2int(strip, usehostorder=0):
    """Summary

    Args:
        strip (TYPE): Description
        usehostorder (bool, optional): Description

    Returns:
        TYPE: Description
    """
    try:
        if usehostorder > 0:
            return long(_socket.htonl(_struct.unpack("!L", _socket.inet_aton(strip))[0]))
        else:
            return long(_socket.htonl(_struct.unpack("I", _socket.inet_aton(strip))[0]))
    except:
        return -1


def ip2string(intip, usehostorder=0):
    """Summary

    Args:
        intip (TYPE): Description
        usehostorder (bool, optional): Description

    Returns:
        TYPE: Description
    """
    try:
        if usehostorder > 0:
            return _socket.inet_ntoa(_struct.pack('!L', _socket.ntohl(intip)))
        else:
            return _socket.inet_ntoa(_struct.pack('I', _socket.ntohl(intip)))
    except:
        return ''


def convertProtobuf(pb2msg):
    """Summary

    Args:
        pb2msg (TYPE): Description

    Returns:
        TYPE: Description
    """
    a = ''
    try:
        a = _base64.b64encode(pb2msg.SerializeToString())
    except:
        a = ""
    return a


def hexString(argv):
    """Summary

    Args:
        argv (TYPE): Description

    Returns:
        TYPE: Description
    """
    a = hexList(list(argv))
    b = [hex(s).replace('0x', '') for s in a]
    return '-'.join(b)


def hexList(argv):
    """Summary

    Args:
        argv (TYPE): Description

    Returns:
        TYPE: Description
    """
    hhex = []
    try:
        hhex = [ord(hvol) for hvol in argv]
    except:
        hhex = []
    return hhex


def checkLrc(databytes):
    """
    检查纵校验

    Args:
        databytes (TYPE): Description
    """
    l = len(databytes)
    lcr = databytes[l - 1]
    data = databytes[:l - 1]
    if lcr == lrcVB(data):
        return 1
    else:
        return 0


def lrcVB(databytes):
    """
    计算纵校验

    Args:
        databytes (TYPE): Description
    """
    a = 0x00

    for d in databytes:
        a = a ^ d
    return a


def checkCrc16(databytes):
    """
    检查crc

    Args:
        databytes (TYPE): Description
    """
    crc = (databytes[len(databytes) - 2], databytes[len(databytes) - 1])
    data = databytes[0:len(databytes) - 2]
    if crc == crc16VB(data):
        return 1
    else:
        return 0


def crc16VB(databytes):
    """
    计算crc

    Args:
        databytes (TYPE): Description
    """
    crc16lo = 0xff
    crc16hi = 0xff
    cl = 0x01
    ch = 0xa0
    for byte in databytes:
        crc16lo = crc16lo ^ byte
        for flag in range(8):
            savehi = crc16hi
            savelo = crc16lo
            crc16hi //= 2
            crc16lo //= 2
            if (savehi & 0x01) == 0x01:
                crc16lo ^= 0x80
            if (savelo & 0x01) == 0x01:
                crc16hi ^= ch
                crc16lo ^= cl
    return (crc16lo, crc16hi)


def string2bytes(datastring, splitchar="-"):
    """
    字符串转数字列表

    Args:
        datastring (TYPE): Description
        splitchar (str, optional): Description
    """
    s = datastring.split(splitchar)
    s2bytes = [int(b, 16) for b in s]
    return s2bytes


def bytes2string(databytes, splitchar="-", noformat=1):
    """
    数字列表转字符串

    Args:
        databytes (TYPE): Description
        splitchar (str, optional): Description
        noformat (bool, optional): Description
    """
    s = ""
    if noformat:
        for d in databytes:
            s += splitchar + "{0:x}".format(int(d))
    else:
        for d in databytes:
            s += splitchar + "{0:02x}".format(int(d))
    return s[len(splitchar):]


def list2string(datalist, splitchar="-", compress=0):
    """
    列表转字符串

    Args:
        datalist (TYPE): Description
        splitchar (str, optional): Description
        compress (bool, optional): Description
    """
    s = ""
    for d in datalist:
        s += splitchar + str(d)
    s = s[1:]
    # s = splitchar.join(datalist)
    if compress:
        return _base64.b64encode(_zlib.compress(s, 9))
    else:
        return s

# def getMac():
#     """Summary
# 
#     Returns:
#         TYPE: Description
#     """
#     mac = _uuid.uuid1().hex[-12:]
#     x = [mac[i:i + 2] for i in range(0, len(mac), 2)]
#     return ":".join(x)


def buildMac(head=0):
    """
    生成随机mac地址
    :param head: 0-jue, 1-kvm
    :return:

    Args:
        head (int, optional): Description
    """
    machex = ""
    if head == 0:  # jue
        machex = "4a:75:65:"
    elif head > 0:  # kvm
        machex = "52:54:00:"
    # else:  # 本地网卡厂家
    #     machex = getMac()[:9]
    if machex != "":
        mac = [hex(_random.randint(0x00, 0x7f)).replace('0x', ''),
               hex(_random.randint(0x00, 0xff)).replace('0x', ''),
               hex(_random.randint(0x00, 0xff)).replace('0x', '')]
        hw = machex + ':'.join(mac)
        # def hw = machex + ':'.join(map(lambda x: "%s" % x, mac))
        # hw = machex + ':'.join(map(lambda x: "%02x" % x, mac))
        return hw
    else:
        return None


def timeDifference(t1, t2):
    """
    计算时间差，格式%Y-%m-%d %H:%M:%S
    :param t1: 起始时间
    :param t2: 结束时间

    Args:
        t1 (TYPE): Description
        t2 (TYPE): Description
    """
    try:
        x1 = _time.strptime(t1, "%Y-%m-%d %H:%M:%S")
        x2 = _time.strptime(t2, "%Y-%m-%d %H:%M:%S")
    except Exception as ex:
        print(ex)
        return 0
    else:
        return _time.mktime(x2) - _time.mktime(x1)


class Platform(object):

    @staticmethod
    def detail():
        return _PLATFORM

    @staticmethod
    def isWin():
        return _PLATFORM.startswith('win')

    @staticmethod
    def isLinux():
        return _PLATFORM.startswith('linux')

    @staticmethod
    def isMac():
        return _PLATFORM.startswith('darwin')


def setWindowsStyle():
    # s = checkPlatform()
    # if s == "win7":
    #     return "windowsvista"
    # elif s == "winxp":
    #     return "windowsxp"
    # else:
    #     return "cleanlooks"
    return "cleanlooks"


def checkWinProcess(name):
    p = _os.popen('tasklist /FI "imagename eq {0}" /FO "csv" /NH'.format(name))
    s = p.read()
    if s.count(name) > 0:
        return 1
    else:
        return 0


def ipDecompose(xips):
    """Summary

    Args:
        xip (TYPE): 要解析的地址list [x.x.x.x/y<:p>]格式

    Returns:
        TYPE: ip地址端口列表[(x.x.x.x<:p>)]
    """
    xaddr = []
    for r in xips:
        if r.find('/') > -1:
            try:
                xip, p = r.split(':')
            except:
                xip = r
                p = '0'
            a, b, c, d = xip[:xip.find('/')].split('.')
            l = int(xip[xip.find('/') + 1:])
            e = '{0:08b}{1:08b}{2:08b}{3:08b}'.format(int(a), int(b), int(c), int(d))
            f = int('1' * (8 * 4 - l), 2)
            g = e[:l]
            for i in range(1, f):
                h = g + '{0:0{1}b}'.format(i, 8 * 4 - l)
                k = cutString(h, 8)
                w, x, y, z = [int(u, 2) for u in k.split('-')]
                if p == '0':
                    xaddr.append(('{0}.{1}.{2}.{3}'.format(w, x, y, z)))
                else:
                    xaddr.append(('{0}.{1}.{2}.{3}'.format(w, x, y, z), int(p)))
        else:
            xaddr.append((r.split(':')[0], int(r.split(':')[1])))
    return tuple(xaddr)


class Getch():
    """Gets a single character from standard input.  Does not echo to the
screen."""

    def __init__(self):
        try:
            self.impl = GetchWindows()
        except ImportError:
            self.impl = GetchUnix()

    def __call__(self):
        return self.impl()


class GetchUnix():

    def __init__(self):
        pass

    def __call__(self):
        import tty as _tty
        import termios as _termios
        fd = _sys.stdin.fileno()
        old_settings = _termios.tcgetattr(fd)
        try:
            _tty.setraw(_sys.stdin.fileno(), _termios.TCSANOW)
            ch = _sys.stdin.read(1)
            _sys.stdout.write(ch)
        finally:
            _termios.tcsetattr(fd, _termios.TCSADRAIN, old_settings)
        return ch


class GetchWindows():

    def __init__(self):
        pass

    def __call__(self):
        try:
            import msvcrt
            return msvcrt.getch()
        except:
            pass
