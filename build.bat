@echo off
setlocal

cd /d "%~dp0"

set "IMAGE=ps2-homebrew-sample"
set "PROJECT_DIR=%cd%"
for %%I in ("%~dp0..") do set "ROOT_DIR=%%~fI"

docker image inspect %IMAGE% >nul 2>nul
if errorlevel 1 (
    docker build -t %IMAGE% -f "%ROOT_DIR%\Dockerfile" "%ROOT_DIR%"
    if errorlevel 1 exit /b %errorlevel%
)

if not defined NUMBER_OF_PROCESSORS set "NUMBER_OF_PROCESSORS=4"

if "%~1"=="" (
    docker run --rm --mount type=bind,source="%PROJECT_DIR%",destination=/project %IMAGE% sh -lc "mkdir -p build && make all -j%NUMBER_OF_PROCESSORS%"
) else (
    docker run --rm --mount type=bind,source="%PROJECT_DIR%",destination=/project %IMAGE% sh -lc "mkdir -p build && make %*"
)

exit /b %errorlevel%
