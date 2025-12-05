#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Bootstrap script to download and setup private scripts repository
.DESCRIPTION
    This script handles GitHub authentication and clones your private scripts repo
    Usage: irm raw.githubusercontent.com/youruser/bootstrap-scripts/main/bootstrap.ps1 | iex
#>

param(
    [string]$ScriptsRepo = "edjepaz/scripts",
    [string]$TargetPath = "$HOME\MyScripts",
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Bootstrap Script Installer" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Check if GitHub CLI is installed
$ghInstalled = Get-Command gh -ErrorAction SilentlyContinue

if ($ghInstalled) {
    Write-Host "✓ GitHub CLI found" -ForegroundColor Green
    
    # Check if authenticated
    $ghAuth = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠ GitHub CLI not authenticated" -ForegroundColor Yellow
        Write-Host "Starting authentication process...`n" -ForegroundColor Yellow
        gh auth login
        if ($LASTEXITCODE -ne 0) {
            Write-Host "✗ Authentication failed" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "✓ GitHub CLI authenticated" -ForegroundColor Green
    }
} else {
    Write-Host "⚠ GitHub CLI not found" -ForegroundColor Yellow
    Write-Host "Installing GitHub CLI...`n" -ForegroundColor Yellow
    
    # Install GitHub CLI using winget
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id GitHub.cli --silent
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ GitHub CLI installed" -ForegroundColor Green
            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            Write-Host "Authenticating with GitHub...`n" -ForegroundColor Yellow
            gh auth login
            if ($LASTEXITCODE -ne 0) {
                Write-Host "✗ Authentication failed" -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "✗ Failed to install GitHub CLI" -ForegroundColor Red
            Write-Host "`nPlease install manually: https://cli.github.com/" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "✗ winget not found. Please install GitHub CLI manually: https://cli.github.com/" -ForegroundColor Red
        exit 1
    }
}

# Clone the private repository
Write-Host "`n📦 Cloning private scripts repository..." -ForegroundColor Cyan

if (Test-Path $TargetPath) {
    Write-Host "⚠ Target path already exists: $TargetPath" -ForegroundColor Yellow
    $response = Read-Host "Do you want to update it? (y/n)"
    if ($response -eq 'y') {
        Push-Location $TargetPath
        Write-Host "Pulling latest changes..." -ForegroundColor Yellow
        git pull origin $Branch
        Pop-Location
        Write-Host "✓ Repository updated" -ForegroundColor Green
    } else {
        Write-Host "Skipping clone" -ForegroundColor Yellow
    }
} else {
    gh repo clone $ScriptsRepo $TargetPath -- --branch $Branch
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Repository cloned to: $TargetPath" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to clone repository" -ForegroundColor Red
        exit 1
    }
}

# Check for install script in the cloned repo
$installScript = Join-Path $TargetPath "install.ps1"
if (Test-Path $installScript) {
    Write-Host "`n🔧 Found install script, running setup..." -ForegroundColor Cyan
    & $installScript
} else {
    Write-Host "`n✓ Setup complete! Scripts are in: $TargetPath" -ForegroundColor Green
    Write-Host "No install.ps1 found in repository - manual setup may be needed" -ForegroundColor Yellow
}

Write-Host "`n✨ Bootstrap complete!" -ForegroundColor Green
Write-Host "Scripts location: $TargetPath" -ForegroundColor Cyan
