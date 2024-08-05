@echo off
REM Script to build and start the asciidoc-preview container

if "%1"=="" (
    echo Usage: run_asciidoc_preview.cmd [document_path]
    exit /b 1
)

set DOCUMENT_DIR=%~1

cd ..
set IMAGE_NAME=dev-environment
docker build -t %IMAGE_NAME% -f "docker/Dockerfile" .
docker run -it --rm -v %DOCUMENT_DIR%:/workspace/data -v %cd%/src:/workspace/src -w /workspace dev-environment
cd scripts
