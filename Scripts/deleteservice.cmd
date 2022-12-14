REM https://github.com/Screaminlean/DefaultService

@echo OFF

REM Run as Administrator

REM Stop the service before delete or you will have to reboot for it to be removed
SET SERVICE_NAME="ANet7DefaultService"

REM Stop the service
ECHO "Trying to stop %SERVICE_NAME%"

FOR /F "tokens=3 delims=: " %%H IN ('sc query %SERVICE_NAME% ^| findstr "        STATE"') DO (
  IF /I "%%H" NEQ "STOPPED" (
   NET STOP %SERVICE_NAME%
   IF %ERRORLEVEL% NEQ 0 (Echo "Error stopping %SERVICE_NAME% try manual stop in services.msc." &Exit /b 1)
  )
)

REM Delete the service
ECHO "Trying to delete %SERVICE_NAME%"

FOR /F "tokens=3 delims=: " %%H IN ('sc query %SERVICE_NAME% ^| findstr "        STATE"') DO (
  IF /I "%%H" NEQ "RUNNING" (
   sc.exe delete %SERVICE_NAME% 
   IF %ERRORLEVEL% NEQ 0 (Echo "Error deleting %SERVICE_NAME% service." &Exit /b 1)
  )
)
