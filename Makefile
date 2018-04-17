# This makefile is compatible with MS nmake
# 
# The variables $DLLDEST and $LIBDEST hold the destination directories for the
# dll and the lib, respectively. Probably all that needs to change is $DEVROOT.

# DLL_VER:
# See pthread.h and README for the description of version numbering.
DLL_VER	= 2$(EXTRAVERSION)
DLL_VERD= $(DLL_VER)d
FINDPTHREADS=contrib\FindPTHREADS-WIN32.cmake

# set this to 0 to minimize this Makefile's output during build
!IF !DEFINED(APPVEYOR)
DEBUG_BUILDING = 1
!ENDIF

!IF DEFINED(STATIC_BUILDING) || DEFINED(DEPLOY) || DEFINED(SYSINSTALL) || DEFINED(SYSUNINSTALL)
# set this to 0 to skip building static libraries
STATIC_BUILDING = 1
# for static libraries and import libraries to be able to
# coexist in $(DEST_LIB_NAME)lib,the static libraries will
# have a "lib" prefix
STATIC_LIB_PREFIX = lib
!ENDIF

CP = xcopy /Q /Y /R
MAKE = nmake /nologo
RC = rc /nologo
LIBB = lib /nologo

# Using dynamic runtime by default
RUNTIME = MD

!IF DEFINED(SYSINSTALL) || DEFINED(SYSUNINSTALL)
# These need Admin right... and quoting
DESTROOT = $(VCINSTALLDIR)
SYSROOT = $(SYSTEMROOT)\System32
DLLDEST = $(DESTROOT)bin$(MACHINE)
LIBDEST = $(DESTROOT)lib$(MACHINE)
HDRDEST = $(DESTROOT)include
!ELSE
!IF DEFINED(APPVEYOR)
DESTROOT = pthreads-w32$(APPVEYOR_BUILD_VERSION)-release
!ELSE
DESTROOT = pthreads-w32-v2.10.0-release
!ENDIF
DLLDEST = $(DESTROOT)\bin$(MACHINE)
LIBDEST = $(DESTROOT)\lib$(MACHINE)
HDRDEST = $(DESTROOT)\include
# XXX - defug?!
DATADEST = $(DESTROOT)\share\pthreads-win32\
!ENDIF

DEST_LIB_NAME = pthread.lib
STATIC_LIB_PREFIX = lib

!IF "$(PLATFORM)" == "x64"
!IF DEFINED(VS150COMNTOOLS)
MACHINE = \x64
!ELSE
MACHINE = \amd64
!ENDIF
!ENDIF

!IF DEFINED(CMAKE_MODULE_PATH)
CMAKEDEST = $(CMAKE_MODULE_PATH)
!ELSEIF DEFINED(CMAKE_MODULE_PATH) || DEFINED(DEPLOY) && !DEFINED(SYSINSTALL)
CMAKEDEST = $(DESTROOT)\share\cmake\modules
!ELSEIF DEFINED(CMAKE_MODULE_PATH) && (DEFINED(SYSINSTALL) || DEFINED(SYSUNINSTALL))
CMAKEDEST = $(CMAKE_MODULE_PATH)
!ENDIF

DLLS					= pthreadVCE$(DLL_VER).dll pthreadVSE$(DLL_VER).dll pthreadVC$(DLL_VER).dll \
						  pthreadVCE$(DLL_VERD).dll pthreadVSE$(DLL_VERD).dll pthreadVC$(DLL_VERD).dll
INLINED_STATIC_STAMPS	= pthreadVCE$(DLL_VER).inlined_static_stamp pthreadVSE$(DLL_VER).inlined_static_stamp \
						  pthreadVC$(DLL_VER).inlined_static_stamp pthreadVCE$(DLL_VERD).inlined_static_stamp \
						  pthreadVSE$(DLL_VERD).inlined_static_stamp pthreadVC$(DLL_VERD).inlined_static_stamp
