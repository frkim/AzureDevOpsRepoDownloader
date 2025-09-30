# Azure DevOps Repository Downloader v2.0

A powerful PowerShell script to download multiple Azure DevOps repositories using one of three methods: **Git Clone**, **REST API**, or **Azure DevOps CLI**.

## 🚀 Features

- ✅ **Three download methods** with automatic prerequisite checking
- ✅ Clone multiple ADO repositories in batch
- ✅ Support for both URL list and file input
- ✅ Optional ZIP archive creation
- ✅ Credential management (PAT support)
- ✅ Automatic directory naming based on repository name
- ✅ Branch selection support
- ✅ Comprehensive error handling with friendly error messages
- ✅ Beautiful colored console output with progress tracking

## 📋 Prerequisites

Prerequisites depend on the download method you choose:

### Method 1: Git Clone (Default)
- **Git**: Must be installed and available in PATH
  - Download from: https://git-scm.com/downloads
- **PowerShell 5.1+** or **PowerShell Core 7+**

### Method 2: REST API
- **PowerShell 5.1+** or **PowerShell Core 7+** (already installed on Windows 10+)
- **Personal Access Token (PAT)** with Code (Read) permission

### Method 3: Azure DevOps CLI
- **Azure CLI**: Must be installed and available in PATH
  - Download from: https://aka.ms/installazurecliwindows
- **Azure DevOps Extension**: Install with `az extension add --name azure-devops`
- **PowerShell 5.1+** or **PowerShell Core 7+**

> **Note**: The script automatically checks for prerequisites and displays friendly installation instructions if anything is missing!

## Authentication

### Personal Access Token (PAT)

1. Go to Azure DevOps: `https://dev.azure.com/{organization}`
2. Click on **User Settings** → **Personal Access Tokens**
3. Create a new token with **Code (Read)** permission
4. Copy the token and use it with the `-PersonalAccessToken` parameter

## 🔄 Download Methods Comparison

| Feature | Git Clone | REST API | Azure CLI |
|---------|-----------|----------|-----------|
| **Speed** | ⚡ Fast | 🐢 Slower | ⚡ Fast |
| **Git History** | ✅ Yes | ❌ No | ✅ Yes |
| **Large Files** | ✅ Excellent | ⚠️ Limited | ✅ Excellent |
| **Prerequisites** | Git | PowerShell only | Azure CLI + Extension |
| **Authentication** | PAT or Credential Manager | PAT Required | PAT or Azure Login |
| **Offline Work** | ✅ Full git features | ❌ Source only | ✅ Full git features |
| **Branch Support** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Best For** | Development work | Quick snapshots | Azure-integrated workflows |

### Detailed Pros & Cons

#### 🔹 Method 1: Git Clone (Default)
**Pros:**
- ✅ Preserves full git history and metadata
- ✅ Fast and reliable for all repository sizes
- ✅ Supports all git features (branches, tags, etc.)
- ✅ Works with Git Credential Manager
- ✅ Industry-standard approach

**Cons:**
- ❌ Requires Git installation
- ❌ Downloads full repository history (can be large)

**Best for:** Regular development work, when you need git history, or when working with large repositories.

#### 🔹 Method 2: REST API
**Pros:**
- ✅ No external dependencies (PowerShell only)
- ✅ Downloads only the source code (smaller download)
- ✅ Works on systems without Git
- ✅ Direct ZIP download available

**Cons:**
- ❌ No git history
- ❌ Requires PAT for authentication
- ❌ Slower for very large repositories
- ❌ API rate limits may apply

**Best for:** Quick source code snapshots, systems without Git, or when you don't need version history.

#### 🔹 Method 3: Azure DevOps CLI
**Pros:**
- ✅ Official Microsoft tool
- ✅ Integrates with Azure ecosystem
- ✅ Preserves git history
- ✅ Supports Azure AD authentication

**Cons:**
- ❌ Requires Azure CLI installation
- ❌ Additional dependency (devops extension)
- ❌ Slower initial setup

**Best for:** Azure-integrated environments, teams already using Azure CLI, or when using Azure AD authentication.

## 📖 Usage Examples

### Method 1: Git Clone (Default)

#### Example 1: Basic Git clone
```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryUrls @("https://dev.azure.com/myorg/myproject/_git/repo1") `
    -PersonalAccessToken "your-pat-token-here"
```

#### Example 2: Git clone from file list
```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "Git" `
    -PersonalAccessToken "your-pat-token-here" `
    -DestinationPath "C:\ADORepos"
```

#### Example 3: Git clone with ZIP creation
```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "Git" `
    -CreateZipArchive `
    -CleanupGitFolder `
    -PersonalAccessToken "your-pat-token-here"
```

