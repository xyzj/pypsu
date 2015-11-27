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
import random as _random
import json as _json
import math as _math
import platform as _platform
import socket as _socket
import struct as _struct
import os as _os
import uuid as _uuid
import logging
import logging.handlers
# import Image as _Image
import sys as _sys
reload(_sys)
_sys.setdefaultencoding(_sys.getfilesystemencoding())

cdef list OURHISTORY = [0x2, 0x18, 0x18, 0x18, 0x18, 0x2a, 0x28, 0x28, 0x2f, 0x25, 0x29, 0x2a, 0x25, 0x28, 0x2f, 0x18, 0x18, 0x4f, 0x5d, 0x18, 0x65, 0x5d, 0x6c, 0x18, 0x26, 0x26, 0x26, 0x2, 0x18, 0x18, 0x18, 0x18, 0x2a, 0x28, 0x28, 0x31, 0x25, 0x28, 0x29, 0x25, 0x2a, 0x30, 0x18, 0x18, 0x4f, 0x5d, 0x18, 0x5b, 0x67, 0x66, 0x5c, 0x6d, 0x5b, 0x6c, 0x5d, 0x5c, 0x18, 0x6c, 0x60, 0x5d, 0x18, 0x5e, 0x61, 0x6a, 0x6b, 0x6c, 0x18, 0x6c, 0x6a, 0x61, 0x68, 0x18, 0x26, 0x26, 0x26, 0x2, 0x18, 0x18, 0x18, 0x18, 0x2a, 0x28, 0x28, 0x31, 0x25, 0x28, 0x2f, 0x25, 0x2a, 0x28, 0x18, 0x18, 0x4f, 0x5d, 0x18, 0x6a, 0x5d, 0x5b, 0x5d, 0x61, 0x6e, 0x5d, 0x5c, 0x18, 0x67, 0x6d, 0x6a, 0x18, 0x65, 0x59, 0x6a, 0x6a, 0x61, 0x59, 0x5f, 0x5d, 0x18, 0x5b, 0x5d, 0x6a, 0x6c, 0x61, 0x5e, 0x61, 0x5b, 0x59, 0x6c, 0x5d, 0x18, 0x26, 0x26, 0x26, 0x2, 0x18, 0x18, 0x18, 0x18, 0x2a, 0x28, 0x29, 0x28, 0x25, 0x28, 0x2e, 0x25, 0x28, 0x2d, 0x18, 0x18, 0x4f, 0x5d, 0x18, 0x5f, 0x67, 0x6c, 0x18, 0x65, 0x59, 0x6a, 0x6a, 0x61, 0x5d, 0x5c, 0x18, 0x26, 0x26, 0x26, 0x2, 0x18, 0x18, 0x18, 0x18, 0x2a, 0x28, 0x29, 0x28, 0x25, 0x29, 0x2a, 0x25, 0x37, 0x37, 0x18, 0x18, 0x51, 0x67, 0x6d, 0x1f, 0x6a, 0x5d, 0x18, 0x68, 0x6a, 0x5d, 0x5f, 0x66, 0x59, 0x66, 0x6c, 0x18, 0x26, 0x26, 0x26, 0x2, 0x18, 0x18, 0x18, 0x18, 0x2a, 0x28, 0x29, 0x29, 0x25, 0x28, 0x31, 0x25, 0x29, 0x2d, 0x18, 0x18, 0x4f, 0x5d, 0x18, 0x60, 0x59, 0x5c, 0x18, 0x67, 0x6d, 0x6a, 0x18, 0x5a, 0x59, 0x5a, 0x71, 0x18, 0x26, 0x26, 0x26, 0x2, 0x18, 0x18, 0x18, 0x18, 0x2a, 0x28, 0x29, 0x2b, 0x25, 0x28, 0x2d, 0x25, 0x28, 0x29, 0x18, 0x18, 0x51, 0x67, 0x6d, 0x18, 0x59, 0x6a, 0x5d, 0x18, 0x6b, 0x61, 0x5b, 0x63, 0x18, 0x26, 0x26, 0x26, 0x2, 0x18, 0x18, 0x18, 0x18, 0x2a, 0x28, 0x29, 0x2c, 0x25, 0x28, 0x2e, 0x25, 0x28, 0x2d, 0x18, 0x18, 0x4f, 0x5d, 0x18, 0x6f, 0x5d, 0x64, 0x5b, 0x67, 0x65, 0x5d, 0x18, 0x67, 0x6d, 0x6a, 0x18, 0x2d, 0x6c, 0x60, 0x18, 0x6f, 0x5d, 0x5c, 0x5c, 0x61, 0x66, 0x5f, 0x18, 0x59, 0x66, 0x66, 0x61, 0x6e, 0x5d, 0x6a, 0x6b, 0x59, 0x6a, 0x71, 0x18, 0x26, 0x26, 0x26, 0x2, 0x18, 0x18, 0x18, 0x18, 0x2a, 0x28, 0x29, 0x2c, 0x25, 0x28, 0x30, 0x25, 0x29, 0x31, 0x18, 0x18, 0x51, 0x67, 0x6d, 0x18, 0x60, 0x59, 0x5c, 0x18, 0x71, 0x67, 0x6d, 0x6a, 0x18, 0x2b, 0x29, 0x18, 0x5a, 0x61, 0x6a, 0x6c, 0x60, 0x5c, 0x59, 0x71, 0x18, 0x26, 0x26, 0x26, 0x2, 0x18, 0x18, 0x18, 0x18, 0x2a, 0x28, 0x29, 0x2c, 0x25, 0x28, 0x30, 0x25, 0x2a, 0x29, 0x18, 0x29, 0x2f, 0x32, 0x2d, 0x2d, 0x18, 0x18, 0x51, 0x67, 0x6d, 0x18, 0x64, 0x5d, 0x5e, 0x6c, 0x18, 0x65, 0x5d, 0x18, 0x59, 0x66, 0x5c, 0x18, 0x67, 0x6d, 0x6a, 0x18, 0x5c, 0x59, 0x6d, 0x5f, 0x60, 0x6c, 0x5d, 0x6a, 0x18, 0x5e, 0x67, 0x6a, 0x5d, 0x6e, 0x5d, 0x6a, 0x18, 0x26, 0x26, 0x26, 0x2, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x43, 0x46, 0x46, 0x46, 0x26, 0x26, 0x28, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x47, 0x47, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x26, 0x26, 0x43, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x6c, 0x26, 0x26, 0x50, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x50, 0x26, 0x26, 0x4f, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x4f, 0x50, 0x50, 0x4f, 0x45, 0x45, 0x45, 0x45, 0x61, 0x26, 0x45, 0x45, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x26, 0x47, 0x47, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x26, 0x26, 0x43, 0x50, 0x26, 0x26, 0x26, 0x47, 0x45, 0x45, 0x26, 0x26, 0x50, 0x45, 0x45, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x26, 0x6c, 0x6c, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x61, 0x26, 0x4f, 0x45, 0x45, 0x45, 0x45, 0x45, 0x26, 0x70, 0x45, 0x45, 0x50, 0x26, 0x26, 0x26, 0x50, 0x4f, 0x4f, 0x28, 0x26, 0x26, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x4f, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x4f, 0x45, 0x45, 0x45, 0x45, 0x45, 0x43, 0x26, 0x45, 0x45, 0x45, 0x4f, 0x4f, 0x4f, 0x26, 0x26, 0x26, 0x26, 0x4f, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x26, 0x43, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x28, 0x26, 0x45, 0x45, 0x45, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x43, 0x26, 0x43, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x45, 0x26, 0x70, 0x45, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x26, 0x26, 0x26, 0x45, 0x4f, 0x4f, 0x4f, 0x4f, 0x28, 0x26, 0x6a, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x4f, 0x45, 0x26, 0x26, 0x26, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x4f, 0x4f, 0x6a, 0x26, 0x26, 0x26, 0x26, 0x43, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x4f, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x45, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x46, 0x4f, 0x46, 0x4f, 0x4f, 0x26, 0x26, 0x26, 0x26, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x45, 0x45, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x2, 0x18, 0x18, 0x18, 0x18, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x45, 0x45, 0x26, 0x26, 0x6a, 0x4f, 0x46, 0x46, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x50, 0x2, 0x18, 0x18, 0x18, 0x18, 0x50, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x45, 0x26, 0x26, 0x26, 0x26, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x50, 0x50, 0x50, 0x2, 0x18, 0x18, 0x18, 0x18, 0x50, 0x50, 0x50, 0x50, 0x50, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x50, 0x26, 0x26, 0x50, 0x4f, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x50, 0x50, 0x50, 0x50, 0x2, 0x18, 0x18, 0x18, 0x18]


