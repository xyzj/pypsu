#!/bin/bash

pysl2 setup.py build_ext -if

sudo cp -vf mxhpss.so /usr/local/lib/python2.7/site-packages/
sudo cp -vf mxhpss.so /usr/lib/python2.7/dist-packages/
sudo cp -vf mxhpss_comm.so /usr/local/lib/python2.7/site-packages/
sudo cp -vf mxhpss_comm.so /usr/lib/python2.7/dist-packages/
sudo cp -vf mxpsu.so /usr/local/lib/python2.7/site-packages/
sudo cp -vf mxpsu.so /usr/lib/python2.7/dist-packages/

scp mxhpss.so cos7:/tmp
scp mxhpss_comm.so cos7:/tmp
scp mxpsu.so cos7:/tmp