### Method 2: REST API

#### Example 4: REST API download (no Git required)
```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "RestAPI" `
    -PersonalAccessToken "your-pat-token-here" `
    -DestinationPath "C:\SourceCode"
```

#### Example 5: REST API with ZIP archives
```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryUrls @("https://dev.azure.com/myorg/myproject/_git/repo1") `
    -Method "RestAPI" `
    -CreateZipArchive `
    -PersonalAccessToken "your-pat-token-here"
```

### Method 3: Azure CLI

#### Example 6: Azure CLI download
```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "AzureCLI" `
    -PersonalAccessToken "your-pat-token-here"
```

#### Example 7: Azure CLI with specific branch
```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryUrls @("https://dev.azure.com/myorg/myproject/_git/repo1") `
    -Method "AzureCLI" `
    -Branch "develop" `
    -PersonalAccessToken "your-pat-token-here"
```

### Advanced Examples

#### Example 8: Multiple repositories with Git Credential Manager
```powershell
# If you have Git Credential Manager configured
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "Git" `
    -DestinationPath ".\downloads"
```

#### Example 9: Mixed scenario - compare methods
```powershell
# Download with Git (preserves history)
.\Download-ADORepositories.ps1 `
    -RepositoryUrls @("https://dev.azure.com/myorg/myproject/_git/repo1") `
    -Method "Git" `
    -DestinationPath ".\git-method"

# Download same repo with REST API (source only)
.\Download-ADORepositories.ps1 `
    -RepositoryUrls @("https://dev.azure.com/myorg/myproject/_git/repo1") `
    -Method "RestAPI" `
    -PersonalAccessToken "your-pat" `
    -DestinationPath ".\api-method"
```

## 📝 Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `RepositoryUrls` | String[] | Yes* | Array of ADO repository URLs |
| `RepositoryListFile` | String | Yes* | Path to text file with URLs (one per line) |
| `Method` | String | No | Download method: `Git` (default), `RestAPI`, or `AzureCLI` |
| `DestinationPath` | String | No | Base directory for downloads (default: current directory) |
| `CreateZipArchive` | Switch | No | Create ZIP files instead of keeping repositories |
| `PersonalAccessToken` | String | **Required for RestAPI** | Azure DevOps PAT for authentication |
| `Username` | String | No | Username for authentication (default: "git") |
| `CleanupGitFolder` | Switch | No | Remove .git folder when creating ZIP (Git method only) |
| `Branch` | String | No | Specific branch to download (default: repo default branch) |

*Either `RepositoryUrls` or `RepositoryListFile` must be provided

### Method-Specific Requirements

| Method | Required Parameters | Optional Parameters |
|--------|-------------------|-------------------|
| **Git** | None (PAT optional) | `PersonalAccessToken`, `Branch`, `CreateZipArchive`, `CleanupGitFolder` |
| **RestAPI** | `PersonalAccessToken` | `Branch`, `CreateZipArchive` |
| **AzureCLI** | None (if logged in) | `PersonalAccessToken`, `Branch`, `CreateZipArchive` |

## Repository List File Format

Create a text file with one repository URL per line:

```text
https://dev.azure.com/myorg/project1/_git/repo1
https://dev.azure.com/myorg/project1/_git/repo2
https://dev.azure.com/myorg/project2/_git/repo3
```

- Empty lines are ignored
- Lines starting with `#` are treated as comments

## Supported URL Formats

The script supports both Azure DevOps URL formats:

1. **Modern format**: `https://dev.azure.com/{organization}/{project}/_git/{repository}`
2. **Legacy format**: `https://{organization}.visualstudio.com/{project}/_git/{repository}`

## Output

### Standard Clone Mode
```
downloads/
├── repository1/
│   ├── .git/
│   └── (source files)
├── repository2/
│   ├── .git/
│   └── (source files)
└── repository3/
    ├── .git/
    └── (source files)
```

### ZIP Archive Mode
```
downloads/
├── repository1.zip
├── repository2.zip
└── repository3.zip
```

## Error Handling

The script includes comprehensive error handling:
- ✅ Validates Git installation
- ✅ Checks for existing directories
- ✅ Validates URL formats
- ✅ Provides detailed error messages
- ✅ Summary report at the end

## Security Notes

⚠️ **Important**: 
- Never commit your Personal Access Token to version control
- Store PAT in environment variables or secure vaults
- Consider using Git Credential Manager for automatic credential handling

### Using Environment Variables
```powershell
$env:ADO_PAT = "your-pat-token"
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -PersonalAccessToken $env:ADO_PAT
```

## 🔧 Troubleshooting

### Issue: Missing Prerequisites Error
**Symptoms**: Script displays a red error box about missing prerequisites.

