@ECHO off
SETLOCAL 
::
:: By Gastone Canali
:: v.02 28.01.2012 windows 2000/xp/vista/7/8 with or without robocopy
:: 
:: v.04 2022 windows 10 or 11
::
title=UpToDate-sysinternals.cmd
set filename=%~n0
set logfile="%temp%\_%filename%.txt"
set null=  ^>nul 2^>^&1
set log=^>^>%logfile% 2^>^&1
:: if you want the output remove the comment 
rem set log=

mkdir c:\temp     %null%
mkdir c:\temp\sys %null%
pushd c:\temp\sys %null% || exit
pause

::SET path=c:\path\ToRobocopy;%path%
SET SysIntUrl=https://live.sysinternals.com/tools
SET SysIntFolder=c:\temp\sys

rem call :_NoRobocopy

PushD %SysIntFolder% || goto :_SYSFOLDERERR

for /f "tokens=2 delims= " %%D in ('net use * %SysIntUrl% /persistent:no^|find /i ":"') do call :_setvar SysIntDrive %%D
   if not exist "%SysIntDrive%" goto :_SysIntShareERR
       robocopy . . .?.?.? /w:0 /r:0 >nul 2>nul && (
	   echo Running with robocopy - wait...
       robocopy "%SysIntDrive%"  "%SysIntFolder%" /w:1 /r:1 /np /xf Thumbs.db %log%
	   net use %SysIntDrive% /del
       ) || ( goto :_NoRobocopy )
goto :EOF


:_NoRobocopy
echo Running without robocopy - wait...
 FOR /f "tokens=2 delims= " %%D in ('net use * %SysIntUrl% /persistent:no^|find /i ":"') do call :_setvar SysIntDrive %%D
 FOR /F "skip=7 tokens=4,*"  %%F in ('dir /A-D  "%SysIntDrive%" ^|sort') DO (
     IF exist "%%F" (
       echo %%F Exist chk date
       FOR /F "skip=7 tokens=*" %%R in ('dir /A-D  "%SysIntDrive%\%%F" ^|sort') DO (
          FOR /F "skip=7 tokens=*" %%L in ('dir /A-D  "%SysIntFolder%\%%F" ^|sort') DO (
             echo %%R|find /i "%%L" || echo Local %%F is older  & xcopy "%SysIntDrive%\%%F" "%SysIntFolder%\%%F" /y /c /r /q 
          )
       ) 
     ) ELSE (  echo %%F not present & xcopy "%SysIntDrive%\%%F" . /y /c /r /q )   
   )%log%
net use %SysIntDrive% /del
goto :EOF

:_setvar
  call set %1=%2
goto :EOF

:_SYSFOLDERERR
    echo ERROR:%SysIntFolder% Not Found
goto :EOF

:_SysIntShareERR
    echo ERROR:%SysIntShare%   Not Found 
goto :EOF