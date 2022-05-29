@echo off
setlocal
:: Utilizzabile nello script di logon pe personalizzare
:: le stampanti dell'utente

rem sopprime std output e err output 
set $nolog= ^> nul 2^>^&1

:: Esempio se la stampante vecchia si chiama \\SRVtitan\hp laser amm
:: e la nuova \\SRVtitan\hp laserAmm
SET printServer="SRVtitan"
set oldPrinter="hp laser amm"
set newPrinter="LaserAmm"

:: verifico l'esistenza della stampante vecchia
   reg query "HKEY_CURRENT_USER\Printers\Connections\,,%printServer%,%oldPrinter%" %$nolog% && set "$Prn_exist=Y"
   If /i [%$Prn_exist%]==[y] (
       echo "%oldPrinter% presente: %$Prn_exist%"
	   echo Cancello
       RUNDLL32.EXE printui.dll,PrintUIEntry /q /dn  /n "\\%printServer%\%oldPrinter%"	  
   )
   
:: verifico l'esistenza della stampante nuova
   reg query "HKEY_CURRENT_USER\Printers\Connections\,,%printServer%,%newPrinter%" %$nolog% && set "$Prn_exist=Y" 
   If /i [%$Prn_exist%]==[y] (
       echo "Nuova stampante %newPrinter% presente"
   ) else (
	   echo "Nuova stampante %newPrinter% NON presente, installo"
       RUNDLL32.EXE printui.dll,PrintUIEntry /q /u  /in  /n "\\%printServer%\%newPrinter%"   
   )