SMALL_STATIC_STAMPS		= pthreadVCE$(DLL_VER).small_static_stamp pthreadVSE$(DLL_VER).small_static_stamp \
						  pthreadVC$(DLL_VER).small_static_stamp pthreadVCE$(DLL_VERD).small_static_stamp \
						  pthreadVSE$(DLL_VERD).small_static_stamp pthreadVC$(DLL_VERD).small_static_stamp

CC	= cl /nologo /MP
CPPFLAGS = /I. /FIwinconfig.h
XCFLAGS = /W3 /$(RUNTIME)
CFLAGS	= /O2 /Ob2 $(XCFLAGS)
CFLAGSD	= /Z7 $(XCFLAGS)

# Uncomment this if config.h defines RETAIN_WSALASTERROR
#XLIBS = wsock32.lib

# Default cleanup style
CLEANUP	= __CLEANUP_C

# C++ Exceptions
# (Note: If you are using Microsoft VC++6.0, the library needs to be built
# with /EHa instead of /EHs or else cancellation won't work properly.)
VCEFLAGS	= /EHs /TP $(CPPFLAGS) $(CFLAGS)
VCEFLAGSD	= /EHs /TP $(CPPFLAGS) $(CFLAGSD)
#Structured Exceptions
VSEFLAGS	= $(CPPFLAGS) $(CFLAGS)
VSEFLAGSD	= $(CPPFLAGS) $(CFLAGSD)
#C cleanup code
VCFLAGS		= $(CPPFLAGS) $(CFLAGS)
VCFLAGSD	= $(CPPFLAGS) $(CFLAGSD)

OBJEXT = obj
RESEXT = res
 
include common.mk

DLL_OBJS	= $(DLL_OBJS) $(RESOURCE_OBJS)
STATIC_OBJS	= $(STATIC_OBJS) $(RESOURCE_OBJS)

help:
	@ echo Run one of the following command lines:
	@ echo nmake clean all-tests
	@ echo nmake -DEXHAUSTIVE clean all-tests 
	@ echo nmake clean VC
	@ echo nmake clean VC-debug
	@ echo nmake clean VC-static
	@ echo nmake clean VC-static-debug
#	@ echo nmake clean VC-small-static
#	@ echo nmake clean VC-small-static-debug
	@ echo nmake clean VCE
	@ echo nmake clean VCE-debug
	@ echo nmake clean VCE-static
	@ echo nmake clean VCE-static-debug
#	@ echo nmake clean VCE-small-static
#	@ echo nmake clean VCE-small-static-debug
	@ echo nmake clean VSE
	@ echo nmake clean VSE-debug
	@ echo nmake clean VSE-static
	@ echo nmake clean VSE-static-debug
#	@ echo nmake clean VSE-small-static
#	@ echo nmake clean VSE-small-static-debug

all: realclean
	@ $(MAKE) /E clean VCE
	@ $(MAKE) /E clean VSE
	@ $(MAKE) /E clean VC
	@ $(MAKE) /E clean VCE-debug
	@ $(MAKE) /E clean VSE-debug
	@ $(MAKE) /E clean VC-debug
!IF DEFINED(STATIC_BUILDING)
	@ $(MAKE) /E clean VCE-static
	@ $(MAKE) /E clean VSE-static
	@ $(MAKE) /E clean VC-static
	@ $(MAKE) /E clean VCE-static-debug
	@ $(MAKE) /E clean VSE-static-debug
	@ $(MAKE) /E clean VC-static-debug
!ENDIF

TEST_ENV = CFLAGS="$(CFLAGS) /DNO_ERROR_DIALOGS"

