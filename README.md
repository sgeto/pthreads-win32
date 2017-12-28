[![Build Status](https://travis-ci.org/sgeto/pthreads-win32.svg?branch=privat)](https://travis-ci.org/sgeto/pthreads-win32)
[![Build status](https://ci.appveyor.com/api/projects/status/nvas416n8d4t48y0/branch/privat?svg=true)](https://ci.appveyor.com/project/sgeto/pthreads-win32/branch/privat)


Description
Also known as "pthreads-win32", POSIX Threads for Windows implements a large subset of the threads related API from the Single Unix Specification Version 3.

Conformance and quality are high priorities of this mature library. Development began in 1998 and has continued with numerous significant professional contributions.

Please note:- whilst PThreads4W can be built and run by it, MinGW64 includes it's own default POSIX Threads library called "winpthreads". The two are not compatible and in order to build and run PThreads4W (formerly PThreads-WIn32) MinGW64 must be installed without win32pthreads. If you want or need to build and run with PThreads4W then you need to choose win32 threading instead of POSIX when you install MinGW64 to not install the conflicting winpthreads include and library files.