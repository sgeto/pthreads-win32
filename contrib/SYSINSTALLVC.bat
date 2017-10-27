:: Quick and dirty script to install pthreads-win32 to "%VSINSTALLDIR%VC\"
:: and DLLs additionally to "%SYSTEMROOT%\System32\"
::
:: - quite personal (adjust to your needs)
:: - favors x64 systems (should work on x86)
:: - needs admin rights (obviously)

@echo off
setlocal

set THISAPP=pthreads-win32
for /f "tokens=* usebackq" %%F in (`git describe`) do (set GITVERSION=%%F)
REM set GITVERSION=%THISAPP% %%G

set BUILDDIR=..\..\
set UNIQUEFILE=pthread.h
set NMAKE=nmake /NOLOGO /G /ERRORREPORT:NONE 
set VSVERSION=14.0
set VCVARSALL="C:\Program Files (x86)\Microsoft Visual Studio %VSVERSION%\VC\vcvarsall.bat"
set CMAKEDEST=CMAKEDEST=C:\tools\cmake-3.8.2-win64-x64\share\cmake-3.8\Modules

:: possible choices are x86 | amd64 | arm | x86_amd64 | x86_arm | amd64_x86 | amd64_arm
set MACHINE=x86 x86_amd64

:: checking supplied options
@if "%1"=="clean" goto :CLEAN
@if "%1"=="noinstall" goto :BUILD
@if "%1"=="uninstall" goto :UNINSTALL
@if not "%1"=="NOSYS" (
    set SYSINSTALL=SYSINSTALL=true
    shift)
@if not "%1"=="" @if not "%1"=="clean" @if not "%1"=="uninstall" @if not "%1"=="noinstall" goto :USAGE
@if errorlevel 1 goto :BAD

:BUILD
@if not exist %UNIQUEFILE% (
    @cd %BUILDDIR%
    @if not exist %UNIQUEFILE% goto :BAD)

@for %%i in (%MACHINE%) do (
    @echo Building %THISAPP% for %%i
    @echo ===============================
    @echo.
    @echo Version                = %GITVERSION%
    @echo vcvarsall.bat          = %VCVARSALL% %%i
    @echo NMake                  = %NMAKE%%SYSINSTALL%
    @echo Source Directory       = %CD%
    @echo Install Directory      = "%VSINSTALLDIR%VC\"
    @echo DLL Install Directory  = "%SYSTEMROOT%\System32\"
    @echo.
    %VCVARSALL% %%i
    %NMAKE% /nologo install %SYSINSTALL% %CMAKEDEST%)
if errorlevel 1 goto :BAD
if errorlevel 0 goto :SUCCESS

:UNINSTALL
@color
@echo.
@echo Uninstalling all generated files...
%NMAKE% uninstall SYSUNINSTALL=true %CMAKEDEST%
%NMAKE% uninstall SYSUNINSTALL=true %CMAKEDEST% MACHINE=\amd64
if errorlevel 1 goto :BAD
@echo.
@echo Done.
@pause
@goto :eof

:CLEAN
@color
@echo.
@echo Deleting all generated files...
%NMAKE% realclean
@echo.
if errorlevel 1 goto :BAD
@echo.
@echo Done.
@pause
@goto :eof

:USAGE
@echo.
@echo Invalid option "%*"
@echo.
@echo Usage: %~nx0 [clean] ^| [uninstall] ^| [noinstall] ^| [nosys]
@echo Execute this file without options to build and install %THISAPP%
@echo to your compiler search path [%VSINSTALLDIR%VC\]
@goto :eof

:BAD
@color 4f
@echo.
@echo *******************************************************
@echo *   BUILD FAILED -- Please check the error messages   *
@echo *******************************************************
@echo.
@echo.
@echo _________________________________ NOTICE _________________________________
@echo This batch file is provided "as is". 
@echo See README.md for more information.
@echo __________________________________________________________________________
@echo.
@title BUILD FAILED
@goto :eof

:SUCCESS
@echo.
@echo ==================================================================
@echo =         Successfully built libnet-%THISAPP% for Windows %MACHINE%          =
@echo ==================================================================
@echo.
pause
@goto :eof