all-tests:
#	$(MAKE) /E realclean VC-small-static$(XDBG)
#	cd tests && $(MAKE) /E clean VC-small-static$(XDBG) $(TEST_ENV) && $(MAKE) /E clean VCX-small-static$(XDBG) $(TEST_ENV)
#	$(MAKE) /E realclean VCE-small-static$(XDBG)
#	cd tests && $(MAKE) /E clean VCE-small-static$(XDBG) $(TEST_ENV)
#	$(MAKE) /E realclean VSE-small-static$(XDBG)
#	cd tests && $(MAKE) /E clean VSE-small-static$(XDBG) $(TEST_ENV)
	$(MAKE) /E realclean VC$(XDBG)
	cd tests && $(MAKE) /E clean VC$(XDBG) $(TEST_ENV) && $(MAKE) /E clean VCX$(XDBG) $(TEST_ENV)
	$(MAKE) /E realclean VCE$(XDBG)
	cd tests && $(MAKE) /E clean VCE$(XDBG) $(TEST_ENV)
	$(MAKE) /E realclean VSE$(XDBG)
	cd tests && $(MAKE) /E clean VSE$(XDBG) $(TEST_ENV)
#!IF DEFINED(EXHAUSTIVE)
	$(MAKE) /E realclean VC-static$(XDBG)
	cd tests && $(MAKE) /E clean VC-static$(XDBG) $(TEST_ENV) && $(MAKE) /E clean VCX-static$(XDBG) $(TEST_ENV)
	$(MAKE) /E realclean VCE-static$(XDBG)
	cd tests && $(MAKE) /E clean VCE-static$(XDBG) $(TEST_ENV)
	$(MAKE) /E realclean VSE-static$(XDBG)
	cd tests && $(MAKE) /E clean VSE-static$(XDBG) $(TEST_ENV)
#!ENDIF
	$(MAKE) realclean
	@ echo $@ completed successfully.

all-tests-cflags:
# XXX - setenv isn't a thing anymore on newer MSVC toolchains
	@ -$(SETENV)
	$(MAKE) all-tests XCFLAGS="/W3 /WX /MD /nologo"
	$(MAKE) all-tests XCFLAGS="/W3 /WX /MT /nologo"
!IF DEFINED(MORE_EXHAUSTIVE)
# MORE_EXHAUSTIVE takes a few hours to run!
	$(MAKE) all-tests XCFLAGS="/W3 /WX /MDd /nologo" XDBG="-debug"
	$(MAKE) all-tests XCFLAGS="/W3 /WX /MTd /nologo" XDBG="-debug"
!ENDIF
	@ echo $@ completed successfully.

VCE:
!IF DEFINED(DEBUG_BUILDING)
	@ echo.
	@ echo Building pthread$@...
!ENDIF
	@ $(MAKE) /E /nologo EHFLAGS="$(VCEFLAGS) /DPTW32_BUILD_INLINED" CLEANUP=__CLEANUP_CXX pthreadVCE$(DLL_VER).dll

VCE-debug:
!IF DEFINED(DEBUG_BUILDING)
	@ echo.
	@ echo Building pthread$@...
!ENDIF
	@ $(MAKE) /E /nologo EHFLAGS="$(VCEFLAGSD) /DPTW32_BUILD_INLINED" CLEANUP=__CLEANUP_CXX pthreadVCE$(DLL_VERD).dll

VSE:
!IF DEFINED(DEBUG_BUILDING)
	@ echo.
	@ echo Building pthread$@...
!ENDIF
	@ $(MAKE) /E /nologo EHFLAGS="$(VSEFLAGS) /DPTW32_BUILD_INLINED" CLEANUP=__CLEANUP_SEH pthreadVSE$(DLL_VER).dll

VSE-debug:
!IF DEFINED(DEBUG_BUILDING)
	@ echo.
	@ echo Building pthread$@...
!ENDIF
	@ $(MAKE) /E /nologo EHFLAGS="$(VSEFLAGSD) /DPTW32_BUILD_INLINED" CLEANUP=__CLEANUP_SEH pthreadVSE$(DLL_VERD).dll

