#!/usr/bin/env python
# -*- coding: utf-8 -*-

from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import os

extensions = [
    Extension("mxpsu", ["mxpsu.pyx"],
        include_dirs = [],
        libraries = [],
        library_dirs = []),
    # Extension("mxpsu_nt", ["mxess_nt.pyx"],
    #     include_dirs = [],
    #     libraries = [],
    #     library_dirs = []),
    Extension("mxhpss_nt", ["mxhpss_nt.pyx"],
        include_dirs = [],
        libraries = [],
        library_dirs = []),
    # # Extension("_nt", ["tcsnt.pyx"],
    #     include_dirs = [],
    #     libraries = [],
    #     library_dirs = []),
]

setup(
  name = 'mxpsu_nt',
  ext_modules = cythonize(extensions),
)