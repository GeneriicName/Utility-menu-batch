@echo off
title your title here
:mainloop
setlocal DisableDelayedExpansion
cls
set "delu="
set "pc="
set "choice="
echo Choose from the following & echo: & echo 1. Reset Print Spooler & echo 2. Clear space from C & echo 3. Fix IE & echo 4. Fix cockpit printer & echo 5. Fix 3 languages bug & echo 6. Get all network printers from remote PC & echo 7. Translate TCP/IP printer address to path in print server & echo 8. Delete Users folders on remote PC& echo 9. Exit & echo:
set /p "choice=" 
echo:
if "%choice%"=="" (
   goto mainloop
)
if %choice%==1 (
   goto spooler
)
if %choice%==2 (
   goto space
)
if %choice%==3 (
   goto IE
)
if %choice% == 4 (
   goto cockpit
)
if %choice% == 5 (
   goto lang
)
if %choice% == 6 (
   goto prnt
)
if %choice% == 7 (
   goto tcpip
)
if %choice% == 8 (
   goto clearusers
)
if %choice%==9 (
   exit
) else (
   echo Invalid option, please, try again 
   pause
   goto mainloop
)

:spooler 
set /p "pc=Enter pc: " 
if exist \\%pc%\c$ (
   (SC \\%pc% STOP Spooler) > nul 2> nul
   (SC \\%pc% START Spooler) > nul 2> nul
   echo Succesfullly restarted the spooler at %pc%
) else (
   echo No such computer %pc% or it is unavailable at this time
)
pause
goto mainloop

:space
setlocal enabledelayedexpansion

set /p "pc=Type the PC or IP address: "

if exist \\%pc%\c$ (
   for /f "tokens=2 delims=[]" %%a in ('ping -4 -n 1 !pc! ^| findstr "["') do set ip_address=%%a
   set "ip_address=!ip_address!"
   for /f "tokens=2" %%S in ('wmic /node:!ip_address! volume get DriveLetter^, FreeSpace ^| findstr "^C:"') do set space=%%S
   set /A "org=!space:~0,-6! / (1074)"
   (taskkill /s %pc% /im SearchIndexer.exe /f) 2> nul > nul && (del /s /q /f  "\\%pc%\c$\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb")  2> nul > nul && echo deleted windows search file at \\%pc%\c$\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb

   if exist \\%pc%\c$\windows\ccmcache\ (
      (del /s /q /f  \\%pc%\c$\windows\ccmcache\*) > nul 2> nul
      for /d %%b in ("\\%pc%\c$\windows\ccmcache\*") do (
         (rd /s /q "%%b") > nul 2> nul
      ) 
      echo deleted the contents of \\%pc%\c$\windows\ccmcache\
   )
   if exist \\%pc%\c$\temp (
      (del /s /q / f \\%pc%\c$\temp\*) > nul 2> nul
      for /d %%b in ("%pc%\c$\temp\*") do (
         (rd /s /q /"%%b") > nul 2> nul
      ) 
      echo deleted the contenets of \\%pc%\c$\temp\
   )

   for /D %%i in (\\%pc%\c$\users\*) do (
      if exist %%i\AppData\Local\Temp (
         (del /s /q /f %%i\AppData\Local\Temp\*) > nul 2> nul
         for /D %%b in ("%%i\AppData\Local\Temp\*") do (
            (rd /s /q "%%b") > nul 2> nul
         ) 
        echo deleted the contents of %%i\AppData\Local\Temp\ 
       )
   )

   for /f "tokens=2" %%S in ('wmic /node:!ip_address! volume get DriveLetter^, FreeSpace ^| findstr "^C:"') do set spacefinal=%%S
   set /A "final=!spacefinal:~0,-6! / (1074)"
   set /A cleared=final -org
   echo cleared !cleared!GB space from the disk, there's now !final!GB free in the disk.

) else (
   echo No such computer %pc% or it is unavailable at this time
)
setlocal DisableDelayedExpansion
pause
goto mainloop

:IE 
SETLOCAL ENABLEDELAYEDEXPANSION
set /p pc=Enter Computer Name or IP address: 
if exist \\%pc%\c$ (
   (REG Delete "\\%pc%\HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\{1FD49718-1D00-4B19-AF5F-070AF6D5D54C}" /f) > nul 2> nul
   (REG Delete "\\%pc%\HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\{1FD49718-1D00-4B19-AF5F-070AF6D5D54C}" /f) > nul 2> nul
   for /F "tokens=1,2" %%i in ('qwinsta /server:%pc% ^| findstr "console"') do (
       set usr=%%j
   )
   if "!usr:~3!" =="" (
      for /f "tokens=2" %%a in ('qwinsta /server:%pc% ^| findstr /C:"rdp-tcp#"') do (
          set "usr=%%a"
      )
   )
   echo Succsesfully fixed Internet explorer at %pc%
) else (
   echo No such computer %pc% or it is unavailable at this time
)
setlocal DisableDelayedExpansion
pause
goto mainloop


