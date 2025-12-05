# Bootstrap

Universal one-command script installer for downloading and setting up any private scripts repository.

## Usage

**Short URL (easiest to type):**
```powershell
irm edjepaz.github.io/bootstrap.ps1 | iex
```

**Full URL:**
```powershell
irm raw.githubusercontent.com/edjepaz/bootstrap/main/bootstrap.ps1 | iex
```

The script will prompt you for your GitHub repository name (e.g., `username/repo-name`).

## What it does

1. ✅ Prompts for your GitHub repository (if not provided)
2. ✅ Detects GitHub CLI and offers OAuth authentication (easiest - no PAT needed!)
3. ✅ Falls back to username-specific HTTPS authentication with PAT
4. ✅ Checks for Git and installs it if missing (via winget)
5. ✅ Clones your private scripts repository
6. ✅ Optionally logs out after clone (for temporary sessions on shared devices)
7. ✅ Runs any `install.ps1` found in your scripts repo

## Authentication Options

**Option 1: GitHub CLI (Recommended - No PAT needed!)**
- Install GitHub CLI: `winget install GitHub.cli`
- Script will detect and offer browser-based OAuth login
- Most secure and user-friendly method
- Supports temporary sessions with auto-logout

**Option 2: Personal Access Token (PAT)**
- Used automatically if GitHub CLI is not available
- Create PAT at: https://github.com/settings/tokens
- Git Credential Manager will cache it securely
- Username-specific to avoid conflicts with multiple accounts

## Customization

You can pass parameters to skip prompts and customize behavior:

```powershell
# Specify repository inline
irm raw.githubusercontent.com/edjepaz/bootstrap/main/bootstrap.ps1 | iex -ScriptsRepo "username/scripts"

# Customize target path and branch
irm raw.githubusercontent.com/edjepaz/bootstrap/main/bootstrap.ps1 | iex -ScriptsRepo "username/scripts" -TargetPath "C:\MyScripts" -Branch "main"

# Specify GitHub username for authentication (useful with multiple accounts)
irm raw.githubusercontent.com/edjepaz/bootstrap/main/bootstrap.ps1 | iex -ScriptsRepo "username/scripts" -GitUsername "your-github-username"

# Use GitHub CLI authentication (if already installed)
irm raw.githubusercontent.com/edjepaz/bootstrap/main/bootstrap.ps1 | iex -ScriptsRepo "username/scripts" -UseGitHubCLI

# Temporary session - logout after clone (recommended for shared/untrusted devices)
irm raw.githubusercontent.com/edjepaz/bootstrap/main/bootstrap.ps1 | iex -ScriptsRepo "username/scripts" -LogoutAfter
```

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- GitHub account with access to your private scripts repository
- Internet connection

**Optional but recommended:**
- GitHub CLI (easier authentication, no PAT needed): `winget install GitHub.cli`
- Git for Windows (will be auto-installed if missing and winget is available)