cdef str __cur_file_dir():
    # 获取脚本路径
    cdef str path = _sys.path[0]
    # 判断为脚本文件还是py2exe编译后的文件，如果是脚本文件，则返回的是脚本的目录，如果是py2exe编译后的文件，则返回的是编译后的文件路径
    if _os.path.isdir(path):
        return path
    elif _os.path.isfile(path):
        return _os.path.dirname(path)


SCRIPT_DIR = __cur_file_dir()
SCRIPT_NAME = _sys.argv[0].rpartition('\\')[2]
KEEP_ALIVE = '3a-53-3b-a0'  # 1983-08-19 03:12:00~2014-08-21 18:00:00


cdef double __max(double a, double b):
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


cdef double __min(double a, double c):
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


cdef double __lw(double a, int b, int c):
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


cdef double __ew(double a, int b, int c):
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


cdef double __oi(double a):
    """Summary

    Args:
        a (TYPE): Description

    Returns:
        TYPE: Description
    """
    return _math.pi * a / 180


cdef double __Td(double a, double b, double c, double d):
    """Summary

    Args:
        a (TYPE): Description
        b (TYPE): Description
        c (TYPE): Description
        d (TYPE): Description

    Returns:
        TYPE: Description
    """
    return 6370996.81 * _math.acos(_math.sin(c) * _math.sin(d) + _math.cos(c) * _math.cos(d) * _math.cos(b - a))


