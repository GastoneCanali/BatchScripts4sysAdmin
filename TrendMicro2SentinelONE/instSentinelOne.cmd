@echo off
:: Startup script - 
:: remove TrendMicro WorryFree
:: and install SentinelONE
setlocal

SET scriptpath=%~dp0
if not exist c:\temp mkdir c:\temp
Set LOGfile=%temp%\_seonelog.log

echo -%computername%-%date%-%time%- >>%LOGfile%

:: Critical point: don't ask me why you don't find the file ....
Set "GlobalLog=\\Server01\log$\SeOneLog.csv"
if exist C:\Windows\System32\drivers\SentinelOne\ELAM\SentinelELAM.sys goto :_installed


set msi=SentinelInstaller_windows_64bit_v21_7_5_1080.msi
set SenOneFullPath=%scriptpath%%msi%
set LocalLOG="%temp%\_seOneLlog.log"
set startinstall=%time%


Set SeOne_installed=SeOneInstalling
start /wait "Sentinel One" msiexec /i %SenOneFullPath% /q /norestart    /L*V %LocalLOG%  UI=false SITE_TOKEN=frr32mfmvkfFER5O==

timeout 4

:_installed
Set SeOne_installed=SeOne_installed
(tasklist| find /i "sentinelagent.exe")||  goto :_errSeOne
set SeOne_active=SeOne_active
REM trendmicro running?
(tasklist| find /i "PccNTMon")|| goto :_OK
set TM_active=Tm_active

:_removeTM
    REM https://marconuijens.com/2013/02/28/silent-uninstall-of-password-protected-trendmicro-antivirus/
    set TM_removed=TryToRemoveTM
    REM SentineOne active then remove TrendMicro
    pushD "C:\Program Files (x86)\Trend Micro\Security Agent\NTRmv.exe\.." || goto :_NO_NTRmv
    pushD "C:\Program Files (x86)" 
	rem strPara1 = "-980223"
    rem strPara2 = "-331"
	start /wait "remove TM" "C:\Program Files (x86)\Trend Micro\Security Agent\NTRmv.exe" -980223
   rem -331
    (tasklist| find /i "PccNTMon") || set TM_active=Tm_Not_Active && set TM_removed=No_TM_still_active

goto :_OK

:_NO_NTRmv
echo something went wrong with trendMicro
Set "TM_error=No trend micro"
goto :_OK

:_errSeOne
Set "SeOne_error=SeOne not active"

goto :_OK

:_OK
echo "%computername%;%date%;%startinstall%;%time%;%SeOne_installed%;%TM_removed%;%TM_active%;%SeOne_active%">> %GlobalLog%

