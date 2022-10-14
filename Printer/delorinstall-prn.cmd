@echo off
:: 
::  List or Delete or install Windows printers
::  You can use this in a user logon script
::  to automate printers operation
::
::  Set the default user printer, delete old printrs or install the new one
:: OS supported: from windows 2000 to windows 11
::
:: info about printui, try:  RUNDLL32.EXE printui.dll,PrintUIEntry /?
setlocal

set filename=%~n0
set logfile="%userprofile%\_%filename%.txt"
set $nolog= ^> nul 2^>^&1

:: *** init variabile printers
set $printers=
set $cmdfile=installPRN.cmd
set $cmdfilefull="%temp%\%$cmdfile%"
set $APPEND_installPRN=^>^>%$cmdfilefull%
:: *** delete the install/delete batch file (will be created accordingly )  
IF EXIST %$cmdfilefull% del %$cmdfilefull%



::-----------------------------------------------------------------------------
:: MAIN - Your work - modify for your needs
::-----------------------------------------------------------------------------

::  Turn Off "Let Windows 10 Manage Default Printer"  
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" /v "LegacyDefaultPrinterMode" /t REG_DWORD /d "1" /f

REM install the printer fa-creaPDF and force as default
REM call :_installprn "SRVprint" "fa-creaPDF" "Y" 
REM delete windows network printer "LaserFAT-Betoniera" 
REM call :_Deleteprn "SRVprint" "LaserFAT-Betoniera"
call :_listAllWinPRN
REM call :_ListPRN "SRVprint"  "hp laser"

::-----------------------------------------------------------------------------
:: END MAIN - Your work finish here
::-----------------------------------------------------------------------------


  
::-Don't modify after this----------------------------------------------------------------------------
::  ***   Batch Creation and execution     ***
:: pay attentio if tou have folder redir
::----------------------------------------------------------------------------------------------------
rem set $path_desktop=%USERPROFILE%\desktop
    FOR %%R IN (%$cmdfilefull%) Do IF %%~zR EQU 0 Goto :_END
    echo echo off                                          %$APPEND_installPRN%
    echo rem Starting the genetated script                 %$APPEND_installPRN%
    echo :: del %%0                                        %$APPEND_installPRN%
    rem *** run the script  (delete one or more printers or install one or more printers )
		%$cmdfilefull%
    endlocal
goto :_END

:: |--------------------------------------------------------------------------|
:: |----------------------- INIZIO PROCEDURE/FUNZIONI ------------------------|
:: |--------------------------------------------------------------------------|

::  ***************************************************************************
:: *  Function list printers                                                   *
:: *  no params                                                                *
:: *  Es.:  call :_listAllWinPRN                                               *
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
:: * Function list printer                                                     *
:: *  first param "printer server"  second param "printer name"                *
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
:: *  function install printers                                                 *
:: *  Servername="printer server","nome stampante", "y" setta la prn di default *
:: *  Es.:  call :_installprn "SRVprint" "Laser Jet" "y"                        *
::  ***************************************************************************
:_installprn
rem  $ServerName , $PrinterName , $DefaultPrinter 
   set $Prn_exist=
   reg query "HKEY_CURRENT_USER\Printers\Connections\,,%~1,%~2" %$nolog% &&set $Prn_exist=Y
   If /i [%$Prn_exist%]==[y] (
       %echo% "Found %2 : %$Prn_exist%"
   ) else (
       echo  RUNDLL32.EXE printui.dll,PrintUIEntry /q /u  /in  /n "\\%~1\%~2"        %$APPEND_installPRN%
       if /i [%3]==[y] echo RUNDLL32.EXE printui.dll,PrintUIEntry /y /n  "\\%~1\%~2" %$APPEND_installPRN%
       %echo% "To beInstalled %2 not present: %$Prn_exist%"
   ) 
goto :EOF

::  ***************************************************************************
:: *       Function delete printer                                             *
:: *       Servername="printer server","nome stampante"                        *
:: *       Es.:  call :_Deleteprn "SRVprint" "FAT-Betoniera"                   *
::  ***************************************************************************
:_Deleteprn
rem  call _Deleteprn $ServerName , $PrinterName 
   set $canellaprn=
   set $Prn_exist=
   reg query "HKEY_CURRENT_USER\Printers\Connections\,,%~1,%~2" %$nolog% &&set $Prn_exist=Y
   rem Delete if exist
   If /i [%$Prn_exist%]==[y] echo RUNDLL32.EXE printui.dll,PrintUIEntry /q /dn  /n "\\%~1\%~2" %$APPEND_installPRN%
   %echo% _Deleteprn %1  [%$Prn_exist%]
goto :EOF

:_END