cdef double __Wv(a, b):
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


cdef class GpsPoint:
    """Summary

    Attributes:
        lat (TYPE): Description
        lng (TYPE): Description
    """
    cdef public double lng, lat
    def __init__(self, double lng, double lat):
        """Summary

        Args:
            lng (TYPE): Description
            lat (TYPE): Description
        """
        self.lng = lng
        self.lat = lat


cpdef double get_distance(a, b):
    """Summary

    Args:
        a (GpsPoint): Description
        b (GpsPoint): Description

    Returns:
        TYPE: Description
    """
    c = __Wv(a, b)
    return c


cpdef str format_log(str log_txt, str dateformat='%Y-%m-%d %H:%M:%S'):
    cdef str a = str(u"{0} {1}".format(_time.strftime(dateformat, _time.localtime()), log_txt))
    return a


cpdef str show_our_history():
    cdef str oh = ''
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


cdef class AdvLogger:
    cdef str file_name_prefix, file_level, datefmt, log_dir
    cdef int console_level, backupcount
    cdef object logger
    def __init__(self, str file_name_prefix, int console_level=30, str file_level='20', str datefmt='%H:%M:%S', str logdir='', int backupcount=90):
        if logdir == "":
            self.log_dir = _os.path.join(SCRIPT_DIR, "log")
        else:
            self.log_dir = logdir
        self._mkdirs()
        # self.baseFilename = "{0:s}.log".format(_os.path.join(self.log_dir, file_name_prefix))

        self.logger = logging.getLogger(file_name_prefix)
        self.logger.setLevel(logging.DEBUG)
        # fmt = logging.Formatter(fmt='%(asctime)s [%(levelno)s] %(message)s', datefmt=datefmt)
        self.set_log_level(datefmt, console_level, file_level, file_name_prefix, backupcount)

    cdef set_log_level(self, str datefmt, int console_level, str file_level, str file_name_prefix, int backupcount):
        for h in self.logger.handlers:
            self.logger.removeHandler(h)

        fmt = logging.Formatter(fmt='%(asctime)s %(message)s', datefmt=datefmt)
        consolelog = logging.StreamHandler()
        consolelog.setLevel(console_level)
        consolelog.setFormatter(fmt)
        self.logger.addHandler(consolelog)
        del consolelog
        flevels = file_level.split(',')
        name = 'norecord'
        for level in flevels:
            if level == "10":
                name = "debug"
            elif level == "20":
                name = "info"
            elif level == "30":
                name = "warring"
            elif level == "40":
                name = "error"
            filelog = logging.handlers.TimedRotatingFileHandler(
                "{0:s}.{1:s}.log".format(_os.path.join(self.log_dir, file_name_prefix), name),
                when='midnight', interval=1, backupCount=backupcount, encoding='utf-8')
            # self.filelog.suffix = "%Y%m%d.log"
            filelog.setLevel(int(level))
            filelog.setFormatter(fmt)
            self.logger.addHandler(filelog)
            del filelog

    cdef _mkdirs(self):
        if not _os.path.exists(self.log_dir):
            try:
                _os.makedirs(self.log_dir)
            except Exception as e:
                print(str(e))

    cdef __del__(self):
        self.clear()

    cpdef print_handlers(self):
        print(self.logger.handlers)

    cpdef clear(self):
        if self.logger is None:
            return
        for h in self.logger.handlers:
            self.logger.removeHandler(h)
        # self.logger.shutdown()
        self.logger = None

    cpdef savelog(self, s, int l=40):
        if self.logger is None:
            return

        try:
            s = str(s).strip()
        except:
            return

        try:
            if len(s) == 0:
                return
            if l == 10:
                self.logger.debug(s)
            elif l == 20 or l == 99:
                self.logger.info(s)
            elif l == 30:
                self.logger.warning(s)
            elif l == 40:
                self.logger.error(s)
            elif l == 50:
                self.logger.critical(s)
            else:
                pass
        except Exception as ex:
            with open("mxpsu.logger.err", 'a') as f:
                f.write(ex.message + "\r\n")
            print(ex.message)


