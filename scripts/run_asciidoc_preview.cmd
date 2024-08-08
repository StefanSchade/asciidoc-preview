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

cd ..
set IMAGE_NAME=dev-environment
docker build -t %IMAGE_NAME% -f "docker/Dockerfile" .
docker run -it --rm -v %DOCUMENT_DIR%:/workspace/output -w /workspace dev-environment -name %IMAGE_NAME%
cd scripts
