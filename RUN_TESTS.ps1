# PowerShell script to run all tests for SmartJudi Platform
# Usage: .\RUN_TESTS.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SmartJudi Platform - Test Runner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "manage.py")) {
    Write-Host "Error: manage.py not found. Please run this script from the smartju directory." -ForegroundColor Red
    exit 1
}

# Try to use Python from virtual environment first
$pythonCmd = $null
if (Test-Path "..\my_smart\Scripts\python.exe") {
    $pythonCmd = "..\my_smart\Scripts\python.exe"
    Write-Host "Using Python from virtual environment: $pythonCmd" -ForegroundColor Green
} elseif (Test-Path "my_smart\Scripts\python.exe") {
    $pythonCmd = "my_smart\Scripts\python.exe"
    Write-Host "Using Python from virtual environment: $pythonCmd" -ForegroundColor Green
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonCmd = "python"
    Write-Host "Using Python from PATH" -ForegroundColor Green
} elseif (Get-Command py -ErrorAction SilentlyContinue) {
    $pythonCmd = "py"
    Write-Host "Using Python launcher (py)" -ForegroundColor Green
} else {
    Write-Host "Error: Python not found. Please install Python or activate virtual environment." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Check if virtual environment is activated
if ($env:VIRTUAL_ENV) {
    Write-Host "Virtual environment: $env:VIRTUAL_ENV" -ForegroundColor Green
} else {
    Write-Host "Warning: Virtual environment not detected. It's recommended to activate it first." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Running All Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Run tests
& $pythonCmd manage.py test --verbosity=2

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Execution Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