VC:
!IF DEFINED(DEBUG_BUILDING)
	@ echo.
	@ echo Building pthread$@...
!ENDIF
	@ $(MAKE) /E /nologo EHFLAGS="$(VCFLAGS) /DPTW32_BUILD_INLINED" CLEANUP=__CLEANUP_C pthreadVC$(DLL_VER).dll

VC-debug:
!IF DEFINED(DEBUG_BUILDING)
	@ echo.
	@ echo Building pthread$@...
!ENDIF
	@ $(MAKE) /E /nologo EHFLAGS="$(VCFLAGSD) /DPTW32_BUILD_INLINED" CLEANUP=__CLEANUP_C pthreadVC$(DLL_VERD).dll

#
# Static builds
#
#VCE-small-static:
#	@ $(MAKE) /E /nologo EHFLAGS="$(VCEFLAGS) /DPTW32_STATIC_LIB" CLEANUP=__CLEANUP_CXX pthreadVCE$(DLL_VER).small_static_stamp

#VCE-small-static-debug:
#	@ $(MAKE) /E /nologo EHFLAGS="$(VCEFLAGSD) /DPTW32_STATIC_LIB" CLEANUP=__CLEANUP_CXX pthreadVCE$(DLL_VERD).small_static_stamp

#VSE-small-static:
#	@ $(MAKE) /E /nologo EHFLAGS="$(VSEFLAGS) /DPTW32_STATIC_LIB" CLEANUP=__CLEANUP_SEH pthreadVSE$(DLL_VER).small_static_stamp

#VSE-small-static-debug:
#	@ $(MAKE) /E /nologo EHFLAGS="$(VSEFLAGSD) /DPTW32_STATIC_LIB" CLEANUP=__CLEANUP_SEH pthreadVSE$(DLL_VERD).small_static_stamp

#VC-small-static:
#	@ $(MAKE) /E /nologo EHFLAGS="$(VCFLAGS) /DPTW32_STATIC_LIB" CLEANUP=__CLEANUP_C pthreadVC$(DLL_VER).small_static_stamp

#VC-small-static-debug:
#	@ $(MAKE) /E /nologo EHFLAGS="$(VCFLAGSD) /DPTW32_STATIC_LIB" CLEANUP=__CLEANUP_C pthreadVC$(DLL_VERD).small_static_stamp

VCE-static:
	@ $(MAKE) /E /nologo EHFLAGS="$(VCEFLAGS) /DPTW32_STATIC_LIB /DPTW32_BUILD_INLINED" CLEANUP=__CLEANUP_CXX pthreadVCE$(DLL_VER).inlined_static_stamp

VCE-static-debug:
	@ $(MAKE) /E /nologo EHFLAGS="$(VCEFLAGSD) /DPTW32_STATIC_LIB /DPTW32_BUILD_INLINED" CLEANUP=__CLEANUP_CXX pthreadVCE$(DLL_VERD).inlined_static_stamp

VSE-static:
	@ $(MAKE) /E /nologo EHFLAGS="$(VSEFLAGS) /DPTW32_STATIC_LIB /DPTW32_BUILD_INLINED" CLEANUP=__CLEANUP_SEH pthreadVSE$(DLL_VER).inlined_static_stamp

VSE-static-debug:
	@ $(MAKE) /E /nologo EHFLAGS="$(VSEFLAGSD) /DPTW32_STATIC_LIB /DPTW32_BUILD_INLINED" CLEANUP=__CLEANUP_SEH pthreadVSE$(DLL_VERD).inlined_static_stamp

VC-static:
	@ $(MAKE) /E /nologo EHFLAGS="$(VCFLAGS) /DPTW32_STATIC_LIB /DPTW32_BUILD_INLINED" CLEANUP=__CLEANUP_C pthreadVC$(DLL_VER).inlined_static_stamp

