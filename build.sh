#!/bin/bash
cp -vf mxhpss.py mxhpss.pyx
cp -vf mxweb.py mxweb.pyx
cp -vf mxpsu.py mxpsu.pyx
cp -vf mxlog.py mxlog.pyx
cp -vf pbjson.py mxpbjson.pyx

python setup.py build_ext -if

#sudo cp -vf /tmp/mx*.so /usr/lib/python2.7/site-packages/
sudo cp -vf mx*.so /usr/lib64/python2.7/site-packages/
#sudo cp -vf /tmp/mxhpss_comm.so /usr/lib/python2.7/site-packages/
#sudo cp -vf /tmp/mxhpss_comm.so /usr/lib/python2.7/dist-packages/
#sudo cp -vf /tmp/mxpsu.so /usr/lib/python2.7/site-packages/
#sudo cp -vf /tmp/mxpsu.so /usr/lib/python2.7/dist-packages/
#mv -f /tmp/lic.so .
#scp mxhpss.so cos7:/tmp
#scp mxhpss_comm.so cos7:/tmp
#scp mxpsu.so cos7:/tmp

#mv -f /tmp/mxhpss_nt.so ../mwsc/
