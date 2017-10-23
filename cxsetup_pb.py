#!/usr/bin/env pysl2
# -*- coding: utf-8 -*-

__author__ = 'minamoto'
__ver__ = '0.1'
__doc__ = 'cxsetup_tcs_sl.py'

import sys
import os
import time
from cx_Freeze import setup, Executable
import compileall

compileall.compile_dir('.')

dist_name = 'pb'
dist_base = None

try:
    exepath = os.path.join('/', 'home', os.getlogin(), 'Downloads', 'planb', 'bin')
except:
    exepath = os.path.join(os.path.expanduser('~'), 'Downloads', 'planb', 'bin')

# Dependencies are automatically detected, but it might need
# fine tuning.
buildOptions = dict(
    optimize=2,
    build_exe=exepath,
    create_shared_zip=False,
    append_script_to_exe=True,
    include_msvcr=False,
    includes=['mxpsu',
              'mxhpss',
              'mxhpss_comm',
              'json',
              'uuid',
              'greenlet',
              'platform',
              'logging.handlers',
              'Crypto.Hash.MD5',
              'Crypto.Cipher.AES', ],
    excludes=['gevent', 'unittest', '_codecs_hk', '_codecs_jp', '_codecs_tw', '_codecs_kr'],
    include_files=[(r'./OURHISTORY', 'OURHISTORY'),
                   (r'./.LICENSE', '.LICENSE'),
                   (r'/usr/lib64/python2.7/site-packages/gevent', 'gevent'), ])

executables = [Executable('pyplanb.py', base=dist_base, targetName=dist_name, compress=True)]

setup(
    name=dist_name,
    version='{0}.{1}.{2}'.format(time.localtime()[0], time.localtime()[1], time.localtime()[2])[2:],
    description='Terminal Communication Services',
    options=dict(build_exe=buildOptions),
    executables=executables)

# if not os.path.isdir('/etc/dclms'):
#     os.system('sudo mkdir /etc/dclms -p -m 775')
# if not os.path.isdir('/usr/local/lib/python2.7/site-packages/'):
#     os.system('sudo mkdir /usr/local/lib/python2.7/site-packages/ -p -m 775')
# os.system('mkdir /opt/libs/dpv4')
# os.system('mkdir /opt/libs/protobuf2')
# os.system('cp -f dpv4/*.pyc /opt/libs/dpv4/')
# os.system('cp -f tcs_config.py /etc/dclms/')
# os.system('cp -f tcs_config.py {0}'.format(os.path.join('.', buildOptions['build_exe'])))
os.system('chmod a-x {0}'.format(os.path.join('.', buildOptions['build_exe'], '*.so')))
os.system('chmod a-x {0}'.format(os.path.join('.', buildOptions['build_exe'], 'OURHISTORY')))
os.system('chmod a-x {0}'.format(os.path.join('.', buildOptions['build_exe'], 'LICENSE')))
os.system('chmod o-w {0}'.format(os.path.join('.', buildOptions['build_exe'])))
os.system('chmod o-w {0}'.format(os.path.join('.', buildOptions['build_exe'], '..')))
os.system('rm -fv {0}'.format(os.path.join('.', buildOptions['build_exe'], 'gevent', '*.py')))
# os.system('./update_tcs_mod.sh')
# os.system('rm -f {0}'.format(os.path.join('.', buildOptions['build_exe'], 'gevent', '*.py')))

# os.remove(os.path.join('.', buildOptions['build_exe'], 'gevent', '*.py'))