VC-static-debug:
	@ $(MAKE) /E /nologo EHFLAGS="$(VCFLAGSD) /DPTW32_STATIC_LIB /DPTW32_BUILD_INLINED" CLEANUP=__CLEANUP_C pthreadVC$(DLL_VERD).inlined_static_stamp


realclean: clean
!IF DEFINED(DEBUG_BUILDING)
	@ echo.
	@ echo Running $@...
!ENDIF
	@if exist *.dll del *.dll
	@if exist *.lib del *.lib
	@if exist *.pdb del *.pdb
	@if exist *.a del *.a
	@if exist *.manifest del *.manifest
	@if exist *_stamp del *_stamp
	@if exist make.log.txt del make.log.txt
	cd tests && $(MAKE) clean

clean:
!IF DEFINED(DEBUG_BUILDING)
	@ echo.
	@ echo Running $@...
!ENDIF
	@if exist *.obj del *.obj
	@if exist *.def del *.def
	@if exist *.ilk del *.ilk
#	if exist *.pdb del *.pdb
	@if exist *.exp del *.exp
	@if exist *.map del *.map
	@if exist *.o del *.o
	@if exist *.i del *.i
	@if exist *.res del *.res

# Very basic install. It assumes "realclean" was done just prior to build target if
# you want the installed $(DEVDEST_LIB_NAME) to match that build.
install: all
!IF DEFINED(SYSINSTALL)
!IF "$(PLATFORM)" == "x64"
	if exist pthreadV*.dll $(CP) pthreadV*.dll "$(SYSROOT)"
!ENDIF
!ELSE
	if not exist "$(DLLDEST)" mkdir "$(DLLDEST)"
	if not exist "$(LIBDEST)" mkdir "$(LIBDEST)"
	if not exist "$(HDRDEST)" mkdir "$(HDRDEST)"
!ENDIF
	if exist pthreadV*.dll $(CP) pthreadV*.dll "$(DLLDEST)"
	if exist pthreadV*.pdb $(CP) pthreadV*.pdb "$(DLLDEST)"
	if exist libpthreadV*.lib $(CP) libpthreadV*.lib "$(LIBDEST)"
	$(CP) pthreadV*.lib "$(LIBDEST)"
	$(CP) _ptw32.h "$(HDRDEST)"
	$(CP) pthread.h "$(HDRDEST)"
	$(CP) sched.h "$(HDRDEST)"
	$(CP) semaphore.h "$(HDRDEST)"
!IF DEFINED(CMAKEDEST) || DEFINED(DEPLOY)
!IF DEFINED(DEBUG_BUILDING)
	@ echo.
	@ echo Installing CMAKE Modules into $(CMAKEDEST)...
!ENDIF
# XXX - add a %pthread_root% environment variable
	if not exist "$(CMAKEDEST)" mkdir "$(CMAKEDEST)"
	$(CP) $(FINDPTHREADS) "$(CMAKEDEST)"
	copy /Y $(FINDPTHREADS) "$(CMAKEDEST)\FindPTHREADS4W.cmake"
!ENDIF
!IF DEFINED(DEPLOY)
	for %I in (COPYING COPYING.FSF README README.Borland README.CV README.NONPORTABLE README.Watcom README.WinCE WinCE-PORT) do $(CP) %I "$(DESTROOT)"
	for %I in (ANNOUNCE BUGS ChangeLog CONTRIBUTORS COPYING COPYING.FSF FAQ MAINTAINERS NEWS PROGRESS) do $(CP) %I "$(DATADEST)\doc\"
	copy /Y README.md "$(DESTROOT)\README.FIRST"
	$(CP) /E /S /I manual "$(DATADEST)\manual"
!ENDIF

uninstall:
!IF DEFINED(SYSUNINSTALL) || DEFINED(SYSINSTALL)
	del "$(SYSROOT)\pthreadV*.dll"
