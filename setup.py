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
    Extension("mxpsu_nt", ["mxpsu_nt.pyx"],
        include_dirs = [],
        libraries = [],
        library_dirs = []),
    # Everything but primes.pyx is included here.
    Extension("mxlic", ["mxlic.pyx"],
        include_dirs = [],
        libraries = [],
        library_dirs = []),
    Extension("mxess", ["mxess.pyx"],
        include_dirs = [],
        libraries = [],
        library_dirs = []),
]

setup(
  name = 'mxpsu',
  ext_modules = cythonize(extensions),
)