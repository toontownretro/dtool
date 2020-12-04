@echo off

if "%HOME%" == "" (
  set HOME=%USERPROFILE%
)

if "%PLAYER%" == "" (
  set PLAYER=%USERPROFILE%\player
)

if "%PPREMAKE_CONFIG%" == "" (
  set PPREMAKE_CONFIG=%PLAYER%\Config.pp
)

if "%CTDEFAULT_FLAV%" == "" (
  set CTDEFAULT_FLAV=default
)

if "%CTVSPEC_PATH%" == "" (
  set CTVSPEC_PATH=%PLAYER%\vspec
)

if "%PENV%" == "" (
  set PENV=WIN32
)

if "%DTOOL%" == "" (
  set DTOOL=%PLAYER%\dtool
)

if exist "%DTOOL%\built\etc" (
  REM Use the installed ctattach if we are already built.
  set cttools_path=%DTOOL%\built\bin
) else (
  REM If we're not already built, use the ctattach from the source tree.
  set cttools_path=%DTOOL%\src\attach
  set PATH="%cttools_path%;%PATH%"
)

set SETUP_SCRIPT=

if "%1" == "" (
  for /F "tokens=* delims=\n" %%a in ('%cttools_path%\ctattach.py dtool default') do echo %%a && set SETUP_SCRIPT=%%a
) else (
  for /F "tokens=* delims=\n" %%a in ('%cttools_path%\ctattach.py dtool %1') do echo %%a && set SETUP_SCRIPT=%%a
)

if "%SETUP_SCRIPT%" == "" (
  echo error: ctattach.py returned NULL string for setup_script filename!
  echo        'dtool/built/bin/ctattach.py' probably doesn't exist, need to make install on dtool to copy it from dtool/src/attach
)

call %SETUP_SCRIPT%
