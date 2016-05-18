#!/usr/bin/env python
# -*- coding: utf-8 -*-
import argparse as _argparse
import os as _os
import sys as _sys
from mxhpss import MXIOLoop

__author__ = 'minamoto'
__ver__ = '0.9'
__doc__ = u'''[Unit]
Description=planb
After=network.target

[Service]
PIDFile=/run/pb.pid
KillMode=process
ExecStart=/usr/bin/pb
PrivateTmp=True
Type=oneshot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
'''


def start_planb(results):
    ss = MXIOLoop(19, 10)
    ss.setDebug(results.debug)
    ss.addSocket(('0.0.0.0', results.serviceport))
    ss.serverForever()


def create_daemon(results):
    try:
        if _os.fork() > 0:
            _os._exit(0)
    except OSError, error:
        print 'fork #1 failed: %d (%s)' % (error.errno, error.strerror)
        _os._exit(1)
    # _os.chdir('/')
    _os.setsid()
    _os.umask(0)
    try:
        pid = _os.fork()
        if pid > 0:
            print 'Daemon PID %d' % pid
            _os._exit(0)
    except OSError, error:
        print 'fork #2 failed: %d (%s)' % (error.errno, error.strerror)
        _os._exit(1)
    # 重定向标准IO
    _sys.stdout.flush()
    _sys.stderr.flush()
    si = file("/dev/null", 'r')
    so = file("/dev/null", 'a+')
    se = file("/dev/null", 'a+', 0)
    _os.dup2(si.fileno(), _sys.stdin.fileno())
    _os.dup2(so.fileno(), _sys.stdout.fileno())
    _os.dup2(se.fileno(), _sys.stderr.fileno())

    # 在子进程中执行代码
    start_planb(results)


if __name__ == "__main__":
    if "--history" in _sys.argv:
        mx.showOurHistory()
        _sys.argv.remove('--history')
        raw_input('press any key to continue.')

    parser_required = _argparse.ArgumentParser(add_help=False)

    group = parser_required.add_argument_group('requied arguments')
    group.add_argument('--port',
                       action='store',
                       dest='serviceport',
                       type=int,
                       default=2014,
                       help='Set service listening port.')

    group.add_argument('--no-daemon',
                       action='store_true',
                       dest='nodaemon',
                       default=False,
                       help='''Run as daemon. Default=False''')

    group.add_argument('--debug',
                       action='store_true',
                       dest='debug',
                       default=False,
                       help='''Show debug info. Default=False''')

    arg = _argparse.ArgumentParser(parents=[parser_required])

    arg.add_argument('--version',
                     action='version',
                     version=u'{0} v{1}, code by {2}'.format(__doc__, __ver__, __author__))

    results = arg.parse_args()

    if results.nodaemon:
        start_planb(results)
    else:
        create_daemon(results)
