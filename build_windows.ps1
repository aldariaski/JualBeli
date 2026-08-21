$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================"
Write-Host " JualBeli Windows Build"
Write-Host "========================================"
Write-Host ""

$projectRoot = $PSScriptRoot

$backendDir = Join-Path `
    $projectRoot `
    "jualbeli_backend"

$releaseDir = Join-Path `
    $projectRoot `
    "build\windows\x64\runner\Release"

$backendExe = Join-Path `
    $releaseDir `
    "jualbeli_backend.exe"

# ==============================================================
# CHECK BACKEND
# ==============================================================

if (!(Test-Path $backendDir)) {
    Write-Error "jualbeli_backend directory not found:"
    Write-Error $backendDir
    exit 1
}

Write-Host "[1/5] Backend found:"
Write-Host $backendDir
Write-Host ""

# ==============================================================
# GET BACKEND DEPENDENCIES
# ==============================================================

Write-Host "[2/5] Getting backend dependencies..."
Write-Host ""

Push-Location $backendDir

# uncomment to run
#dart pub get

#if ($LASTEXITCODE -ne 0) {
    #Write-Error "dart pub get failed."
    #exit 1
#}

Pop-Location

# ==============================================================
# BUILD FLUTTER
# ==============================================================

Write-Host ""
Write-Host "[3/5] Building Flutter Windows..."
Write-Host ""

flutter build windows

if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter Windows build failed."
    exit 1
}

# ==============================================================
# COMPILE BACKEND
# ==============================================================

Write-Host ""
Write-Host "[4/5] Compiling backend..."
Write-Host ""

Push-Location $backendDir

dart compile exe `
    bin\jualbeli_backend.dart `
    -o $backendExe

if ($LASTEXITCODE -ne 0) {
    Pop-Location
    Write-Error "Backend compilation failed."
    exit 1
}

Pop-Location

# ==============================================================
# VERIFY
# ==============================================================

Write-Host ""
Write-Host "[5/5] Checking build..."
Write-Host ""

$flutterExe = Join-Path `
    $releaseDir `
    "jualbeli.exe"

if (!(Test-Path $flutterExe)) {
    Write-Error "jualbeli.exe was not found."
    exit 1
}

if (!(Test-Path $backendExe)) {
    Write-Error "jualbeli_backend.exe was not found."
    exit 1
}

# ==============================================================
# DONE
# ==============================================================

Write-Host ""
Write-Host "========================================"
Write-Host " BUILD SUCCESSFUL"
Write-Host "========================================"
Write-Host ""

Write-Host "Flutter:"
Write-Host $flutterExe

Write-Host ""

Write-Host "Backend:"
Write-Host $backendExe

Write-Host ""

Write-Host "Release folder:"
Write-Host $releaseDir

Write-Host ""
Write-Host "JualBeli is ready to run."
Write-Host ""