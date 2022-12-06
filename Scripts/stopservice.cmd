REM https://github.com/Screaminlean/DefaultService

@echo OFF

REM Run as Administrator

SET SERVICE_NAME="ANet7DefaultService"

ECHO "Trying to stop %SERVICE_NAME%"

REM Stop the service
FOR /F "tokens=3 delims=: " %%H IN ('sc query %SERVICE_NAME% ^| findstr "        STATE"') DO (
  IF /I "%%H" NEQ "STOPPED" (
   NET STOP %SERVICE_NAME%
   IF %ERRORLEVEL% NEQ 0 (Echo "Error stopping %SERVICE_NAME% try manual stop in services.msc." &Exit /b 1)
  )
)
