@echo off
REM Script to build and start the asciidoc-preview container

if "%1"=="" (
    echo Usage: run_asciidoc_preview.cmd [document_path]
    exit /b 1
)

set DOCUMENT_DIR=%~1

IF NOT EXIST "%DOCUMENT_DIR%" (
    echo The specified path does not exist.
    exit /b 1
)

REM Check if the path is absolute
echo %DOCUMENT_DIR% | findstr /R "^[a-zA-Z]:\\" > nul
if %ERRORLEVEL% neq 0 (
    REM Convert relative path to absolute path
    set DOCUMENT_DIR=%~dp0%DOCUMENT_DIR%
)

REM Sanitize the DOCUMENT_DIR to create a valid container name
set SANITIZED_PATH=%DOCUMENT_DIR::=_% 
set SANITIZED_PATH=%SANITIZED_PATH:\=_% 
set SANITIZED_PATH=%SANITIZED_PATH:/=_% 

REM Set the image name
set IMAGE_NAME=asciidoc-preview

REM Set the container name
set CONTAINER_NAME=%IMAGE_NAME%_%SANITIZED_PATH%

cd ..
docker build -t %IMAGE_NAME% -f "docker/Dockerfile" .
docker run -it --rm -p 35729:35729 -p 4000:4000 -v %DOCUMENT_DIR%:/workspace/input -w /workspace --name %IMAGE_NAME% %IMAGE_NAME%

echo %IMAGE_NAME%
cd scripts

