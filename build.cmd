@echo off

SETLOCAL

SET NUGET=%LocalAppData%\NuGet\NuGet.exe
SET FAKE=%LocalAppData%\FAKE\tools\Fake.exe
SET NYX=%LocalAppData%\Nyx\tools\build_next.fsx
SET GITVERSION=%LocalAppData%\GitVersion.CommandLine\tools\GitVersion.exe
SET MSBUILD14_TOOLS_PATH="%ProgramFiles(x86)%\MSBuild\14.0\bin\MSBuild.exe"

IF NOT EXIST %MSBUILD14_TOOLS_PATH% (
  echo In order to run this tool you need either Visual Studio 2015 or
  echo Microsoft Build Tools 2015 tools installed.
  echo.
  echo Visit this page to download either:
  echo.
  echo http://www.visualstudio.com/en-us/downloads/visual-studio-2015-downloads-vs
  echo.
)

echo Downloading NuGet.exe...
IF NOT EXIST %LocalAppData%\NuGet md %LocalAppData%\NuGet
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile '%NUGET%'"

echo Downloading latest version of NuGet.Core...
IF NOT EXIST %LocalAppData%\NuGet.Core %NUGET% "install" "NuGet.Core" "-OutputDirectory" "%LocalAppData%" "-ExcludeVersion" "-Version" "2.11.1"

echo Downloading FAKE...
IF NOT EXIST %LocalAppData%\FAKE %NUGET% "install" "FAKE" "-OutputDirectory" "%LocalAppData%" "-ExcludeVersion" "-Version" "4.32.0"

echo Downloading GitVersion.CommandLine...
IF NOT EXIST %LocalAppData%\GitVersion.CommandLine %NUGET% "install" "GitVersion.CommandLine" "-OutputDirectory" "%LocalAppData%" "-ExcludeVersion" "-Version" "3.6.1"

echo Downloading Nyx...
%NUGET% "install" "Nyx" "-OutputDirectory" "%LocalAppData%" "-ExcludeVersion" "-PreRelease"

%FAKE% %NYX% "target=clean" -st

%FAKE% %NYX% "target=RestoreNugetPackages" -st
%FAKE% %NYX% "target=RestoreBowerPackages" -st

IF NOT [%1]==[] (set RELEASE_NUGETKEY="%1")
IF NOT [%2]==[] (set RELEASE_TARGETSOURCE="%2")

SET SUMMARY="Pandora aims to externalize the application configuration."
SET DESCRIPTION="Pandora aims to externalize the application configuration."

%FAKE% %NYX% appName=Elders.Pandora.Consul appSummary=%SUMMARY% appDescription=%DESCRIPTION% nugetPackageName=Pandora.Consul nugetserver=%RELEASE_TARGETSOURCE% nugetkey=%RELEASE_NUGETKEY%