@echo off
setlocal

set filename=%~n0
set logfile="%userprofile%\_%filename%.txt"
set $nolog= ^> nul 2^>^&1

:: *** svuoto la variabile stampanti
set $stampanti=
set $cmdfile=installaPRN.cmd
set $cmdfilefull="%temp%\%$cmdfile%"
set $APPEND_installaPRN=^>^>%$cmdfilefull%
:: *** cancello il file di installazione stampanti
IF EXIST %$cmdfilefull% del %$cmdfilefull%

REM call :_installaprn "SRVprint" "fa-creaPDF" "n" 
REM call :_cancellaprn "SRVprint" "FAT-Betoniera"

  
::_____________________________________________________________________________
::_____________________________________________________________________________
::  ***   crea ed esegue il batch che installa le stampanti   ***
:: nn e' detto : verificare folder redir
::-----------------------------------------------------------------------------
rem set $path_desktop=%USERPROFILE%\desktop
    FOR %%R IN (%$cmdfilefull%) Do IF %%~zR EQU 0 Goto :_END
    echo echo off                                          %$APPEND_installaPRN%
    echo rem Esegue lo script per installare le stampanti  %$APPEND_installaPRN%
    echo :: del %%0                                        %$APPEND_installaPRN%
    rem *** esegue lo script  (che cancellerà e installerà le prn)
		%$cmdfilefull%
    endlocal
goto :_END
:: |--------------------------------------------------------------------------|
:: |---------------- FINE MAIN -- INIZIO PROCEDURE/FUNZIONI ------------------|
:: |--------------------------------------------------------------------------|

::  ***************************************************************************
:: * funzione installa stampanti                                               *
:: * Servername="printer server","nome stampante", "y" setta la prn di default *
:: *  Es.:  call :_installaprn "SRVprint" "Laser Jet" "y"                      *
::  ***************************************************************************
rem wmic printer  where "name  like '%pdf'" get name
rem wmic printer get sharename,name,DriverName, Portname
:_installaprn
rem  $ServerName , $PrinterName , $DefaultPrinter 
   set $Prn_exist=
   reg query "HKEY_CURRENT_USER\Printers\Connections\,,%~1,%~2" %$nolog% &&set $Prn_exist=Y
   If /i [%$Prn_exist%]==[y] (
       %echo% "TROVATA %2 presente: %$Prn_exist%"
   ) else (
       echo  RUNDLL32.EXE printui.dll,PrintUIEntry /q /u  /in  /n "\\%~1\%~2"        %$APPEND_installaPRN%
       if /i [%3]==[y] echo RUNDLL32.EXE printui.dll,PrintUIEntry /y /n  "\\%~1\%~2" %$APPEND_installaPRN%
       %echo% "Da Installare %2 non presente: %$Prn_exist%"
   ) 
goto :EOF


::  ***************************************************************************
:: *       funzione elimina stampanti                                          *
:: *       Servername="printer server","nome stampante"                        *
:: *       Es.:  call :_cancellaprn "SRVprint" "FAT-Betoniera"                *
::  ***************************************************************************
:_cancellaprn
rem  call _cancellaprn $ServerName , $PrinterName 
   set $canellaprn=
   set $Prn_exist=
   reg query "HKEY_CURRENT_USER\Printers\Connections\,,%~1,%~2" %$nolog% &&set $Prn_exist=Y
   rem se esiste la cancello
   If /i [%$Prn_exist%]==[y] echo RUNDLL32.EXE printui.dll,PrintUIEntry /q /dn  /n "\\%~1\%~2" %$APPEND_installaPRN%
   %echo% _cancellaprn %1  [%$Prn_exist%]
goto :EOF

:_END