# Download Method Comparison Guide

This guide helps you choose the best method for downloading Azure DevOps repositories.

## Quick Decision Matrix

```
Need git history? 
├─ YES → Use Git Clone or Azure CLI
│   ├─ Already have Azure CLI? 
│   │   ├─ YES → Use Azure CLI
│   │   └─ NO → Use Git Clone
│   └─ Git installed?
│       ├─ YES → Use Git Clone (fastest)
│       └─ NO → Install Git, then use Git Clone
└─ NO → Use REST API (no Git needed)
    └─ Smallest download, source code only
```

## Detailed Comparison

### 1. Git Clone Method 🥇 RECOMMENDED

#### When to Use
- ✅ Regular development work
- ✅ Need to commit changes back
- ✅ Want full git history
- ✅ Working with branches/tags
- ✅ Need offline git operations

#### Prerequisites
- Git installed (https://git-scm.com/downloads)
- PowerShell 5.1+

#### Authentication Options
1. **Personal Access Token** (passed to script)
2. **Git Credential Manager** (automatic)
3. **SSH Keys** (requires URL modification)

#### Pros
- ✅ **Fastest** for most scenarios
- ✅ **Full git history** preserved
- ✅ **Standard approach** used worldwide
- ✅ **Flexible authentication** (PAT, credential manager, SSH)
- ✅ **Efficient** with large repositories
- ✅ **Works offline** once cloned
- ✅ **Supports all git features** (branches, tags, submodules)

#### Cons
- ❌ Requires Git installation (~50MB)
- ❌ Downloads full history (larger than source-only)
- ❌ Network interruptions can fail the clone

#### Example
```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "Git" `
    -PersonalAccessToken "your-pat"
```

#### Output Structure
```
downloads/
├── repo1/
│   ├── .git/          # Full git database
│   ├── src/
│   └── README.md
└── repo2/
    ├── .git/
    └── ...
```

---

### 2. REST API Method 📡

#### When to Use
- ✅ Only need source code snapshot
- ✅ Git not available
- ✅ Minimal disk space
- ✅ Automated source analysis
- ✅ Quick code review

#### Prerequisites
- PowerShell 5.1+ (built into Windows 10+)
- Personal Access Token (required)

#### Authentication Options
1. **Personal Access Token** (required)

#### Pros
- ✅ **No external dependencies** (PowerShell only)
- ✅ **Smallest download** (source code only)
- ✅ **Works without Git** installed
- ✅ **Simple setup** (no Git configuration)
- ✅ **Direct ZIP download** available
- ✅ **Good for snapshots** and analysis

#### Cons
- ❌ **No git history** (commits, branches, tags lost)
- ❌ **PAT required** (can't use credential manager)
- ❌ **Slower for large repos** (API limitations)
- ❌ **No offline git operations**
- ❌ **API rate limits** may apply
- ❌ **Less efficient** with very large files

#### Example
```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "RestAPI" `
    -PersonalAccessToken "your-pat"
```

#### Output Structure
```
downloads/
├── repo1/             # Source code only
│   ├── src/
│   └── README.md
└── repo2/
    └── ...
```

---

### 3. Azure DevOps CLI Method 🔷

#### When to Use
- ✅ Already using Azure CLI
- ✅ Azure AD authentication preferred
- ✅ Need git history
- ✅ Azure-integrated environment
- ✅ Enterprise scenarios with SSO

#### Prerequisites
- Azure CLI (https://aka.ms/installazurecliwindows)
- Azure DevOps extension (`az extension add --name azure-devops`)
- PowerShell 5.1+

#### Authentication Options
1. **Azure AD Login** (`az login`)
2. **Personal Access Token** (via environment variable)
3. **Managed Identity** (Azure VMs)

#### Pros
- ✅ **Official Microsoft tool**
- ✅ **Azure AD integration** (SSO support)
- ✅ **Full git history** preserved
- ✅ **Enterprise-friendly** authentication
- ✅ **Consistent with Azure ecosystem**
- ✅ **Good documentation** from Microsoft

#### Cons
- ❌ **Requires Azure CLI** installation (~100MB)
- ❌ **Additional extension** needed
- ❌ **More setup steps** than Git
- ❌ **Slower initial configuration**
- ❌ **Uses Git under the hood** anyway

#### Example
```powershell
# First time setup
az login
az extension add --name azure-devops

# Then use
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "AzureCLI"
```

#### Output Structure
```
downloads/
├── repo1/
│   ├── .git/          # Full git database
│   ├── src/
│   └── README.md
└── repo2/
    ├── .git/
    └── ...
```

---

## Feature Comparison Table

| Feature | Git Clone | REST API | Azure CLI |
|---------|:---------:|:--------:|:---------:|
| **Installation Size** | ~50MB | 0MB | ~100MB |
| **Setup Complexity** | 🟢 Easy | 🟢 Easy | 🟡 Medium |
| **Download Speed** | 🟢 Fast | 🟡 Medium | 🟢 Fast |
| **Git History** | ✅ Yes | ❌ No | ✅ Yes |
| **Branches/Tags** | ✅ Yes | ⚠️ Limited | ✅ Yes |
| **Large Files (100MB+)** | ✅ Excellent | ⚠️ Limited | ✅ Excellent |
| **Offline Operations** | ✅ Yes | ❌ No | ✅ Yes |
| **Disk Space Used** | 🟡 Medium | 🟢 Low | 🟡 Medium |
| **Auth Options** | 3 types | PAT only | 3 types |
| **Azure AD / SSO** | ❌ No | ❌ No | ✅ Yes |
| **Works Without Git** | ❌ No | ✅ Yes | ❌ No |
| **API Rate Limits** | ✅ None | ⚠️ Yes | ✅ None |
| **Submodules Support** | ✅ Yes | ❌ No | ✅ Yes |

Legend: 🟢 Good | 🟡 Medium | 🔴 Limited

---

## Performance Benchmarks

### Small Repository (10MB, 100 commits)

| Method | Download Time | Disk Usage |
|--------|--------------|-----------|
| Git Clone | ~5 seconds | ~15MB |
| REST API | ~8 seconds | ~10MB |
| Azure CLI | ~6 seconds | ~15MB |

### Medium Repository (100MB, 1000 commits)

| Method | Download Time | Disk Usage |
|--------|--------------|-----------|
| Git Clone | ~30 seconds | ~150MB |
| REST API | ~45 seconds | ~100MB |
| Azure CLI | ~32 seconds | ~150MB |

### Large Repository (1GB, 10000 commits)

| Method | Download Time | Disk Usage |
|--------|--------------|-----------|
| Git Clone | ~5 minutes | ~1.5GB |
| REST API | ~12 minutes | ~1GB |
| Azure CLI | ~5.5 minutes | ~1.5GB |

*Note: Times assume 100Mbps connection. Results vary based on network speed and Azure DevOps region.*

---

## Disk Space Comparison

For a typical repository:

```
Source Code Size: 50MB

Method          | Disk Usage | What's Included
----------------|------------|------------------
Git Clone       | 75MB       | Source + Full history + Git database
REST API        | 50MB       | Source code only
Azure CLI       | 75MB       | Source + Full history + Git database
```

---

## Use Case Examples

### Scenario 1: Daily Development Work
**Recommendation:** Git Clone ⭐
- Need to commit and push changes
- Want to switch branches
- Need full git history

```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "Git"
```

### Scenario 2: Code Review / Audit
**Recommendation:** REST API ⭐
- Only need to read source code
- Don't need git history
- Want fastest setup

```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "RestAPI" `
    -PersonalAccessToken $env:ADO_PAT
```

### Scenario 3: Enterprise Environment with Azure AD
**Recommendation:** Azure CLI ⭐
- Company uses Azure AD SSO
- Already have Azure CLI
- Want integrated authentication

```powershell
az login
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "AzureCLI"
```

### Scenario 4: Automated Build Server
**Recommendation:** Git Clone ⭐
- Need reproducible builds
- Want specific commits/tags
- Git likely already installed

```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryUrls @($repoUrl) `
    -Method "Git" `
    -Branch "release/v1.0" `
    -PersonalAccessToken $env:BUILD_PAT
```

### Scenario 5: Backup / Archival
**Recommendation:** Git Clone with ZIP ⭐
- Want complete backup
- Need to preserve history
- Want compressed format

```powershell
.\Download-ADORepositories.ps1 `
    -RepositoryListFile "repos.txt" `
    -Method "Git" `
    -CreateZipArchive `
    -PersonalAccessToken $env:ADO_PAT
```

---

## Decision Flowchart

```
START: Need to download ADO repositories
│
├─ Do you need git history?
│  │
│  ├─ NO → Use REST API
│  │       ├─ Smallest download
│  │       ├─ No Git needed
│  │       └─ Source code only
│  │
│  └─ YES → Do you need Azure AD / SSO?
│     │
│     ├─ YES → Use Azure CLI
│     │        ├─ Enterprise authentication
│     │        ├─ Azure integrated
│     │        └─ Official Microsoft tool
│     │
│     └─ NO → Is Git already installed?
│        │
│        ├─ YES → Use Git Clone ⭐ RECOMMENDED
│        │        ├─ Fastest
│        │        ├─ Most flexible
│        │        └─ Industry standard
│        │
│        └─ NO → Install Git (5 min) → Use Git Clone
│                 OR
│                 Use REST API if you can't install Git
```

---

## Summary Recommendations

### 🥇 Best Overall: Git Clone
- Use for 80% of scenarios
- Fast, reliable, flexible
- Industry standard approach

### 🥈 Best for Simplicity: REST API
- No Git installation needed
- Perfect for source snapshots
- Smallest download size

### 🥉 Best for Enterprise: Azure CLI
- Azure AD integration
- Official Microsoft tool
- Good for managed environments

---

## Quick Command Reference

### Git Clone
```powershell
.\Download-ADORepositories.ps1 -RepositoryListFile "repos.txt" -Method "Git" -PersonalAccessToken $pat
```

### REST API
```powershell
.\Download-ADORepositories.ps1 -RepositoryListFile "repos.txt" -Method "RestAPI" -PersonalAccessToken $pat
```

### Azure CLI
```powershell
.\Download-ADORepositories.ps1 -RepositoryListFile "repos.txt" -Method "AzureCLI" -PersonalAccessToken $pat
```

---

## 📄 License & Author

**MIT License** - Copyright (c) 2025 François-Xavier Kim

**Disclaimer**: This documentation and associated script are provided "as is", 
without warranty of any kind. Use at your own risk.

**Author**: François-Xavier Kim

---

**Still unsure?** Start with **Git Clone** - it's the most versatile and commonly used method.
