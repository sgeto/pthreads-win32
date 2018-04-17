# PThreads4W

### Build Status

[![Build Status](https://travis-ci.org/sgeto/pthreads-win32.svg?branch=privat)](https://travis-ci.org/sgeto/pthreads-win32)
[![Build status](https://ci.appveyor.com/api/projects/status/nvas416n8d4t48y0/branch/privat?svg=true)](https://ci.appveyor.com/project/sgeto/pthreads-win32/branch/privat)
### License
![License](https://img.shields.io/badge/License-LGPL%20v2.1-lightgrey.svg)


### Description

Also known as "pthreads-win32", POSIX Threads for Windows implements a large subset of the threads related API from the Single Unix Specification Version 3.

### Please note

- This is a personal GitHub mirror of: https://git.code.sf.net/p/pthreads4w/code
Actually the master branch is the mirror, while the so-called "privat" branch holds a modified fork with a few, mostly minor, changes to suite *my* environment.

"Privat" Branch: https://github.com/sgeto/pthreads-win32/tree/privat

Diff: https://github.com/sgeto/pthreads-win32/pull/1.diff

Patch: https://github.com/sgeto/pthreads-win32/pull/1.patch

- Whilst PThreads4W can be built and run by it, MinGW64 includes it's own default POSIX Threads library called "winpthreads". The two are not compatible and in order to build and run PThreads4W (formerly PThreads-WIn32) MinGW64 must be installed without win32pthreads. If you want or need to build and run with PThreads4W then you need to choose win32 threading instead of POSIX when you install MinGW64 to not install the conflicting winpthreads include and library files.

### Get PThreads4W

GitHub project [Releases section](https://github.com/sgeto/pthreads-win32/releases)

Downloads of continuous builds from [Appveyor](https://ci.appveyor.com/project/sgeto/pthreads-win32)