cdef class MyLogger:
    cdef str file_name_prefix, datefmt, log_dir, baseFilename
    cdef int filelog_level, consolelog_level, backupcount
    cdef object logger
    def __init__(self, str file_name_prefix, int filelog_level=20, int consolelog_level=60, str datefmt='%H:%M:%S', str logdir='', int backupcount=90):
        if logdir == "":
            self.log_dir = _os.path.join(SCRIPT_DIR, "log")
        else:
            self.log_dir = logdir
        self._mkdirs()
        self.baseFilename = "{0:s}.log".format(_os.path.join(self.log_dir, file_name_prefix))

        self.logger = logging.getLogger(file_name_prefix)
        self.logger.setLevel(logging.DEBUG)
        fmt = logging.Formatter(fmt='%(asctime)s [%(levelno)s] %(message)s', datefmt=datefmt)
        filelog = logging.handlers.TimedRotatingFileHandler(
            self.baseFilename, when='midnight', interval=1, backupCount=backupcount, encoding='utf-8')
        # self.filelog.suffix = "%Y%m%d.log"
        filelog.setLevel(filelog_level)
        filelog.setFormatter(fmt)
        consolelog = logging.StreamHandler()
        consolelog.setLevel(consolelog_level)
        consolelog.setFormatter(fmt)
        self.logger.addHandler(consolelog)
        self.logger.addHandler(filelog)


    cdef _mkdirs(self):
        if not _os.path.exists(self.log_dir):
            try:
                _os.makedirs(self.log_dir)
            except Exception as e:
                print(str(e))

    cdef __del__(self):
        self.clear()

    cpdef print_handlers(self):
        print(self.logger.handlers)

    cpdef clear(self):
        for h in self.logger.handlers:
            self.logger.removeHandler(h)
        self.logger = None

    cpdef savelog(self, s, int l=40):
        if self.logger is None:
            return

        try:
            s = str(s).strip()
        except:
            return

        try:
            if len(s) == 0:
                return
            if l == 10:
                self.logger.debug(s)
            elif l == 20 or l == 99:
                self.logger.info(s)
            elif l == 30:
                self.logger.warning(s)
            elif l == 40:
                self.logger.error(s)
            elif l == 50:
                self.logger.critical(s)
            else:
                pass
        except Exception as ex:
            with open("pymxlib.err", 'a') as f:
                f.write(ex.message + "\r\n")
            print(ex.message)