:cockpit
set /p pc=Enter Computer Name or IP address: 
if exist \\%pc%\c$ (
   (reg delete "\\%pc%\HKEY_CURRENT_USER\Software\Jetro Platforms\JDsClient\PrintPlugIn" /v "PrintClientPath" /f) > nul 2> nul
   echo Succsesfully ran cockpit printer fix script at %pc%
) else (
   echo No such computer %pc% or it is unavailable at this time
)
pause
goto mainloop

:lang
set /p pc=Enter Computer Name or IP address: 
if exist \\%pc%\c$ (
   (reg delete "\\%pc%\HKEY_USERS\.DEFAULT\Keyboard Layout\Preload" /f) > nul 2> nul
   echo Succsesfully 3 languages fix script at %pc%
) else (
   echo No such computer %pc% or it is unavailable at this time
)
pause
goto mainloop

:prnt 
SETLOCAL ENABLEDELAYEDEXPANSION
set /p pc=Enter Computer Name or IP address: 
if exist \\%pc%\c$ (
   set found=
   for /f "tokens=1,2*" %%a in ('reg query \\%pc%\HKU') do (
      set sid=%%a
      set "sid=!sid:~11!"
      set profilepath=
      for /f "tokens=2,*" %%m in ('reg query "\\%pc%\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\!sid!" /v ProfileImagePath 2^>nul') do (
         set delu=%%n
         set "delu=!delu:~9!"
         call :convert "!DPN!"
      )
      for /f "tokens=2,3 delims=," %%i in ('reg query "\\%pc%\%%a\Printers\Connections" 2^> nul ^| findstr /i /c:",,"') do (
         set printer=\\%%i\%%j
         set printer=!printer:\,=!
         echo Found a Network Printer at !printer! on user !DPN!
         set "found=1"
      )
   )
   set svrs="\\print_svr1" "\\print_svr2" "\\print_svr3" 
   for /f "tokens=*" %%i in ('reg query "\\%pc%\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Printers" 2^> nul ') do (
      for /f "tokens=2*" %%a in ('reg query "\\%pc%\%%i" /v Port 2^> nul') do ( 
         set tc=
         set brk=
         set "port=%%b"
         if "!port:~0,9!"=="Microsoft" (set brk=1 && set tc=1)
         set "check=!port:.=!"
         if not "!port!"=="" (
            if not "!port!"=="!check!" ( 
               for %%s in (!svrs!) do if not defined brk (
                  for /f "skip=3 tokens=1,2,3 delims= " %%a in ('net view "%%~s"') do if not defined brk (
                      if "%%c"=="!port!" (
                         echo TCP/IP printer with an IP of !port! is located at %%~s\%%a
                         set "brk=1"
                         set "found=1"
                         set tc=1
                      )
                   )
               )
              if not defined tc (echo TCP/IP printer with an IP of !port! is not on any of the servers && set found=1)
            )
         )
      )
   )
   set "port="
   set wsf=
   for /f "tokens=*" %%q in ('reg query "\\%pc%\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\SWD\PRINTENUM" 2^> nul ') do (
      for /f "tokens=2*" %%a in ('reg query "\\%pc%\%%q" /v LocationInformation 2^> nul') do ( 
         for /f "tokens=2 delims=/" %%l in ("%%b") do ( 
            for /f "tokens=1 delims=:" %%x in ("%%l") do (set "port=%%x")
            set "check=!port:.=!"
            if not "!port!"=="" (
               echo !wsf! | findstr /C:"!port!" > nul
               if not "!port!"=="!check!" if errorlevel 1 (
                  set "wsf=!wsf! !port!"
                  for %%s in (!svrs!) do if not defined brk (
                     for /f "skip=3 tokens=1,2,3 delims= " %%a in ('net view "%%~s"') do if not defined brk (
                         if "%%c"=="!port!" (
                            echo WSD printer with an IP of !port! is located at %%~s\%%a
                            set "brk=1"
                            set "found=1"
                            set tc=1
                         )
                      )
                  )
                 if not defined tc (echo WSD printer with an IP of !port! is not on any of the servers && set found=1)
               )
            )
         )
      )
   )
   if not defined found (
      echo There are no Network printer at %pc%
   )
) else (
   echo echo No such computer %pc% or it is unavailable at this time
)
setlocal DisableDelayedExpansion
pause

goto mainloop

:tcpip
SETLOCAL ENABLEDELAYEDEXPANSION
set "found="
set /p "ip=Enter TCP/IP printer's IP Address: "
set svrs="\\prn03" "\\prn02" "\\prn01" "\\prn04" "\\prn05" "\\prn06"
set brk=
for %%s in (!svrs!) do if not defined brk (
   for /f "skip=3 tokens=1,2,3 delims= " %%a in ('net view "%%~s"') do if not defined brk (
      if "%%c"=="!ip!" (
         echo TCP/IP printer with an IP of %ip% is located at %%~s\%%a
         set "brk=1"
         set "found=1"
       )
    )
)
if not "%found%"=="1" (
   echo There is no Network with an address of %ip% at any of the print servers
)
setlocal DisableDelayedExpansion
pause
goto mainloop

