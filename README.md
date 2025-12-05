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
2. ✅ Prompts for GitHub username (defaults to repository owner)
3. ✅ Checks for Git and installs it if missing (via winget)
4. ✅ Clones your private scripts repository using user-specific authentication
5. ✅ Runs any `install.ps1` found in your scripts repo

**Note:** The script uses username-specific HTTPS authentication to avoid conflicts when multiple GitHub accounts are configured on the same machine. Git will prompt for your Personal Access Token (PAT) when cloning the private repository.

## Customization

You can pass parameters to skip the prompt:

```powershell
# Specify repository inline
irm raw.githubusercontent.com/edjepaz/bootstrap/main/bootstrap.ps1 | iex -ScriptsRepo "username/scripts"

# Customize target path and branch
irm raw.githubusercontent.com/edjepaz/bootstrap/main/bootstrap.ps1 | iex -ScriptsRepo "username/scripts" -TargetPath "C:\MyScripts" -Branch "main"

# Specify GitHub username for authentication (useful with multiple accounts)
irm raw.githubusercontent.com/edjepaz/bootstrap/main/bootstrap.ps1 | iex -ScriptsRepo "username/scripts" -GitUsername "your-github-username"
```

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- GitHub account with access to your private scripts repository
- Internet connection

**Optional:** Git for Windows (will be auto-installed if missing and winget is available)
