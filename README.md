# DefaultService
This repo is just documenting building a windows hosted service in .NET 7, the default template was used with Top Level Statements.

# Table of Contents
- [DefaultService](#defaultservice)
- [Table of Contents](#table-of-contents)
  - [Packages](#packages)
  - [Program.cs](#programcs)
  - [Worker.cs](#workercs)
- [Publish](#publish)
  - [Configuration](#configuration)
- [Windows Service Management](#windows-service-management)
  - [Install a Service](#install-a-service)
  - [Uninstall a Service](#uninstall-a-service)

## Packages 

- [Microsoft.Extensions.Hosting](https://www.nuget.org/packages/Microsoft.Extensions.Hosting/7.0.0) (included in the template)
- [Microsoft.Extensions.Hosting.WindowsServices](https://www.nuget.org/packages/Microsoft.Extensions.Hosting.WindowsServices/7.0.0) (need to install)

## Program.cs
Add UseWindowsService.
```c
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

- `Produce single file` - **Checked**
- `Enable ReadyToRun compilation` - **Checked**
-  `Trim unused code` - **UnChecked**

# Windows Service Management

## Install a Service
```bash
@echo OFF

SET SERVICE_NAME="My_Service"
SET EXE_NAME="exename.exe"
SET EXE_PATH="C:\\somepath\"%EXE_NAME%

sc.exe create %SERVICE_NAME% binpath= "%EXE_PATH%\%EXE_NAME%"
IF %ERRORLEVEL% NEQ 0 (Echo "Error creating %SERVICE_NAME% service." &Exit /b 1)
```
## Uninstall a Service

```bash
@echo OFF

SET SERVICE_NAME="My_Service"

sc.exe delete %SERVICE_NAME% 
IF %ERRORLEVEL% NEQ 0 (Echo "Error deleting %SERVICE_NAME% service." &Exit /b 1)
```