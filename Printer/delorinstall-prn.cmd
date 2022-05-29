@echo off
setlocal

set filename=%~n0
set logfile="%userprofile%\_%filename%.txt"
set $nolog= ^> nul 2^>^&1

:: *** svuoto la variabile stampanti
set $stampanti=
set $cmdfile=installPRN.cmd
set $cmdfilefull="%temp%\%$cmdfile%"
set $APPEND_installPRN=^>^>%$cmdfilefull%
:: *** cancello il file di installazione stampanti
IF EXIST %$cmdfilefull% del %$cmdfilefull%

::-----------------------------------------------------------------------------
:: Your work - modify for your needs
::-----------------------------------------------------------------------------

REM installa la stampante fa-creaPDF e la setta di default
REM call :_installprn "SRVprint" "fa-creaPDF" "Y" 
REM call :_Deleteprn "SRVprint" "FAT-Betoniera"
call :_listAllWinPRN
REM call :_ListPRN "SRVprint"  "hp laser"
  
::-Don't modify after this----------------------------------------------------------------------------
::  ***   crea ed esegue il batch che install le stampanti   ***
:: nn e' detto : verificare folder redir
::-----------------------------------------------------------------------------
rem set $path_desktop=%USERPROFILE%\desktop
    FOR %%R IN (%$cmdfilefull%) Do IF %%~zR EQU 0 Goto :_END
    echo echo off                                          %$APPEND_installPRN%
    echo rem Esegue lo script per installre le stampanti  %$APPEND_installPRN%
    echo :: del %%0                                        %$APPEND_installPRN%
    rem *** esegue lo script  (che cancellerà e installerà le prn)
		%$cmdfilefull%
    endlocal
goto :_END

:: |--------------------------------------------------------------------------|
:: |---------------- FINE MAIN -- INIZIO PROCEDURE/FUNZIONI ------------------|
:: |--------------------------------------------------------------------------|

::  ***************************************************************************
:: * funzione elenca stampanti                                                 *
:: *  no params                                                                *
:: *  Es.:  call :_listAllWinPRN                                                 *
::  ***************************************************************************
:_listAllWinPRN
    REM *** list All win printers
    For /f "delims=, tokens=2*" %%o in ('reg query "HKEY_CURRENT_USER\Printers\Connections"') do echo %%o + %%p
    
    REM other ways 
    REM *** List ALL printer (local,win,tcp etc.)
    REM wmic printer get sharename,name,DriverName, Portname,ServerName 
    REM *** list printers if contain pdf in the name
    REM wmic printer  where "name  like '%pdf%'" get name
goto :EOF

::  ***************************************************************************
:: * funzione elenca stampanti                                                 *
:: *  first param "printer server"  second param "printer name"                                *
:: *  Es.:  call :_ListPRN "SRVprint"                                          *
:: *  Es.:  call :_ListPRN "SRVprint"                                          *
:: *  Es.:  call :_ListPRN "SRVprint"  "hp laser"                              *
::  ***************************************************************************
:_listPRN
    SET "$printer=%~2"
    SET "$prnsrv=%~1"
    
    REM List  the installed $printer shared by $prnsrv 
    For /f "delims=, tokens=2*" %%o in ('reg query "HKEY_CURRENT_USER\Printers\Connections" ^|find /i "%$prnsrv%,%$printer%"') do echo %%o + %%p
     
    REM --------- other ways, but slow ---------
    REM for /f  %%p in ('wmic printer  where ^'ServerName^="\\\\%$prnsrv%"^' get Name')  do echo %%p|find /i "%$prnsrv%"
    REM *** list network printers 
    REM for /f  %%p in ('wmic printer  where ^'ServerName like "%%%\\\\%%%"^' get Name') do echo %%p|find /i "\\"
    REM *** list network printers
    REM for /f  %%p in ('wmic printer  where ^'name  like "%%%$printer%%%"^' get name')  do echo %%p|find /i "%$printer%"
    REM *** find network printers that contains in the name $printer and server name
    REM for /f  %%p in ('wmic printer  where ^'ServerName^="\\\\%$prnsrv%" AND name  like "%%%$printer%%%"^' get Name') do echo %%p|find /i "%$prnsrv"
    REM *** find the network printer by name and server
    REM for /f  %%p in ('wmic printer  where ^'Name^="\\\\%$prnsrv%\\%$printer%"^' get Name') do echo %%p|find /i "%$printer%"
GOTO :EOF

::  ***************************************************************************
:: * funzione install stampanti                                               *
:: * Servername="printer server","nome stampante", "y" setta la prn di default *
:: *  Es.:  call :_installprn "SRVprint" "Laser Jet" "y"                      *
::  ***************************************************************************
:_installprn
rem  $ServerName , $PrinterName , $DefaultPrinter 
   set $Prn_exist=
   reg query "HKEY_CURRENT_USER\Printers\Connections\,,%~1,%~2" %$nolog% &&set $Prn_exist=Y
   If /i [%$Prn_exist%]==[y] (
       %echo% "TROVATA %2 presente: %$Prn_exist%"
   ) else (
       echo  RUNDLL32.EXE printui.dll,PrintUIEntry /q /u  /in  /n "\\%~1\%~2"        %$APPEND_installPRN%
       if /i [%3]==[y] echo RUNDLL32.EXE printui.dll,PrintUIEntry /y /n  "\\%~1\%~2" %$APPEND_installPRN%
       %echo% "Da Installare %2 non presente: %$Prn_exist%"
   ) 
goto :EOF

::  ***************************************************************************
:: *       funzione elimina stampanti                                          *
:: *       Servername="printer server","nome stampante"                        *
:: *       Es.:  call :_Deleteprn "SRVprint" "FAT-Betoniera"                *
::  ***************************************************************************
:_Deleteprn
rem  call _Deleteprn $ServerName , $PrinterName 
   set $canellaprn=
   set $Prn_exist=
   reg query "HKEY_CURRENT_USER\Printers\Connections\,,%~1,%~2" %$nolog% &&set $Prn_exist=Y
   rem se esiste la cancello
   If /i [%$Prn_exist%]==[y] echo RUNDLL32.EXE printui.dll,PrintUIEntry /q /dn  /n "\\%~1\%~2" %$APPEND_installPRN%
   %echo% _Deleteprn %1  [%$Prn_exist%]
goto :EOF

:_END