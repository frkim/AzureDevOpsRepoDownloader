# Azure DevOps Repository Downloader - Cheat Sheet

## 🚀 Quick Commands

### Git Clone (Default - Recommended)
```powershell
.\Download-ADORepositories.ps1 -RepositoryListFile "repos.txt" -PersonalAccessToken "your-pat"
```

### REST API (No Git Needed)
```powershell
.\Download-ADORepositories.ps1 -RepositoryListFile "repos.txt" -Method "RestAPI" -PersonalAccessToken "your-pat"
```

### Azure CLI (Enterprise)
```powershell
.\Download-ADORepositories.ps1 -RepositoryListFile "repos.txt" -Method "AzureCLI" -PersonalAccessToken "your-pat"
```

---

## 📋 Common Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `-Method` | Download method | `"Git"`, `"RestAPI"`, `"AzureCLI"` |
| `-RepositoryListFile` | File with repo URLs | `"repos.txt"` |
| `-RepositoryUrls` | Array of URLs | `@("url1", "url2")` |
| `-PersonalAccessToken` | Your PAT | `"abc123..."` |
| `-DestinationPath` | Where to save | `"C:\Repos"` |
| `-Branch` | Specific branch | `"develop"` |
| `-CreateZipArchive` | Create ZIPs | (switch) |
| `-CleanupGitFolder` | Remove .git in ZIP | (switch) |

---

## 🎯 Method Selection Guide

| Need | Use Method |
|------|-----------|
| Full git history | **Git Clone** or **Azure CLI** |
| No Git installed | **REST API** |
| Smallest download | **REST API** |
| Azure AD / SSO | **Azure CLI** |
| Fastest | **Git Clone** |
| Simplest setup | **REST API** |

---

## 🔐 Authentication

### Get Personal Access Token (PAT)
1. Go to: `https://dev.azure.com/{org}/_usersSettings/tokens`
2. Click **"+ New Token"**
3. Select scope: **Code (Read)**
4. Copy token

### Store Securely
```powershell
# Set environment variable
$env:ADO_PAT = "your-pat-token"

# Use in script
.\Download-ADORepositories.ps1 -RepositoryListFile "repos.txt" -PersonalAccessToken $env:ADO_PAT
```

---

## 📂 Repository List Format

Create `repos.txt`:
```text
# Production
https://dev.azure.com/org/project/_git/repo1
https://dev.azure.com/org/project/_git/repo2

# Development
https://dev.azure.com/org/project/_git/repo3
```

---

## 💡 Common Scenarios

### Scenario: Daily Development
```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "Git"
```

### Scenario: Code Review / Snapshot
```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "RestAPI" `
    -PersonalAccessToken $env:ADO_PAT
```

### Scenario: Create Backups
```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "Git" `
    -CreateZipArchive `
    -PersonalAccessToken $env:ADO_PAT
```

### Scenario: Specific Branch
```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryUrls @("https://dev.azure.com/org/proj/_git/repo") `
    -Branch "release/v1.0" `
    -PersonalAccessToken $env:ADO_PAT
```

### Scenario: Custom Location
```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -DestinationPath "C:\Projects\Repos" `
    -PersonalAccessToken $env:ADO_PAT
```

---

## 🔧 Prerequisites by Method

### Git Clone
- ✅ Git: https://git-scm.com/downloads
- ✅ PowerShell 5.1+

### REST API
- ✅ PowerShell 5.1+ (already on Windows 10+)
- ✅ PAT token (required)

### Azure CLI
- ✅ Azure CLI: https://aka.ms/installazurecliwindows
- ✅ Extension: `az extension add --name azure-devops`
- ✅ PowerShell 5.1+

---

## ⚡ Quick Checks

```powershell
# Check PowerShell version
$PSVersionTable.PSVersion

# Check Git
git --version

# Check Azure CLI
az --version

# Check if script prerequisites are met (it checks automatically!)
.\Download-ADORepositories.ps1 -RepositoryUrls @("test") -Method "Git"
```

---

## 🐛 Quick Fixes

### Error: Missing Prerequisites
**Fix**: Install the missing tool (script shows instructions)

### Error: Authentication Required
**Fix**: Add `-PersonalAccessToken "your-pat"`

### Error: Directory Already Exists
**Fix**: Delete the directory or change `-DestinationPath`

### Error: Git Not Found
**Fix**: Install Git from https://git-scm.com/downloads

### Error: Invalid URL
**Fix**: Check URL format:
```
https://dev.azure.com/{org}/{project}/_git/{repo}
```

---

## 📊 Method Comparison

| Feature | Git | REST API | Azure CLI |
|---------|:---:|:--------:|:---------:|
| Speed | ⚡⚡⚡ | ⚡⚡ | ⚡⚡⚡ |
| Setup | 🟢 Easy | 🟢 Easy | 🟡 Medium |
| Git History | ✅ | ❌ | ✅ |
| No Dependencies | ❌ | ✅ | ❌ |
| Azure AD/SSO | ❌ | ❌ | ✅ |

---

## 📱 Output Examples

### Standard Output
```
downloads/
├── repo1/
├── repo2/
└── repo3/
```

### ZIP Output
```
downloads/
├── repo1.zip
├── repo2.zip
└── repo3.zip
```

---

## 🎓 Learning Resources

- **Quick Start**: `QUICK-START.md`
- **Full Docs**: `README.md`
- **Method Guide**: `METHOD-COMPARISON.md`
- **This Index**: `INDEX.md`

---

## 💾 Save This!

Print or bookmark this cheat sheet for quick reference!

---

**Pro Tip**: Start with REST API if you're new - it's the simplest!

```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "RestAPI" `
    -PersonalAccessToken "your-pat"
```

---

## 📄 License

**MIT License** | Author: **François-Xavier Kim**

⚠️ **Disclaimer**: Provided "as is", without warranty of any kind. Use at your own risk.
