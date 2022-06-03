@echo off
setlocal
:: Set external source in this PDC
::
:: 
:: NTP Servers for italy 
:: ntp1.inrim.it     193.204.114.232
:: ntp2.inrim.it     193.204.114.233
:: 0.europe.pool.ntp.org
:: udp 123
:: Gastone Canali v. 0.1 marzo 2010
:: v.02 ntp.pool.org  2022
set SERVERS=0.it.pool.ntp.org 193.204.114.105 193.204.114.232  193.204.114.233
set NUM=4
:: *** test servers 
echo *** Start testing NTP servers
for /d %%S in (%SERVERS%) do  (
    (echo.|set /P = Query %%S)
	w32tm /stripchart /computer:%%S /samples:%NUM% /dataonly| find /i "error" && (echo %%S & call :_ERR %%S )||(echo. ok)

)
echo *** END  NTP servers test
echo.
:: display time difference
echo *** Dispaly time difference
for /d %%S in (%SERVERS%) do  w32tm /stripchart /computer:%%S /samples:%NUM% /dataonly
echo.
echo *** NOW: configure the Windows Time service on this PDC emulator 
:: Type the following command to configure the PDC emulator
echo Remove ECHO in the batch or cut and paste in a propmt dos
echo the following command
ECHO  w32tm /config /manualpeerlist:"%SERVERS%"   /syncfromflags:manual /reliable:yes /update 
goto :_END
:_ERR 
echo Nothing done !!! 
echo ERROR: server has problem
echo Remove the server  %1 variable from SERVERS an reRun the batch 
PAUSE
exit
:_END