:clearusers
setlocal enabledelayedexpansion
set flag=
set usr=
set /p "pc=enter pc: "
if exist \\%pc%\c$ (
   set "flag=true"
   echo:
   for /F "tokens=1,2" %%i in ('qwinsta /server:%pc% ^| findstr "console"') do (
       set usr=%%j
   )
   if "!usr:~3!" =="" (
      for /f "tokens=2" %%a in ('qwinsta /server:%pc% ^| findstr /C:"rdp-tcp#"') do (
          set "usr=%%a"
      )
   )
   if not "!usr:~3!" == "" (
      set "listTD="
      set "todelete="
      for /f "tokens=2 delims=[]" %%a in ('ping -4 -n 1 !pc! ^| findstr "["') do set ip_address=%%a
      set ip_address=!ip_address!
      for /f "tokens=2" %%S in ('wmic /node:!ip_address! volume get DriveLetter^, FreeSpace ^| findstr "^C:"') do set space=%%S
      set /A "org=!space:~0,-6! / (1074)"
      for /D %%i in (\\!pc!\c$\users\*) do (
         for /f "tokens=3,* delims=\" %%a in ("%%i") do set delu=%%b
         set "ask="
         set "sk="
         if not "!usr!"=="!delu!" if not "!delu:~0,5!"=="ADMIN" if not "!delu!"=="Administrator" if not "!delu!"=="Public" (
            call :convert "!DPN!" "DPI"
            :YN
            if "!DPN!" == "!delu!" (
               set /p "ask=Do you want to delete the user folder of !delu! from this PC? Y/N: "
            ) 
            if not "!DPN!" == "!delu!" (
               set /p "ask=Do you want to delete the user folder of !delu! - !DPN! from this PC? Y/N: "
            )
            if "!ask!"=="y" (set "sk=1")
            if "!ask!"=="Y" (set "sk=1")
            if "!sk!"=="1" ( 
               echo !delu! will be Deleted
               set todelete=!todelete! "%%i"
               set "listTD=!listTD!;!delu!-!DPI!"
            )
            if not "!ask!"=="Y" if not "!ask!"=="y" if not "!ask!"=="n" if not "!ask!"=="N" ( 
               if not "!DPN!" == "!delu!" (echo Skipping the deleting of - !delu! !DPN!)
               if "!DPN!" == "!delu!" (echo Skipping the deletion of !delu!)
            )
         )
      )
      if not "!todelete!"=="" (
         set "todelete=!todelete:~1!"
         set "listTD=!listTD:~1!"
         echo:
         echo Are you sure you want to delete the folders of the following users?
         for /f "tokens=1* delims=;" %%u in ("!listTD!") do (
           echo %%u
           for %%v in (%%v) do (
              echo %%v
            )
         echo:
         )
         :cnfrm
         set "confirm="
         set "cm="
         set /p "confirm=Press Y to confirm: "
         if "!confirm!"=="y" (set "cm=1")
         if "!confirm!"=="Y" (set "cm=1")
         if not "!confirm!"=="Y" if not "!confirm!"=="y" if not "!confirm!"=="n" if not "!confirm!"=="N" ( 
            if not "!confirm!"=="" (
               set "prompt=!confirm! is not Y(ES) or N(O), try again."
               echo !prompt!
            )
            goto cnfrm
         )
         if "!cm!"=="1" (
            echo Deleting the users, this may take a few minutes
            (rmdir /q /s !todelete!) 2> nul > nul
            for /f "tokens=2" %%S in ('wmic /node:!ip_address! volume get DriveLetter^, FreeSpace ^| findstr "^C:"') do set space=%%S
            set /A "final=!space:~0,-6! / (1074)"
            set /A "cleared=!final! - !org!"
            echo cleared !cleared!GB space from the disk, there's now !final!GB free in the disk.
        )
         
      )
   )
   if "!todelete!"=="" (echo Didnt delete any user)
   ) 
   if "!usr:~3!" == "" (
      echo No active user was found on !pc!, Cancling...
   ) 
) 
if "!flag!" == "" (echo No such computer !pc! or it is unavailable at this time)
)
setlocal DisableDelayedExpansion
pause
goto mainloop


:convert
set "DPN=!delu!"
set "DPI=!delu!"
(net user !DPN! /domain | FIND /I "Full Name") > nul 2> nul
if !errorlevel! equ 0 (
    FOR /F "tokens=3,4 delims=, " %%A IN ('net user !delu! /domain^| FIND /I "Full Name"') DO SET "dname=%%B %%A"
    set "original=!dname!"
    set "reversed="
    :loop
    if not "!original!"=="" (
       set "reversed=!reversed!!original:~-1!"
       set "original=!original:~0,-1!"
       goto loop
    )
   set "DPN=!reversed!
   set "DPI=!reversed!"
)
setlocal DisableDelayedExpansion
