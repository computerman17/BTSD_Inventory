:: Windows Inventory Script

:: Turn off display
echo off

:: Clear screen
cls

:: Display message
echo.
echo Please wait while this script gathers all necessary inventory information...
echo.

:: Set current directory
Set CURDIR=%~dp0

:: Set Current Date
FOR /F "TOKENS=2 eol=/ DELIMS=/ " %%A IN ('DATE/T') DO SET mm=%%A
FOR /F "TOKENS=2,3 eol=/ DELIMS=/ " %%A IN ('DATE/T') DO SET dd=%%B
FOR /F "TOKENS=2,3,4 eol=/ DELIMS=/ " %%A IN ('DATE/T') DO SET yyyy=%%C

SET CUR_DATE=%mm%-%dd%-%yyyy%

:: Set Current Time
set HH=%TIME: =0%
set HH=%HH:~0,2%
set MI=%TIME:~3,2%
FOR /F "tokens=3 delims=: " %%A in ('time /t ') do @(Set AMPM=%%A)

SET CUR_TIME=%HH%:%MI% %AMPM%

:: Set location of Log Files
Set LogFileDir=%CURDIR%Logs\

:: Set Computername
set HOST=%COMPUTERNAME%

:: Set Username
set USER=%USERNAME%

:: Set Serial Number
for /F "skip=2 tokens=2 delims=," %%A in ('wmic systemenclosure get serialnumber /FORMAT:csv') do (set "SERIAL=%%A")

:: Set Make
FOR /F "tokens=2 delims==" %%A IN ('WMIC csproduct GET Vendor /VALUE ^| FIND /I "Vendor="') DO SET MAKE=%%A

:: Set Model
FOR /F "tokens=2 delims==" %%A IN ('WMIC csproduct GET Name /VALUE ^| FIND /I "Name="') DO SET MODEL=%%A


:: Determine size of C Drive
@echo off & setlocal ENABLEDELAYEDEXPANSION
SET "volume=C:"
FOR /f "tokens=1*delims=:" %%i IN ('fsutil volume diskfree %volume%') DO (
    SET "diskfree=!disktotal!"
    SET "disktotal=!diskavail!"
    SET "diskavail=%%j"
)

:: Determine what to set C Drive Size based on if C Drive exists
IF EXIST "C:\Windows\" (
	set C_DRIVE_SIZE=%disktotal:~1,-9% GB
) ELSE (
	set C_DRIVE_SIZE=N/A
)


:: Set RAM
For /F "Usebackq Delims== Tokens=2" %%x In (`WMIc MemoryChip Get Capacity /Value`
   ) Do Set Inst_Ram=%%x
Set /A KB=%Inst_Ram:~0,-4%
Set /A MB = kb/1024
Set /A GB = mb/1024
set RAM=%GB% GB


:: Set Processor
FOR /F "tokens=2 delims==" %%A IN ('WMIC cpu GET Name /VALUE ^| FIND /I "Name="') DO SET PROCESSOR=%%A


:: Create variable for Processor in all upper case (CUP_PROCESSOR)
for /f "skip=2 delims=" %%I in ('tree "\%PROCESSOR%"') do if not defined upper set "upper=%%~I"
set "upper=%upper:~3%"
set CUP_PROCESSOR=%upper%


:: Determine if PROCESSOR contains word "CORE(TM)2 DUO"
echo %CUP_PROCESSOR% | findstr /C:"CORE(TM)2 DUO" 1>nul

if errorlevel 1 (
  set ABV_PROCESSOR=UNKNOWN
) ELSE (
  set ABV_PROCESSOR=Core2Duo
)

:: Determine if PROCESSOR contains word "CORE(TM) I3"
echo %CUP_PROCESSOR% | findstr /C:"CORE(TM) I3" 1>nul

if errorlevel 1 (
  set ABV_PROCESSOR=UNKNOWN
) ELSE (
  set ABV_PROCESSOR=Core_i3
)

:: Determine if PROCESSOR contains word "CORE(TM) I5"
echo %CUP_PROCESSOR% | findstr /C:"CORE(TM) I5" 1>nul

if errorlevel 1 (
  set ABV_PROCESSOR=UNKNOWN
) ELSE (
  set ABV_PROCESSOR=Core_i5
)


:: Clear screen
cls


:: Create Log Directory
md "%LogFileDir%"

:: Create Model Sub-Directory
md "%LogFileDir%\%MODEL%"

:: Get MAC Address
@echo off
FOR /f "tokens=1" %%a in ('getmac /NH') DO SET MAC=%%a


:: Set Log File
set LogFile=%CURDIR%Logs\%MODEL%\%ABV_PROCESSOR% Inventory.csv

:: Determine what model machine and then save inventory to corresponding file
echo %CUR_DATE%,%CUR_TIME%,%USER%,%HOST%,%MAKE%,%MODEL%,%SERIAL%,%MAC%,%C_DRIVE_SIZE%,%RAM%,%PROCESSOR%>>"%LogFile%"


:: Clear screen
cls


:: Display inventory information for user
echo.
echo   Computer Model: %MODEL%
echo  Hard Drive Size: %C_DRIVE_SIZE%
echo              RAM: %RAM%
echo        Processor: %PROCESSOR%
echo.
echo      Output file: %LogFile%
echo.

:: Pause screen so user can see output
PAUSE
