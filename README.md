# Bootstrap

One-command script installer for downloading and setting up private scripts repository.

## Usage

Run this command from any Windows machine:

```powershell
irm raw.githubusercontent.com/youruser/bootstrap/main/bootstrap.ps1 | iex
```

## What it does

1. ✅ Checks for GitHub CLI (`gh`) and installs it if missing
2. ✅ Authenticates with GitHub (interactive login)
3. ✅ Clones your private scripts repository
4. ✅ Runs any `install.ps1` found in your scripts repo

## Customization

You can pass parameters:

```powershell
irm raw.githubusercontent.com/youruser/bootstrap/main/bootstrap.ps1 | iex -ScriptsRepo "youruser/scripts" -TargetPath "C:\MyScripts"
```

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- Internet connection
- winget (pre-installed on Windows 11, available on Windows 10)