cdef class PriorityQueue:
    """Create a queue object with a given maximum size.

    If maxsize is <= 0, the queue size is infinite.
    """
    cdef int maxsize, unfinished_tasks
    cdef list queue
    cdef object mutex, not_empty, not_full, all_tasks_done
    def __init__(self, int maxsize=0):
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

    cdef task_done(self):
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
        cdef int unfinished
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

    cdef join(self):
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

    cpdef int qsize(self):
        """Return the approximate size of the queue (not reliable!)."""
        self.mutex.acquire()
        n = self._qsize()
        self.mutex.release()
        return n

    cpdef int empty(self):
        """Return True if the queue is empty, False otherwise (not reliable!)."""
        self.mutex.acquire()
        cdef int n
        if self._qsize() > 0:
            n = 0
        else:
            n = 1
        self.mutex.release()
        return n

    cpdef full(self):
        """Return True if the queue is full, False otherwise (not reliable!)."""
        self.mutex.acquire()
        cdef int n = 0 < self.maxsize == self._qsize()
        self.mutex.release()
        return n

    cdef put(self, object item, int block=1, int timeout=0):
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

    cdef put_nowait(self, tuple item):
        """Put an item into the queue without blocking.

        Only enqueue the item if a free slot is immediately available.
        Otherwise raise the Full exception.
        """
        return self.put(item, False)

    cdef get(self, int block=1, int timeout=0):
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

    cpdef get_nowait(self):
        """Remove and return an item from the queue without blocking.

        Only get an item if one is immediately available. Otherwise
        raise the Empty exception.
        """
        return self.get(False)

    # Override these methods to implement other queue organizations
    # (e.g. stack or priority queue).
    # These will only be called with appropriate locks held

    # Initialize the queue representation
    cdef _init(self, int maxsize):
        # cdef list q=[]
        self.queue = []

    cdef _qsize(self):
        return len(self.queue)

    # Put a new item in the queue
    def _put(self, tuple item):
        self.queue.insert(0, item)
        self.queue.sort(key=lambda it: it[0], reverse=True)

    # Get an item from the queue
    cdef _get(self):
        return self.queue.pop()

    cpdef put_now(self, object item, int priority=5):
        self.put_nowait((priority, item))

    cdef __del__(self):
        # del self.queue
        self.queue = []

    cpdef get_queue(self):
        return self.queu


# cdef int HEIGHT = 32
# # chars = "   ...',;:jlrixtO0KXNWMMM"
# cdef str chars = "   .........rixtO0KXNWMMM"

# cdef tuple __getsize(object image):
#     '''Calculate the target picture size
#     '''
#     cdef int s_width = image.size[0]
#     cdef int s_height = image.size[1]
#     cdef int t_height = HEIGHT
#     cdef int t_width = (t_height * s_width) / s_height
#     t_width = int(t_width * 2.3)
#     # cdef tuple t_size = (t_width, t_height)
#     return (t_width, t_height)


# cpdef str pic2ascii(str filename):
#     cdef str output = ''
#     image = _Image.open(filename)
#     cdef tuple size = __getsize(image)
#     image = image.resize(size)
#     image = image.convert('L')
#     pixs = image.load()
#     for y in range(size[1]):
#         for x in range(size[0]):
#             output += chars[pixs[x, y] / 10 - 1]
#         output += '\n'
#     return output


cpdef str get_linux_ip_address(str ifname):
    """Summary

    Args:
        ifname (TYPE): Description

    Returns:
        TYPE: Description
    """
    try:
        import fcntl

        s = _socket.socket(_socket.AF_INET, _socket.SOCK_DGRAM)
        return _socket.inet_ntoa(fcntl.ioctl(
            s.fileno(),
            0x8915,  # SIOCGIFADDR
            _struct.pack('256s', ifname[:15])
        )[20:24])
    except:
        return ''


cpdef tuple cut_string(str instring, int width):
    """Summary

    Args:
        instring (TYPE): Description
        width (TYPE): Description
        splitchar (str, optional): Description
        aslist (bool, optional): Description

    Returns:
        TYPE: Description
    """
    cdef int l  = len(instring)
    cdef list a = [instring[x:x + width] for x in range(0, l, width)]
    return tuple(a)


# cpdef str check_platform():
#     """Summary

#     Returns:
#         TYPE: Description
#     """
#     cdef str p = _platform.platform().lower()
#     if "linux" in p:
#         return "linux"
#     elif "windows-2008server" in p:
#         return "svr08"
#     elif "windows-xp" in p:
#         return "winxp"
#     else:
#         return "win7"


cpdef check_folder(str folders='log,conf', int uplevel=0):
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
    cdef str path = SCRIPT_DIR
    cdef list folder = folders.split(',')
    cdef str x
    for d in folder:
        x = _os.path.join(path, location, d)
        try:
            _os.mkdir(x)  # , mode=0775)
        except:
            pass


