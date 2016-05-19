#!/bin/bash

rm -rf build dist
pyinstaller planb.spec
cp -f .LICENSE dist/
cp -f OURHISTORY dist/