**Solution**: The script will show you exactly what's missing and how to install it. Follow the instructions displayed:

```
╔════════════════════════════════════════════════════════════════╗
║                   MISSING PREREQUISITES                        ║
╚════════════════════════════════════════════════════════════════╝
```

- **For Git**: Download from https://git-scm.com/downloads
- **For Azure CLI**: Download from https://aka.ms/installazurecliwindows
- **For Azure DevOps Extension**: Run `az extension add --name azure-devops`

### Issue: "AUTHENTICATION REQUIRED" error (REST API)
**Symptoms**: Red error box when using REST API method without PAT.

**Solution**: 
1. Go to https://dev.azure.com/{organization}/_usersSettings/tokens
2. Create a new Personal Access Token with **Code (Read)** permission
3. Copy the token and use it with `-PersonalAccessToken` parameter

### Issue: Authentication failures
**Solution**: 
1. Verify your PAT is valid and has **Code (Read)** permission
2. Check PAT hasn't expired (they expire by default)
3. Ensure you're using the correct organization URL
4. For Azure CLI, try running `az login` first

### Issue: "Directory already exists"
**Solution**: The script skips existing directories to prevent data loss. Delete or rename them to re-download.

### Issue: Large repository downloads are slow
**Solution**: 
- **Git method**: This is normal for repos with large history. Consider the REST API method for source-only downloads.
- **REST API**: Expected for very large files. Git method may be faster for such cases.
- **Azure CLI**: Similar to Git method performance.

### Issue: Azure CLI not finding repositories
**Solution**:
1. Make sure you're logged in: `az login`
2. Set default organization: `az devops configure --defaults organization=https://dev.azure.com/yourorg`
3. Verify you have access to the repositories

### Issue: REST API download fails for large files
**Solution**: Switch to Git or Azure CLI method, which handle large files better.

### Issue: Script hangs or shows no output
**Solution**:
1. Check your network connection
2. Verify the repository URLs are correct
3. Ensure you have access permissions to the repositories
4. Try running with `-Verbose` for more details

## 🔐 Security Best Practices

⚠️ **Important Security Notes:**

1. **Never commit PAT tokens to version control**
2. **Store PAT in environment variables or secure vaults**
3. **Use minimum required permissions** (Code Read only)
4. **Set expiration dates on tokens**
5. **Rotate tokens regularly**

### Secure PAT Storage

#### Option 1: Environment Variable
```powershell
# Set once
$env:ADO_PAT = "your-pat-token"

# Use in script
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "RestAPI" `
    -PersonalAccessToken $env:ADO_PAT
```

#### Option 2: Secure String (for sensitive environments)
```powershell
# Store securely
$secureToken = Read-Host -AsSecureString -Prompt "Enter PAT"
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
$token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Use in script
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -PersonalAccessToken $token
```

#### Option 3: Git Credential Manager (Git method only)
Configure once, use everywhere:
```powershell
git config --global credential.helper manager-core
# Then just run without PAT parameter
.\Download-ADORepositories.ps1 -RepositoryListFile "repos.txt" -Method "Git"
```

## 🎯 Choosing the Right Method

### Use **Git Clone** when:
- ✅ You need full git history
- ✅ You're doing active development
- ✅ You want to commit changes back
- ✅ Repository size is reasonable
- ✅ Git is already installed

### Use **REST API** when:
- ✅ You only need source code snapshot
- ✅ Git is not available
- ✅ You want the smallest download
- ✅ You're doing automated analysis
- ✅ You don't need git features

### Use **Azure CLI** when:
- ✅ You're already using Azure CLI
- ✅ You want Azure AD integration
- ✅ You need git history
- ✅ You prefer Microsoft's official tools
- ✅ You work in Azure-integrated environments

## 📊 Performance Comparison

Based on a typical 100MB repository with 1000 commits:

| Method | Download Time | Disk Space | Includes History |
|--------|--------------|------------|------------------|
| **Git Clone** | ~30 seconds | ~150MB | ✅ Yes |
| **REST API** | ~45 seconds | ~50MB | ❌ No |
| **Azure CLI** | ~30 seconds | ~150MB | ✅ Yes |

*Times are approximate and depend on network speed and repository characteristics.*

## 📄 License

MIT License

Copyright (c) 2025 François-Xavier Kim

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## 👨‍💻 Author

**François-Xavier Kim**

This script is provided "as is", without warranty of any kind. Use at your own risk.

## 🤝 Contributing

Feel free to enhance this script! Common improvements:
- Add support for SSH URLs
- Implement parallel downloads
- Add progress bars for large downloads
- Support for sparse checkout (Git)
- Retry logic for network failures