!ENDIF
	del "$(DLLDEST)\pthreadV*.dll"
	del "$(DLLDEST)\pthreadV*.pdb"
	del "$(LIBDEST)\libpthreadV*.lib"
	del "$(LIBDEST)\pthreadV*.lib"
	del "$(HDRDEST)\_ptw32.h"
	del "$(HDRDEST)\pthread.h"
	del "$(HDRDEST)\sched.h"
	del "$(HDRDEST)\semaphore.h"
# XXX - remove!!! %pthread_root% environment variable
	del "$(CMAKEDEST)\FindPTHREADS-WIN32.cmake"
	del "$(CMAKEDEST)\FindPTHREADS4W.cmake"
!IF DEFINED(DEPLOY)
	for %I in (ANNOUNCE BUGS ChangeLog CONTRIBUTORS COPYING COPYING.FSF FAQ MAINTAINERS NEWS PROGRESS README README.Borland README.CV README.NONPORTABLE README.Watcom README.WinCE WinCE-PORT) do del $(DESTROOT)\%I
!ENDIF

cmake:
!IF DEFINED(CMAKEDEST) || DEFINED(DEPLOY)
!IF DEFINED(DEBUG_BUILDING)
	@ echo.
	@ echo Installing CMAKE Modules into $(CMAKEDEST)...
!ENDIF
# XXX - add (and remove!!!) a %pthread_root% environment variable?
	if not exist "$(CMAKEDEST)" mkdir "$(CMAKEDEST)"
	$(CP) $(FINDPTHREADS) "$(CMAKEDEST)"
	copy /Y $(FINDPTHREADS) "$(CMAKEDEST)\FindPTHREADS4W.cmake"
!ENDIF

$(DLLS): $(DLL_OBJS)
	$(CC) /LDd /ZI /nologo $(DLL_OBJS) /link /implib:$*.lib $(XLIBS) /out:$@

$(INLINED_STATIC_STAMPS): $(DLL_OBJS)
!IF DEFINED(DEBUG_BUILDING)
	@ echo.
	@ echo Building $(STATIC_LIB_PREFIX)$@...
!ENDIF
	if exist $(STATIC_LIB_PREFIX)$*.lib del $(STATIC_LIB_PREFIX)$*.lib
	$(LIBB) $(DLL_OBJS) /out:$(STATIC_LIB_PREFIX)$*.lib
	echo. >$(STATIC_LIB_PREFIX)$@

$(SMALL_STATIC_STAMPS): $(STATIC_OBJS)
	if exist $*.lib del $*.lib
	$(LIBB) $(STATIC_OBJS) /out:$*.lib
	echo. >$@

.c.obj:
	$(CC) $(EHFLAGS) /D$(CLEANUP) -c $<

# TARGET_CPU is an environment variable set by Visual Studio Command Prompt
# as provided by the SDK (VS 2010 Express plus SDK 7.1)
# PLATFORM is an environment variable that may be set in the VS 2013 Express x64 cross
# development environment
# On my HP Compaq PC running VS 10, PLATFORM was defined as "HPD" but PROCESSOR_ARCHITECTURE
# was defined as "x86"
.rc.res:
!IF DEFINED(PLATFORM)
!  IF DEFINED(PROCESSOR_ARCHITECTURE)
	  $(RC) /dPTW32_ARCH$(PROCESSOR_ARCHITECTURE) /dPTW32_RC_MSC /d$(CLEANUP) $<
!  ELSE
	  $(RC) /dPTW32_ARCH$(PLATFORM) /dPTW32_RC_MSC /d$(CLEANUP) $<
!  ENDIF
!ELSE IF DEFINED(TARGET_CPU)
	$(RC) /dPTW32_ARCH$(TARGET_CPU) /dPTW32_RC_MSC /d$(CLEANUP) $<
!ELSE
	$(RC) /dPTW32_ARCHx86 /dPTW32_RC_MSC /d$(CLEANUP) $<
!ENDIF

.c.i:
	$(CC) /P /O2 /Ob1 $(VCFLAGS) $<
