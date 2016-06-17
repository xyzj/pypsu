#!/usr/bin/env python
# -*- coding: utf-8 -*-

from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

extensions = [
    Extension("mxpsu", ["mxpsu.pyx"],
        include_dirs = [],
        libraries = [],
        library_dirs = []),
    Extension("lic", ["lic.pyx"],
        include_dirs = [],
        libraries = [],
        library_dirs = []),
    Extension("mxhpss_comm", ["mxhpss_comm.pyx"],
        include_dirs = [],
        libraries = [],
        library_dirs = []),
    Extension("mxhpss", ["mxhpss.pyx"],
        include_dirs = [],
        libraries = [],
        library_dirs = []),
    Extension("mxlog", ["mxlog.pyx"],
        include_dirs = [],
        libraries = [],
        library_dirs = []),
    # Extension("mxsp", ["mxsp.pyx"],
    #     include_dirs = [],
    #     libraries = [],
    #     library_dirs = []),
]

setup(
  name = 'mxpsu',
  ext_modules = cythonize(extensions),
)
