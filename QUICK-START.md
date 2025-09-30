# Quick Start Guide 🚀

Get started downloading Azure DevOps repositories in under 5 minutes!

## ⚡ Super Quick Start (3 steps)

### Step 1: Get Your Personal Access Token (PAT)

1. Go to: `https://dev.azure.com/{your-organization}/_usersSettings/tokens`
2. Click **"+ New Token"**
3. Give it a name (e.g., "Repo Downloader")
4. Select scope: **Code (Read)**
5. Click **"Create"** and **copy the token**

### Step 2: Create Your Repository List

Create a file named `repos.txt`:
```
https://dev.azure.com/myorg/project1/_git/repository1
https://dev.azure.com/myorg/project2/_git/repository2
https://dev.azure.com/myorg/project3/_git/repository3
```

### Step 3: Run the Script

```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -PersonalAccessToken "your-pat-token-here"
```

**Done!** Your repositories are now in the current directory.

---

## 📋 Prerequisites Check

Run this to check what you have installed:

```powershell
# Check PowerShell version
$PSVersionTable.PSVersion

# Check Git
git --version

# Check Azure CLI
az --version
```

### What You Need (depends on method)

#### For Git Method (Default) ✅ Recommended
- ✅ PowerShell 5.1+ (already on Windows 10+)
- ✅ Git: [Download here](https://git-scm.com/downloads) (~5 min install)

#### For REST API Method (Simplest)
- ✅ PowerShell 5.1+ (already on Windows 10+)
- ✅ That's it! No other software needed.

#### For Azure CLI Method
- ✅ PowerShell 5.1+ (already on Windows 10+)
- ✅ Azure CLI: [Download here](https://aka.ms/installazurecliwindows) (~10 min install)
- ✅ Extension: `az extension add --name azure-devops`

---

## 🎯 Common Scenarios

### Scenario 1: Just Started, Don't Have Git

Use REST API method (no Git needed):

```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "RestAPI" `
    -PersonalAccessToken "your-pat-token-here"
```

### Scenario 2: Have Git, Want Full History

Use Git method (default, fastest):

```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -PersonalAccessToken "your-pat-token-here"
```

### Scenario 3: Want ZIP Files

Use any method with `-CreateZipArchive`:

```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -CreateZipArchive `
    -PersonalAccessToken "your-pat-token-here"
```

### Scenario 4: Specific Branch

Any method supports branch selection:

```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Branch "develop" `
    -PersonalAccessToken "your-pat-token-here"
```

### Scenario 5: Single Repository

Use `-RepositoryUrls` instead of file:

```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryUrls @("https://dev.azure.com/myorg/project/_git/repo") `
    -PersonalAccessToken "your-pat-token-here"
```

### Scenario 6: Custom Destination

Specify where to save:

```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -DestinationPath "C:\MyRepos" `
    -PersonalAccessToken "your-pat-token-here"
```

---

## 🛠️ Installation Guides

### Installing Git (Method 1)

1. **Download**: Go to https://git-scm.com/downloads
2. **Run installer**: Keep all default settings
3. **Restart** your PowerShell window
4. **Verify**: Run `git --version`

**Time required**: ~5 minutes

### Installing Azure CLI (Method 3)

1. **Download**: Go to https://aka.ms/installazurecliwindows
2. **Run MSI installer**: Keep all default settings
3. **Restart** your PowerShell window
4. **Install extension**:
   ```powershell
   az extension add --name azure-devops
   ```
5. **Login** (optional):
   ```powershell
   az login
   ```
6. **Verify**: Run `az --version`

**Time required**: ~10 minutes

---

## 🔐 Secure PAT Storage (Recommended)

Instead of putting your PAT in the command, store it securely:

### Option 1: Environment Variable (Recommended)

```powershell
# Set once per session
$env:ADO_PAT = "your-pat-token-here"

# Use in scripts
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -PersonalAccessToken $env:ADO_PAT
```

### Option 2: Prompt for PAT

```powershell
$pat = Read-Host -Prompt "Enter your PAT" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pat)
$plainPat = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -PersonalAccessToken $plainPat
```

---

## 📂 Understanding the Output

### Standard Output (Git/Azure CLI)

```
downloads/
├── repository1/
│   ├── .git/              # Git database (history, branches, etc.)
│   ├── src/
│   │   └── main.py
│   └── README.md
├── repository2/
│   ├── .git/
│   └── ...
└── repository3/
    ├── .git/
    └── ...
```

### REST API Output

```
downloads/
├── repository1/
│   ├── src/              # No .git folder!
│   │   └── main.py
│   └── README.md
├── repository2/
│   └── ...
└── repository3/
    └── ...
```

### ZIP Archive Output

```
downloads/
├── repository1.zip
├── repository2.zip
└── repository3.zip
```

---

## 🐛 Quick Troubleshooting

### "Missing Prerequisites" Error

**What you see:**
```
╔════════════════════════════════════════════════════════════════╗
║                   MISSING PREREQUISITES                        ║
╚════════════════════════════════════════════════════════════════╝
```

**Solution:** The script tells you exactly what's missing. Follow the displayed instructions.

### "Authentication Required" Error

**What you see:**
```
╔════════════════════════════════════════════════════════════════╗
║                   AUTHENTICATION REQUIRED                      ║
╚════════════════════════════════════════════════════════════════╝
```

**Solution:** 
- For REST API: Add `-PersonalAccessToken` parameter
- For Git: Add `-PersonalAccessToken` or setup Git Credential Manager
- For Azure CLI: Run `az login` first or add `-PersonalAccessToken`

### "Directory Already Exists" Warning

**What you see:**
```
WARNING: Directory 'C:\repos\myrepo' already exists. Skipping clone.
```

**Solution:** The script protects existing data. Either:
- Delete/rename the existing directory
- Change `-DestinationPath` to a new location

---

## 💡 Pro Tips

### Tip 1: Start with REST API

If you're unsure which method to use, start with REST API - it has no dependencies:

```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "RestAPI" `
    -PersonalAccessToken "your-pat"
```

### Tip 2: Test with One Repository First

Before downloading many repos, test with one:

```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryUrls @("https://dev.azure.com/org/proj/_git/test-repo") `
    -PersonalAccessToken "your-pat"
```

### Tip 3: Use Comments in Your Repo List

```txt
# Production repositories
https://dev.azure.com/myorg/prod/_git/api
https://dev.azure.com/myorg/prod/_git/web

# Development repositories
https://dev.azure.com/myorg/dev/_git/api
https://dev.azure.com/myorg/dev/_git/web
```

### Tip 4: Check What Will Be Downloaded

Open `repos.txt` in notepad before running:

```powershell
notepad repos.txt
```

### Tip 5: Create a Batch Script

Create `download-all.ps1`:

```powershell
$pat = $env:ADO_PAT
if (-not $pat) {
    Write-Error "Please set ADO_PAT environment variable"
    exit 1
}

.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "Git" `
    -DestinationPath ".\downloads" `
    -PersonalAccessToken $pat
```

Then just run:
```powershell
.\download-all.ps1
```

---

## 📚 Next Steps

1. ✅ **Read the comparison guide**: `METHOD-COMPARISON.md` - Understand which method is best for your needs
2. ✅ **Read the full README**: `README.md` - Complete documentation with all options
3. ✅ **Try different methods**: Experiment with Git, REST API, and Azure CLI
4. ✅ **Automate your workflow**: Create scripts for regular downloads

---

## ❓ Quick FAQ

**Q: Which method should I use?**  
A: Git Clone for most cases. REST API if Git isn't available. Azure CLI if you use Azure AD.

**Q: Do I need a PAT for Git method?**  
A: No, but recommended. Git can use Credential Manager without PAT.

**Q: Can I download private repositories?**  
A: Yes, with a valid PAT that has access.

**Q: How do I get multiple branches?**  
A: Download with Git method, then use git commands to checkout branches.

**Q: What if download fails halfway?**  
A: Re-run the script. It skips existing directories automatically.

**Q: Can I run this on Linux/Mac?**  
A: Yes! PowerShell Core works on all platforms.

**Q: How do I download a specific commit?**  
A: Use Git method, then run `git checkout <commit-hash>` after download.

---

## 🆘 Need Help?

1. **Check prerequisites**: Run the prerequisite check commands above
2. **Read error messages**: The script shows helpful error messages with solutions
3. **Try REST API method**: It's the simplest with fewest dependencies
4. **Check the full README**: `README.md` has detailed troubleshooting

---

**Ready to go?** Pick a scenario above and get started! 🚀
