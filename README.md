# DefaultService
This repo is just documenting building a windows hosted service in .NET 7, the default template was used with Top Level Statements. 
This configuration seems to work with no **Error 1053**.

# Considerations
## Application Execution
By default, the current directory for your Windows service is the System folder, **Not** the directory that your .exe is in ~~(C:\Path\To\My\App.exe)~~. We need to bare this in mind when trying ro access files with a relative path as the application will look for those files in the system directory and cause and exception that will cause the service to bail on start with **Error 1053** or an error while running and if not handled will cost you a great deal of time trying to track it down.

- **x64 C:\windows\System32**
- **x86 C:\Windows\SysWOW64**

## Debugging
When you debug your service and everythinhg works as expected but then fails when you deploy the service, consider the above!

### Things to try
**In Program.cs**  set the current directory, this should then point to the directory of your .exe. 
[See this post on StackOverFlow](https://stackoverflow.com/questions/2714262/relative-path-issue-with-net-windows-service), I can not take credit for these, I have just noted them here to help.
```csharp
  static void Main(string[] args)
  {
    Directory.SetCurrentDirectory(AppDomain.CurrentDomain.BaseDirectory);            
  }
```

# Table of Contents
- [DefaultService](#defaultservice)
- [Considerations](#considerations)
  - [Application Execution](#application-execution)
  - [Debugging](#debugging)
    - [Things to try](#things-to-try)
- [Table of Contents](#table-of-contents)
- [The Application](#the-application)
  - [Packages](#packages)
  - [Program.cs](#programcs)
  - [Worker.cs](#workercs)
- [Publish](#publish)
  - [Configuration](#configuration)
- [Windows Service Management](#windows-service-management)
  - [Scripts](#scripts)
  - [Install a Service](#install-a-service)
  - [Uninstall a Service](#uninstall-a-service)

# The Application
## Packages 

- [Microsoft.Extensions.Hosting](https://www.nuget.org/packages/Microsoft.Extensions.Hosting/7.0.0) (included in the template)
- [Microsoft.Extensions.Hosting.WindowsServices](https://www.nuget.org/packages/Microsoft.Extensions.Hosting.WindowsServices/7.0.0) (need to install)

## Program.cs
Add UseWindowsService.
```csharp
.UseWindowsService()
    .Build();
```

## Worker.cs

# Publish
## Configuration
Right click the project, select publish and create a publish profile. 

**Then click Show all settings**.

- `Configuration` - **Release | x64**
- `Target framework` - **net7.0**
- `Deployment mode` - **Self-contained**
- `Target runtime` - **win-x64**
- `Target location` - **\bin\Release\net7.0\publish\win-x64\\**

File publish options

- [x] `Produce single file`
- [x] `Enable ReadyToRun compilation`
- [ ] `Trim unused code` 

# Windows Service Management

## Scripts
The service scripts included in the Scripts directory requires CMD to be run as **Administrator**
- **installservice.cmd**
- **deleteservice.cmd**

Please update the variables in the scripts to suit your application before you execute them. I have tested them several times and they perform as expected on my system. The scripts are provided for assistance and reference with **no guarantee**. It is **your responsability** to check before executing them that they are **NOT** going to **alter or delete** any **important services** on your system.

## Install a Service
File **installservice.cmd** is included in the Scripts directory and requires CMD to be run as **Administrator**
```bash
>cd script_directory
>installservice
```

```bash
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
sc.exe config %SERVICE_NAME% type= own displayname= %DISPLAY_NAME% error= ignore start= auto
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

```
## Uninstall a Service
File **deleteservice.cmd** is included in the Scripts directory and requires CMD to be run as **Administrator**
```bash
>cd script_directory
>deleteservice
```
```bash
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
```