@echo off

setlocal

set "CarNDUKFProjectPlatform=x64"
set "CarNDUKFProjectToolset=v141"
set "CarNDUKFProjectBuildType=Debug"

if NOT "%~1"=="" set "CarNDUKFProjectPlatform=%~1"
if NOT "%~2"=="" set "CarNDUKFProjectToolset=%~2"
if NOT "%~3"=="" set "CarNDUKFProjectBuildType=%~3" 

set "VcPkgDir=c:\vcpkg"
set "VcPkgTriplet=%CarNDUKFProjectPlatform%-windows"
rem set "VcPkgTriplet=%CarNDUKFProjectPlatform%-windows-%CarNDUKFProjectToolset%"

if defined VCPKG_ROOT_DIR if /i not "%VCPKG_ROOT_DIR%"=="" (
    set "VcPkgDir=%VCPKG_ROOT_DIR%"
)
if defined VCPKG_DEFAULT_TRIPLET if /i not "%VCPKG_DEFAULT_TRIPLET%"=="" (
    set "VcpkgTriplet=%VCPKG_DEFAULT_TRIPLET%"
)
set "VcPkgPath=%VcPkgDir%\vcpkg.exe"

echo. & echo Bootstrapping dependencies for triplet: %VcPkgTriplet% & echo.

rem ==============================
rem Update and Install packages
rem ==============================
call "%VcPkgPath%" update

rem Install latest uwebsockets
call "%VcPkgPath%" install uwebsockets --triplet %VcPkgTriplet%
rem Use adapted main.cpp for latest uwebsockets
copy main.cpp ..\..\src

rem ==============================
rem Configure CMake
rem ==============================

set "VcPkgTripletDir=%VcPkgDir%\installed\%VcPkgTriplet%"

set "CMAKE_PREFIX_PATH=%VcPkgTripletDir%;%CMAKE_PREFIX_PATH%"

echo. & echo Bootstrapping successful for triplet: %VcPkgTriplet% & echo CMAKE_PREFIX_PATH=%CMAKE_PREFIX_PATH% & echo.

set "CarNDUKFProjectCMakeGeneratorName=Visual Studio 15 2017"

if "%CarNDUKFProjectPlatform%"=="x86" (
    if "%CarNDUKFProjectToolset%"=="v140" set "CarNDUKFProjectCMakeGeneratorName=Visual Studio 14 2015"
    if "%CarNDUKFProjectToolset%"=="v141" set "CarNDUKFProjectCMakeGeneratorName=Visual Studio 15 2017"
)

if "%CarNDUKFProjectPlatform%"=="x64" (
    if "%CarNDUKFProjectToolset%"=="v140" set "CarNDUKFProjectCMakeGeneratorName=Visual Studio 14 2015 Win64"
    if "%CarNDUKFProjectToolset%"=="v141" set "CarNDUKFProjectCMakeGeneratorName=Visual Studio 15 2017 Win64"
)

set "CarNDUKFProjectBuildDir=%~dp0\..\..\products\cmake.msbuild.windows.%CarNDUKFProjectPlatform%.%CarNDUKFProjectToolset%"
if not exist "%CarNDUKFProjectBuildDir%" mkdir "%CarNDUKFProjectBuildDir%"
cd "%CarNDUKFProjectBuildDir%"

echo: & echo CarNDUKFProjectBuildDir=%CD% & echo cmake.exe -G "%CarNDUKFProjectCMakeGeneratorName%" "%~dp0\..\.." & echo:

call cmake.exe -G "%CarNDUKFProjectCMakeGeneratorName%" "%~dp0\..\.."

call "%VcPkgPath%" integrate install

endlocal