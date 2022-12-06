REM https://github.com/Screaminlean/DefaultService

@echo OFF

REM Run as Administrator

SET SERVICE_NAME="ANet7DefaultService"

ECHO "Trying to start %SERVICE_NAME%"

REM Start the service
FOR /F "tokens=3 delims=: " %%H IN ('sc query %SERVICE_NAME% ^| findstr "        STATE"') DO (
  IF /I "%%H" NEQ "RUNNING" (
   NET START %SERVICE_NAME%
   IF %ERRORLEVEL% NEQ 0 (Echo "Error starting %SERVICE_NAME% try manual start in services.msc. " &Exit /b 1)
  )
)
