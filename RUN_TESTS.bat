@echo off
REM Batch script to run all tests for SmartJudi Platform
REM Usage: RUN_TESTS.bat

echo ========================================
echo SmartJudi Platform - Test Runner
echo ========================================
echo.

REM Check if we're in the right directory
if not exist "manage.py" (
    echo Error: manage.py not found. Please run this script from the smartju directory.
    pause
    exit /b 1
)

REM Try to use Python from virtual environment first
if exist "..\my_smart\Scripts\python.exe" (
    set PYTHON_CMD=..\my_smart\Scripts\python.exe
    echo Using Python from virtual environment: %PYTHON_CMD%
) else if exist "my_smart\Scripts\python.exe" (
    set PYTHON_CMD=my_smart\Scripts\python.exe
    echo Using Python from virtual environment: %PYTHON_CMD%
) else (
    REM Try to find Python in PATH
    where python >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set PYTHON_CMD=python
        echo Using Python from PATH
    ) else (
        where py >nul 2>&1
        if %ERRORLEVEL% EQU 0 (
            set PYTHON_CMD=py
            echo Using Python launcher (py)
        ) else (
            echo Error: Python not found. Please install Python or activate virtual environment.
            pause
            exit /b 1
        )
    )
)

echo.

REM Check if virtual environment is activated
if defined VIRTUAL_ENV (
    echo Virtual environment: %VIRTUAL_ENV%
) else (
    echo Warning: Virtual environment not detected. It's recommended to activate it first.
    echo.
)

echo ========================================
echo Running All Tests
echo ========================================
echo.

%PYTHON_CMD% manage.py test --verbosity=2

echo.
echo ========================================
echo Test Execution Complete
echo ========================================
pause
