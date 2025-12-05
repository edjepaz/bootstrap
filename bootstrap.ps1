#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Bootstrap script to download and setup private scripts repository
.DESCRIPTION
    This script uses Git with SSH or HTTPS authentication to clone your private scripts repo
    Usage: irm raw.githubusercontent.com/edjepaz/bootstrap/main/bootstrap.ps1 | iex
    
    You can also pass parameters:
    irm raw.githubusercontent.com/edjepaz/bootstrap/main/bootstrap.ps1 | iex -ScriptsRepo "username/repo" -TargetPath "C:\MyScripts"
#>

param(
    [string]$ScriptsRepo = "",
    [string]$TargetPath = ".\scripts",
    [string]$Branch = "main",
    [string]$GitUsername = "",
    [switch]$UseGitHubCLI = $false,
    [switch]$LogoutAfter = $false
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Bootstrap Script Installer" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Prompt for repository if not provided
if ([string]::IsNullOrWhiteSpace($ScriptsRepo)) {
    Write-Host "Enter your GitHub repository (format: username/repo-name)" -ForegroundColor Yellow
    Write-Host "Example: edjepaz/scripts" -ForegroundColor Gray
    $ScriptsRepo = Read-Host "Repository"
    
    if ([string]::IsNullOrWhiteSpace($ScriptsRepo)) {
        Write-Host "✗ Repository is required" -ForegroundColor Red
        exit 1
    }
    
    # Validate format
    if ($ScriptsRepo -notmatch '^[\w-]+/[\w-]+$') {
        Write-Host "✗ Invalid repository format. Use: username/repo-name" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Repository: $ScriptsRepo" -ForegroundColor Cyan
Write-Host "Target path: $TargetPath" -ForegroundColor Cyan
Write-Host "Branch: $Branch`n" -ForegroundColor Cyan

# Check if Git is installed
$gitInstalled = Get-Command git -ErrorAction SilentlyContinue

if (-not $gitInstalled) {
    Write-Host "⚠ Git not found" -ForegroundColor Yellow
    Write-Host "Attempting to install Git...`n" -ForegroundColor Yellow
    
    # Try to install via winget
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Installing Git for Windows..." -ForegroundColor Gray
        winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Git installed" -ForegroundColor Green
            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            $gitInstalled = Get-Command git -ErrorAction SilentlyContinue
            
            if (-not $gitInstalled) {
                Write-Host "⚠ Git installed but not in PATH. Please restart your terminal." -ForegroundColor Yellow
                Write-Host "Then run this script again." -ForegroundColor Yellow
                exit 1
            }
        } else {
            Write-Host "✗ Failed to install Git automatically" -ForegroundColor Red
            Write-Host "Please install Git manually from: https://git-scm.com/download/win" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "✗ winget not available" -ForegroundColor Red
        Write-Host "Please install Git manually from: https://git-scm.com/download/win" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "✓ Git found" -ForegroundColor Green

# Check for GitHub CLI and handle authentication
$ghInstalled = Get-Command gh -ErrorAction SilentlyContinue
$ghAuthenticated = $false
$needsGhLogout = $false

if ($ghInstalled) {
    Write-Host "✓ GitHub CLI found" -ForegroundColor Green
    
    # Check if already authenticated
    $ghStatus = gh auth status 2>&1 | Out-String
    if ($ghStatus -match "Logged in to github.com") {
        $ghAuthenticated = $true
        Write-Host "✓ Already authenticated with GitHub CLI" -ForegroundColor Green
    }
    
    # If not authenticated or UseGitHubCLI is explicitly requested
    if (-not $ghAuthenticated -or $UseGitHubCLI) {
        if (-not $ghAuthenticated) {
            Write-Host "`n🔐 GitHub CLI authentication required" -ForegroundColor Cyan
            Write-Host "This will open a browser for secure OAuth login" -ForegroundColor Gray
            
            if ($LogoutAfter) {
                Write-Host "Note: You will be logged out after the clone completes" -ForegroundColor Yellow
            }
            
            $response = Read-Host "`nAuthenticate with GitHub CLI? (y/n)"
            if ($response -eq 'y') {
                gh auth login -h github.com -p https -w
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✓ GitHub CLI authentication successful" -ForegroundColor Green
                    $ghAuthenticated = $true
                    $needsGhLogout = $LogoutAfter
                } else {
                    Write-Host "✗ GitHub CLI authentication failed" -ForegroundColor Red
                    Write-Host "Falling back to manual authentication..." -ForegroundColor Yellow
                }
            } else {
                Write-Host "Skipping GitHub CLI authentication" -ForegroundColor Yellow
            }
        }
    }
} else {
    Write-Host "ℹ GitHub CLI not found (optional)" -ForegroundColor DarkGray
    Write-Host "  Install for easier authentication: winget install GitHub.cli" -ForegroundColor DarkGray
}

# Determine clone URL
Write-Host "`n📦 Cloning private scripts repository..." -ForegroundColor Cyan
Write-Host "Repository: $ScriptsRepo" -ForegroundColor Gray

# Extract or prompt for GitHub username (only if not using authenticated gh)
if ([string]::IsNullOrWhiteSpace($GitUsername) -and -not $ghAuthenticated) {
    # Extract username from repository (owner part)
    $repoOwner = $ScriptsRepo.Split('/')[0]
    Write-Host "`nGitHub username for authentication (default: $repoOwner)" -ForegroundColor Yellow
    Write-Host "Press Enter to use '$repoOwner' or type a different username:" -ForegroundColor Gray
    $inputUsername = Read-Host "Username"
    
    if ([string]::IsNullOrWhiteSpace($inputUsername)) {
        $GitUsername = $repoOwner
    } else {
        $GitUsername = $inputUsername
    }
}

if (-not $ghAuthenticated -and $GitUsername) {
    Write-Host "Authenticating as: $GitUsername" -ForegroundColor Cyan
}

# Build HTTPS URL with username to force user-specific authentication (if not using gh)
if ($ghAuthenticated) {
    $httpsUrl = "https://github.com/$ScriptsRepo.git"
} else {
    $httpsUrl = "https://$GitUsername@github.com/$ScriptsRepo.git"
}
$sshUrl = "git@github.com:$ScriptsRepo.git"

if (Test-Path $TargetPath) {
    Write-Host "⚠ Target path already exists: $TargetPath" -ForegroundColor Yellow
    $response = Read-Host "Do you want to update it? (y/n)"
    if ($response -eq 'y') {
        Push-Location $TargetPath
        Write-Host "Pulling latest changes..." -ForegroundColor Yellow
        git pull origin $Branch 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Repository updated" -ForegroundColor Green
        } else {
            Write-Host "⚠ Update failed, continuing..." -ForegroundColor Yellow
        }
        Pop-Location
    } else {
        Write-Host "Skipping clone" -ForegroundColor Yellow
    }
} else {
    Write-Host "Attempting to clone with HTTPS..." -ForegroundColor Gray
    Write-Host "(Git will prompt for Personal Access Token if needed)" -ForegroundColor Gray
    Write-Host "Note: Password authentication is not supported - use a PAT from https://github.com/settings/tokens" -ForegroundColor DarkGray
    
    # Clone the repository
    git clone --branch $Branch $httpsUrl $TargetPath 2>&1 | Out-String | Write-Host
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Repository cloned to: $TargetPath" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to clone repository" -ForegroundColor Red
        Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
        Write-Host "1. Make sure you have access to the repository" -ForegroundColor Gray
        Write-Host "2. Git may have prompted for credentials - check above" -ForegroundColor Gray
        Write-Host "3. You can also try manually: git clone $httpsUrl $TargetPath" -ForegroundColor Gray
        exit 1
    }
}

# Check for install script in the cloned repo
$installScript = Join-Path $TargetPath "install.ps1"
if (Test-Path $installScript) {
    Write-Host "`n🔧 Found install.ps1 in repository" -ForegroundColor Cyan
    Write-Host "Location: $installScript" -ForegroundColor Gray
    Write-Host "`n⚠ WARNING: This script will be executed on your system" -ForegroundColor Yellow
    $response = Read-Host "Do you want to run it? (y/n)"
    
    if ($response -eq 'y') {
        Write-Host "`nRunning install script..." -ForegroundColor Cyan
        & $installScript
        Write-Host "`n✓ Install script completed" -ForegroundColor Green
    } else {
        Write-Host "`nSkipped running install.ps1" -ForegroundColor Yellow
        Write-Host "You can run it manually later: & '$installScript'" -ForegroundColor Gray
    }
} else {
    Write-Host "`n✓ Setup complete! Scripts are in: $TargetPath" -ForegroundColor Green
    Write-Host "No install.ps1 found in repository - manual setup may be needed" -ForegroundColor Yellow
}

# Handle GitHub CLI logout if requested
if ($needsGhLogout -and $ghInstalled) {
    Write-Host "`n🔓 Logging out from GitHub CLI..." -ForegroundColor Cyan
    gh auth logout --hostname github.com 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Logged out successfully - credentials removed from this device" -ForegroundColor Green
    } else {
        Write-Host "⚠ Logout may have failed - you can manually logout with: gh auth logout" -ForegroundColor Yellow
    }
}

Write-Host "`n✨ Bootstrap complete!" -ForegroundColor Green
Write-Host "Scripts location: $TargetPath" -ForegroundColor Cyan
