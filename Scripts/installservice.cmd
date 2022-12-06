@echo OFF

REM Run as Administrator

SET SERVICE_NAME="ANet7DefaultService"
SET SERVICE_DESCRIPTION="Dotnet 7 default service."
SET EXE_NAME="DefaultService.exe"
SET EXE_PATH="D:\repos\DefaultService\DefaultService\bin\Releaseet7.0\publish\win-x64"
SET DISPLAY_NAME="A Default Service"

SET RESTART_MINUTES=1
SET /A SERVICE_RESTART_DELAY=%RESTART_MINUTES%*60000
SET RESET_DAYS=1
SET /A RESET_DELAY=%RESET_DAYS%*86400

REM When altering these commands there should be a required space after = but not before!

REM Create the service
sc.exe create %SERVICE_NAME% binpath= "%EXE_PATH%\\%EXE_NAME%"
IF %ERRORLEVEL% NEQ 0 (Echo "Error creating %SERVICE_NAME% service. " &Exit /b 1)

REM Update the description
sc.exe description %SERVICE_NAME% %SERVICE_DESCRIPTION%
IF %ERRORLEVEL% NEQ 0 (Echo "Error adding description to %SERVICE_NAME% service. " &Exit /b 1)

REM Update config
sc.exe config %SERVICE_NAME% type= own displayname= %DISPLAY_NAME% error= ignore start= auto obj= LocalSystem password= ""
IF %ERRORLEVEL% NEQ 0 (Echo "Error updating %SERVICE_NAME% service config options. " &Exit /b 1)

REM Update recovery options
sc.exe Failure %SERVICE_NAME% actions= restart/%SERVICE_RESTART_DELAY%/restart/%SERVICE_RESTART_DELAY%/restart/%SERVICE_RESTART_DELAY%// reset= %RESET_DELAY%
IF %ERRORLEVEL% NEQ 0 (Echo "Error updating %SERVICE_NAME% service recovery options. " &Exit /b 1)

REM Start the service
for /F "tokens=3 delims=: " %%H in ('sc query %SERVICE_NAME% ^| findstr "        STATE"') do (
  if /I "%%H" NEQ "RUNNING" (
   NET START %SERVICE_NAME%
   IF %ERRORLEVEL% NEQ 0 (Echo "Error starting %SERVICE_NAME% try manual start in services.msc. " &Exit /b 1)
  )
)
