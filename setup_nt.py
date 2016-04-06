#!/usr/bin/env python
# -*- coding: utf-8 -*-

from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import os

extensions = [
    Extension("mxpsu",
              ["mxpsu.pyx"],
              include_dirs=[],
              libraries=[],
              library_dirs=[]),
    # Extension("mxpsu_nt", ["mxess_nt.pyx"],
    #     include_dirs = [],
    #     libraries = [],
    #     library_dirs = []),
    Extension("mxhpss_comm",
              ["mxhpss_comm.pyx"],
              include_dirs=[],
              libraries=[],
              library_dirs=[]),
    Extension("mxhpss",
              ["mxhpss.pyx"],
              include_dirs=[],
              libraries=[],
              library_dirs=[]),
    Extension("mxsp_nt",
              ["mxsp_nt.pyx"],
              include_dirs=[],
              libraries=[],
              library_dirs=[]),
]

setup(name='mxpsu', ext_modules=cythonize(extensions), )
