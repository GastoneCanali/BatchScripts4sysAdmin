@echo off
::
::set time and date variables
:: TT, DD, DDTT , DDTTSS , secondi=SS, centesimi=CC
:: giorno=_GG mese=_MM anno=_AA ore=_O minuti=_M
:: DD=data rovesciata separata da _ 2004_12_31
:: TT=ora separata da _ 10_15
:: AMGOM=AnnoMeseGiornoOreMinuti es. AMGOM=200505090956
:: 22/06/2013 12.55.11,88
:: H_sep
goto :_init
:_start
set "debugging=on"

   ::data rovesciata e separata da _ 2005_12_28
   for /f "Tokens=1-4 Delims=%D_sep% " %%i in ('date /t')       do (  
      set  DD=%%k_%%j_%%i
      set _GG=%%i
      set _MM=%%j
      set _AA=%%k
   )

   ::ora separata da _ 13_50
   for /f "Tokens=1-4 Delims=%H_sep% " %%i in ('time /t') do (
      set  TT=%%i_%%j
      set  _O=%%i
      set  _M=%%j
   )

   ::seconds
   for /F "Tokens=4 Delims=%H_sep%" %%i in ('echo. ^|time^|find ","') do (
	   for /f "Tokens=1,2 Delims=%cent_Sep%" %%a in ('echo %%i') do (
		  set _SS=%%a
	      set _CC=%%b
       )
   )   

:: data e ora
   set DDTT=%DD%-%TT%
   set DDTTSS=%DD%-%TT%_%_SS%
::
   set AMGOM=%_AA%%_MM%%_GG%%_O%%_M%
   set AMG=%_AA%%_MM%%_GG%
   echo on
if /i +%debugging%+==+on+ goto  :_DTdebug
goto :_DTend
	
:_init
Rem init variables
for /f "tokens=1,2,3,4 delims= " %%s in ('reg query "HKEY_CURRENT_USER\Control Panel\International" /v sdate ^|find  "REG_SZ"') do  call :_setvar D_sep %%u
for /f "tokens=1,2,3,4 delims= " %%s in ('reg query "HKEY_CURRENT_USER\Control Panel\International" /v stime ^|find  "REG_SZ"') do  call :_setvar H_sep %%u
set cent_Sep=,
set  DD=
set _GG=
set _MM=
set _AA=
set  TT=
set  _O=
set  _M=
set _CC=
set _SS=
set AMGOM=
set AMG=
goto :_start

:_setvar
  call set %1=%2
goto :EOF

:_DTdebug
echo off
::debug
echo H_sep  =%H_sep%+
echo H_sep  =%D_sep%+
echo time   =%TT%+
echo data   =%DD%+
echo seco   =%_SS%+
echo cent   =%_CC%+
echo giorno =%_GG%+
echo mese   =%_MM%+
echo anno   =%_AA%+
echo ore    =%_O%+
echo minuti =%_M%+
echo AMGOM  =%AMGOM%+
:_DTend 