cpdef double time2stamp(str timestr, int tocsharp=0, str format_type='%Y-%m-%d %H:%M:%S'):
    """Summary

    Args:
        timestr (TYPE): Description
        tocsharp (bool, optional): Description
        format_type (str, optional): Description

    Returns:
        TYPE: Description
    """
    cdef double y = 621356256000000000.0
    cdef double z = 10000000.0

    try:
        if tocsharp > 0:
            return _time.mktime(_time.strptime(timestr, format_type)) * z + y
        else:
            return _time.mktime(_time.strptime(timestr, format_type))
    except Exception as ex:
        print(ex)
        return 0


cpdef str stamp2time(double stamp, int fromcsharp=0, str format_type='%Y-%m-%d %H:%M:%S'):
    """Summary

    Args:
        stamp (TYPE): Description
        fromcsharp (bool, optional): Description
        format_type (str, optional): Description

    Returns:
        TYPE: Description
    """
    cdef double y = 621356256000000000.0
    cdef double z = 10000000.0

    if fromcsharp > 0:
        return _time.strftime(format_type, _time.localtime((stamp - y) / z))
    else:
        return _time.strftime(format_type, _time.localtime(stamp))


cpdef long ip2int(str strip, int usehostorder=0):
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


cpdef str ip2string(int intip, int usehostorder=0):
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


cpdef str convert_protobuf(object pb2msg):
    """Summary

    Args:
        pb2msg (TYPE): Description

    Returns:
        TYPE: Description
    """
    cdef str a
    try:
        a = _base64.b64encode(pb2msg.SerializeToString())
    except:
        a = ""
    return a


cpdef str hex_string(str argv):
    """Summary

    Args:
        argv (TYPE): Description

    Returns:
        TYPE: Description
    """
    cdef list a = hex_list(list(argv))
    cdef list b = [hex(s).replace('0x', '') for s in a]
    return '-'.join(b)


cpdef list hex_list(list argv):
    """Summary

    Args:
        argv (TYPE): Description

    Returns:
        TYPE: Description
    """
    cdef list hhex
    try:
        hhex = [ord(hvol) for hvol in argv]
    except:
        hhex = []
    return hhex


cpdef int check_lrc(list databytes):
    """
    检查纵校验

    Args:
        databytes (TYPE): Description
    """
    cdef int l = len(databytes)
    cdef int lcr = databytes[l - 1]
    cdef list data = databytes[:l - 1]
    if lcr == lrc_vb(data):
        return 1
    else:
        return 0


cpdef int lrc_vb(list databytes):
    """
    计算纵校验

    Args:
        databytes (TYPE): Description
    """
    cdef int a = 0x00

    for d in databytes:
        a = a ^ d
    return a


cpdef int check_crc16(databytes):
    """
    检查crc

    Args:
        databytes (TYPE): Description
    """
    crc = (databytes[len(databytes) - 2], databytes[len(databytes) - 1])
    data = databytes[0:len(databytes) - 2]
    if crc == crc16_vb(data):
        return 1
    else:
        return 0


cpdef tuple crc16_vb(list databytes):
    """
    计算crc

    Args:
        databytes (TYPE): Description
    """
    cdef int crc16lo = 0xff
    cdef int crc16hi = 0xff
    cdef int cl = 0x01
    cdef int ch = 0xa0
    cdef int savehi, savelo
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


cpdef list string2bytes(str datastring, str splitchar="-"):
    """
    字符串转数字列表

    Args:
        datastring (TYPE): Description
        splitchar (str, optional): Description
    """
    cdef list s = datastring.split(splitchar)
    cdef list s2bytes = [int(b, 16) for b in s]
    return s2bytes


cpdef str bytes2string(list databytes, str splitchar="-", int noformat=1):
    """
    数字列表转字符串

    Args:
        databytes (TYPE): Description
        splitchar (str, optional): Description
        noformat (bool, optional): Description
    """
    cdef str s = ""
    if noformat:
        for d in databytes:
            s += splitchar + "{0:x}".format(int(d))
    else:
        for d in databytes:
            s += splitchar + "{0:02x}".format(int(d))
    return s[len(splitchar):]


