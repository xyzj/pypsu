#!/bin/bash

#python setup.py build_ext -if

sudo cp -vf /tmp/mxhpss.so /usr/local/lib/python2.7/site-packages/
sudo cp -vf /tmp/mxhpss.so /usr/lib/python2.7/dist-packages/
sudo cp -vf /tmp/mxhpss_comm.so /usr/local/lib/python2.7/site-packages/
sudo cp -vf /tmp/mxhpss_comm.so /usr/lib/python2.7/dist-packages/
sudo cp -vf /tmp/mxpsu.so /usr/local/lib/python2.7/site-packages/
sudo cp -vf /tmp/mxpsu.so /usr/lib/python2.7/dist-packages/

#scp mxhpss.so cos7:/tmp
#scp mxhpss_comm.so cos7:/tmp
#scp mxpsu.so cos7:/tmp

mv -f /tmp/mxhpss_nt.so ~/work/python/mwsc/