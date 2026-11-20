@echo off
echo ============================================================================
echo   Uploading RTL-Based Environmental Monitoring and Data-Logging SoC to GitHub
echo   Repository: https://github.com/NamrathaKavididevi/environment_monitoring_soc.git
echo ============================================================================
echo.

set GIT="E:\2025.1\tps\win64\git-2.46.0\cmd\git.exe"

%GIT% branch -M main
%GIT% push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================================================
    echo   SUCCESSFULLY PUSHED PROJECT TO GITHUB!
    echo ============================================================================
) else (
    echo.
    echo ============================================================================
    echo   Push failed or requires login.
    echo   If prompted, sign in via browser or enter your GitHub Personal Access Token.
    echo ============================================================================
)
pause
