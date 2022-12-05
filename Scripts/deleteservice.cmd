@echo OFF

REM Run as Administrator
REM Stop the service before delete or you will have to reboot for it to be removed
SET SERVICE_NAME="ANet7DefaultService"
SET WAIT_TIME=5

REM Stop the service
ECHO "Trying to stop %SERVICE_NAME%"

for /F "tokens=3 delims=: " %%H in ('sc query %SERVICE_NAME% ^| findstr "        STATE"') do (
  if /I "%%H" NEQ "STOPPED" (
   NET STOP %SERVICE_NAME%
   IF %ERRORLEVEL% NEQ 0 (Echo "Error stopping %SERVICE_NAME% try manual stop in services.msc." &Exit /b 1)
  )
)

REM Delete the service
ECHO "Trying to delete %SERVICE_NAME%"

for /F "tokens=3 delims=: " %%H in ('sc query %SERVICE_NAME% ^| findstr "        STATE"') do (
  if /I "%%H" NEQ "RUNNING" (
   sc.exe delete %SERVICE_NAME% 
   IF %ERRORLEVEL% NEQ 0 (Echo "Error deleting %SERVICE_NAME% service." &Exit /b 1)
  )
)
