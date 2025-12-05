# Bootstrap

One-command script installer for downloading and setting up private scripts repository.

## Usage

Run this command from any Windows machine:

```powershell
irm raw.githubusercontent.com/edjepaz/bootstrap/main/bootstrap.ps1 | iex
```

## What it does

1. ✅ Checks for Git installation
2. ✅ Clones your private scripts repository using Git credentials
3. ✅ Runs any `install.ps1` found in your scripts repo

**Note:** Git will prompt for your GitHub credentials when cloning the private repository.

## Customization

You can pass parameters:

```powershell
irm raw.githubusercontent.com/edjepaz/bootstrap/main/bootstrap.ps1 | iex -ScriptsRepo "edjepaz/scripts" -TargetPath "C:\MyScripts"
```

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- Git for Windows
- GitHub account with access to your private scripts repository
- Internet connection
