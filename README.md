# Bootstrap

Universal one-command script installer for downloading and setting up any private scripts repository.

## Usage

Run this command from any Windows machine:

```powershell
irm raw.githubusercontent.com/edjepaz/bootstrap/main/bootstrap.ps1 | iex
```

The script will prompt you for your GitHub repository name (e.g., `username/repo-name`).

## What it does

1. ✅ Prompts for your GitHub repository (if not provided)
2. ✅ Checks for Git and installs it if missing (via winget)
3. ✅ Clones your private scripts repository using Git credentials
4. ✅ Runs any `install.ps1` found in your scripts repo

**Note:** Git will prompt for your GitHub credentials when cloning the private repository.

## Customization

You can pass parameters to skip the prompt:

```powershell
# Specify repository inline
irm raw.githubusercontent.com/edjepaz/bootstrap/main/bootstrap.ps1 | iex -ScriptsRepo "username/scripts"

# Customize target path and branch
irm raw.githubusercontent.com/edjepaz/bootstrap/main/bootstrap.ps1 | iex -ScriptsRepo "username/scripts" -TargetPath "C:\MyScripts" -Branch "main"
```

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- GitHub account with access to your private scripts repository
- Internet connection

**Optional:** Git for Windows (will be auto-installed if missing and winget is available)
