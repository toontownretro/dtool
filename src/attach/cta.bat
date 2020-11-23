@echo off

REM Runs ctattach, then executes and removes the outputted script to set up the
REM environment.

for /F "tokens=* delims=\n" %%a in ('python -m ctattach %*') do echo %%a && set script=%%a

"%script%"
del /f "%script%"