cpdef str list2string(list datalist, str splitchar="-", int compress=0):
    """
    列表转字符串

    Args:
        datalist (TYPE): Description
        splitchar (str, optional): Description
        compress (bool, optional): Description
    """
    cdef str s = ""
    for d in datalist:
        s += splitchar + str(d)
    s = s[1:]
    # s = splitchar.join(datalist)
    if compress:
        return _base64.b64encode(_zlib.compress(s, 9))
    else:
        return s


cpdef str get_mac():
    """Summary

    Returns:
        TYPE: Description
    """
    cdef str mac = _uuid.uuid1().hex[-12:]
    cdef list x = [mac[i:i + 2] for i in range(0, len(mac), 2)]
    return ":".join(x)


cpdef str build_mac(int head=0):
    """
    生成随机mac地址
    :param head: 0-jue，1-kvm，2+-当前网卡厂商编码
    :return:

    Args:
        head (int, optional): Description
    """
    cdef str machex
    if head == 0:  # jue
        machex = "4a:75:65:"
    elif head > 0:  # kvm
        machex = "52:54:00:"
    else:  # 本地网卡厂家
        machex = get_mac()[:9]

    cdef list mac = [hex(_random.randint(0x00,0x7f)).replace('0x',''), hex(_random.randint(0x00,0xff)).replace('0x',''), hex(_random.randint(0x00,0xff)).replace('0x','')]
    # cdef list mac = [str(_uuid.uuid1())[2:4], str(_uuid.uuid1())[4:6], str(_uuid.uuid1())[6:8]]
    cdef str hw = machex+':'.join(mac)
    # cdef str hw = machex + ':'.join(map(lambda x: "%s" % x, mac))
    # hw = machex + ':'.join(map(lambda x: "%02x" % x, mac))
    return hw


cpdef long time_difference(str t1, str t2):
    """
    计算时间差，格式%Y-%m-%d %H:%M:%S
    :param t1: 起始时间
    :param t2: 结束时间

    Args:
        t1 (TYPE): Description
        t2 (TYPE): Description
    """
    cdef long x1,x2
    try:
        x1 = _time.strptime(t1, "%Y-%m-%d %H:%M:%S")
        x2 = _time.strptime(t2, "%Y-%m-%d %H:%M:%S")
    except Exception as ex:
        print(ex)
        return 0
    else:
        return long(_time.mktime(x2) - _time.mktime(x1))


cpdef str check_platform():
    p = _platform.platform().lower()
    if "linux" in p:
        return "linux"
    elif "windows-2008server" in p:
        return "svr08"
    elif "windows-xp" in p:
        return "winxp"
    else:
        return "win7"


cpdef str set_windows_style():
    s = check_platform()
    if s == "win7":
        return "windowsvista"
    elif s == "winxp":
        return "windowsxp"
    else:
        return "cleanlooks"


cpdef int check_win_process(str name):
    p = _os.popen('tasklist /FI "imagename eq {0}" /FO "csv" /NH'.format(name))
    s = p.read()
    if s.count(name) > 0:
        return 1
    else:
        return 0


cpdef tuple ip_decompose(list xips):
    """Summary

    Args:
        xip (TYPE): 要解析的地址list [x.x.x.x/y<:p>]格式

    Returns:
        TYPE: ip地址端口列表[(x.x.x.x<:p>)]
    """
    cdef list xaddr = []
    cdef str a,b,c,d,e,g,h,k,xip,p
    cdef int f,w,x,y,z
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
                k = cut_string(h, 8)
                w, x, y, z = [int(u, 2) for u in k.split('-')]
                if p == '0':
                    xaddr.append(('{0}.{1}.{2}.{3}'.format(w, x, y, z)))
                else:
                    xaddr.append(('{0}.{1}.{2}.{3}'.format(w, x, y, z), int(p)))
        else:
            xaddr.append((r.split(':')[0], int(r.split(':')[1])))
    return tuple(xaddr)


cdef class Getch:
    """Gets a single character from standard input.  Does not echo to the
screen."""
    cdef object impl
    def __init__(self):
        try:
            self.impl = GetchWindows()
        except ImportError:
            self.impl = GetchUnix()

    def __call__(self):
        return self.impl()


cdef class GetchUnix:
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


cdef class GetchWindows:
    def __init__(self):
        pass

    def __call__(self):
        try:
            import msvcrt
            return msvcrt.getch()
        except:
            pass