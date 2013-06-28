@ECHO OFF
set THIS_FOLDER=%CD%
cd %APPDATA%

FOR /F "tokens=*" %%R IN ('dir lyx* /b /o:gn') DO SET FOLDER_NAME=%%R
set INSTALL_FOLDER=%APPDATA%\%FOLDER_NAME%\layouts

cd %THIS_FOLDER%
copy "%THIS_FOLDER%\csm-thesis.layout" "%INSTALL_FOLDER%\"
echo "CSM Thesis Layout installed to %INSTALL_FOLDER%"

pause
