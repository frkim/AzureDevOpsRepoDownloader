# Script Workflow and Architecture

This document explains how the Azure DevOps Repository Downloader works internally.

## 🔄 High-Level Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER INPUT                              │
│  - Repository URLs or File List                                 │
│  - Download Method (Git/RestAPI/AzureCLI)                      │
│  - Authentication (PAT)                                         │
│  - Output Options (ZIP/Directory)                               │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PREREQUISITE CHECK                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐   │
│  │  Git        │  │  Azure CLI  │  │  PowerShell         │   │
│  │  Method?    │  │  Method?    │  │  5.1+ (Always)      │   │
│  │  Check Git  │  │  Check CLI  │  │  ✓ Present          │   │
│  └──────┬──────┘  └──────┬──────┘  └──────────────────────┘   │
│         │                 │                                      │
│    ┌────▼────┐       ┌───▼────┐                                │
│    │ Missing? │       │Missing?│                                │
│    └────┬────┘       └───┬────┘                                │
│         │ Yes            │ Yes                                  │
│         ▼                ▼                                       │
│    Show Friendly Error Message with Installation Instructions   │
└────────────────────────────┬────────────────────────────────────┘
                             │ All OK
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   PARSE REPOSITORY LIST                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Read URLs from:                                          │  │
│  │  - Command line parameter (-RepositoryUrls), OR           │  │
│  │  - File (-RepositoryListFile)                            │  │
│  │                                                            │  │
│  │  For each URL:                                            │  │
│  │  1. Parse organization name                              │  │
│  │  2. Parse project name                                   │  │
│  │  3. Parse repository name                                │  │
│  │  4. Validate URL format                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                  PREPARE DESTINATION                            │
│  - Create destination directory if not exists                   │
│  - Resolve full path                                            │
│  - Initialize result tracking                                   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
        ┌────────────────────┴────────────────────┐
        │     FOR EACH REPOSITORY IN LIST         │
        └────────────────────┬────────────────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
            ▼                ▼                ▼
    ┌──────────────┐ ┌─────────────┐ ┌──────────────┐
    │ Git Method   │ │ REST API    │ │ Azure CLI    │
    │              │ │ Method      │ │ Method       │
    └──────┬───────┘ └──────┬──────┘ └──────┬───────┘
           │                │                │
           └────────────────┼────────────────┘
                            │
                            ▼
    ┌─────────────────────────────────────────────┐
    │        Download Using Selected Method       │
    │  - Authenticate with PAT or credentials     │
    │  - Handle branch selection if specified     │
    │  - Download to repository-named directory   │
    │  - Track success/failure                    │
    └──────────────────┬──────────────────────────┘
                       │
                       ▼
            ┌──────────────────┐
            │   Success?       │
            └─────┬────────┬───┘
                  │ Yes    │ No
                  │        │
         ┌────────▼────┐   │
         │ Create ZIP? │   │
         └────┬────┬───┘   │
              │Yes │No     │
              │    │       │
    ┌─────────▼──┐ │       │
    │ Create ZIP │ │       │
    │ Remove Dir │ │       │
    └─────────┬──┘ │       │
              │    │       │
              └────┴───────┴──────────┐
                                      │
                                      ▼
                         ┌────────────────────────┐
                         │  Record Result         │
                         │  - Success/Failure     │
                         │  - Path                │
                         │  - Error message       │
                         └────────┬───────────────┘
                                  │
                                  ▼
                      ┌─────────────────────┐
                      │  More repositories? │
                      └───────┬─────────┬───┘
                          Yes │         │ No
                  ┌───────────┘         │
                  │                     │
                  │                     ▼
                  │         ┌────────────────────────┐
                  │         │   GENERATE SUMMARY     │
                  │         │  - Total processed     │
                  │         │  - Success count       │
                  │         │  - Failure count       │
                  │         │  - List of results     │
                  │         └────────────────────────┘
                  │                     │
                  │                     ▼
                  │              ┌──────────────┐
                  │              │  Display to  │
                  │              │  User        │
                  │              └──────────────┘
                  │                     │
                  └─────────────────────┘
```

---

## 📊 Method-Specific Workflows

### Git Clone Method

```
┌──────────────────────────────────────┐
│   Git Clone Method Selected          │
└────────────────┬─────────────────────┘
                 │
                 ▼
        ┌────────────────┐
        │  Check if Git  │
        │  is installed  │
        └────────┬───────┘
                 │
     ┌───────────┼───────────┐
     │ Yes                   │ No
     ▼                       ▼
┌─────────────┐      ┌───────────────────┐
│  Continue   │      │  Show Error with  │
│             │      │  Install Guide    │
└──────┬──────┘      └───────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  Build Authenticated Git URL         │
│  - Insert PAT if provided            │
│  - Or use credential manager         │
└────────────────┬─────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────┐
│  Execute Git Clone Command           │
│  git clone [--branch X] <url> <path> │
└────────────────┬─────────────────────┘
                 │
     ┌───────────┼───────────┐
     │ Success               │ Failure
     ▼                       ▼
┌─────────────┐      ┌───────────────────┐
│  Directory  │      │  Return error     │
│  with .git/ │      │  Log details      │
└──────┬──────┘      └───────────────────┘
       │
       ▼ (if CreateZipArchive)
┌──────────────────────────────────────┐
│  Optionally remove .git folder       │
│  Create ZIP archive                  │
│  Remove original directory           │
└──────────────────────────────────────┘
```

### REST API Method

```
┌──────────────────────────────────────┐
│   REST API Method Selected           │
└────────────────┬─────────────────────┘
                 │
                 ▼
        ┌────────────────┐
        │  Check for PAT │
        │  (Required!)   │
        └────────┬───────┘
                 │
     ┌───────────┼───────────┐
     │ Present               │ Missing
     ▼                       ▼
┌─────────────┐      ┌───────────────────┐
│  Continue   │      │  Show Auth Error  │
│             │      │  with PAT Guide   │
└──────┬──────┘      └───────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  Get Repository Information          │
│  API: GET /repositories/{repo}       │
│  - Get default branch if needed      │
└────────────────┬─────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────┐
│  Download ZIP via API                │
│  API: GET /items?format=zip          │
│  - Downloads source code only        │
│  - No git history                    │
└────────────────┬─────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────┐
│  Extract ZIP to Directory            │
└────────────────┬─────────────────────┘
                 │
     ┌───────────┼───────────┐
     │ CreateZipArchive?     │
     │ Yes                   │ No
     ▼                       ▼
┌─────────────┐      ┌───────────────────┐
│  Keep ZIP   │      │  Delete ZIP       │
│  Delete Dir │      │  Keep extracted   │
└─────────────┘      └───────────────────┘
```

### Azure CLI Method

```
┌──────────────────────────────────────┐
│   Azure CLI Method Selected          │
└────────────────┬─────────────────────┘
                 │
                 ▼
        ┌────────────────┐
        │  Check if az   │
        │  is installed  │
        └────────┬───────┘
                 │
     ┌───────────┼───────────┐
     │ Yes                   │ No
     ▼                       ▼
┌─────────────┐      ┌───────────────────┐
│  Check for  │      │  Show Error with  │
│  devops ext │      │  Install Guide    │
└──────┬──────┘      └───────────────────┘
       │
   ┌───┼───┐
   │Present│ Missing
   ▼       ▼
┌─────┐  ┌────────────────┐
│ OK  │  │ Show Extension │
│     │  │ Install Guide  │
└──┬──┘  └────────────────┘
   │
   ▼
┌──────────────────────────────────────┐
│  Set PAT in Environment              │
│  (if provided)                       │
└────────────────┬─────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────┐
│  Configure Organization & Project    │
│  az devops configure --defaults      │
└────────────────┬─────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────┐
│  Execute az repos clone              │
│  (Uses git under the hood)           │
└────────────────┬─────────────────────┘
                 │
     ┌───────────┼───────────┐
     │ Success               │ Failure
     ▼                       ▼
┌─────────────┐      ┌───────────────────┐
│  Directory  │      │  Return error     │
│  with .git/ │      │  Log details      │
└─────────────┘      └───────────────────┘
```

---

## 🔐 Authentication Flow

```
┌──────────────────────────────────────┐
│       Authentication Required        │
└────────────────┬─────────────────────┘
                 │
        ┌────────┴────────┐
        │  Method Type?   │
        └────────┬────────┘
                 │
     ┌───────────┼───────────┬──────────┐
     │           │           │          │
     ▼           ▼           ▼          ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌──────────┐
│   Git   │ │REST API │ │Azure CLI│ │Azure CLI │
│with PAT │ │         │ │with PAT │ │with Login│
└────┬────┘ └────┬────┘ └────┬────┘ └────┬─────┘
     │           │           │           │
     ▼           ▼           ▼           ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌──────────┐
│Insert   │ │Basic    │ │Set ENV  │ │az login  │
│PAT in   │ │Auth     │ │variable │ │(Azure AD)│
│Git URL  │ │header   │ │         │ │          │
└────┬────┘ └────┬────┘ └────┬────┘ └────┬─────┘
     │           │           │           │
     └───────────┴───────────┴───────────┘
                 │
                 ▼
        ┌────────────────┐
        │  Authenticated │
        │  Request       │
        └────────────────┘
```

---

## 📦 Output Processing Flow

```
┌──────────────────────────────────────┐
│    Repository Downloaded             │
│    (in temporary/final location)     │
└────────────────┬─────────────────────┘
                 │
        ┌────────┴────────┐
        │ CreateZipArchive│
        │  Parameter?     │
        └────────┬────────┘
                 │
     ┌───────────┼───────────┐
     │ YES                   │ NO
     ▼                       ▼
┌─────────────────────┐ ┌────────────────┐
│ Process for ZIP     │ │ Keep as is     │
└──────────┬──────────┘ └────────────────┘
           │
           ▼
    ┌──────────────┐
    │ Method Type? │
    └──────┬───────┘
           │
   ┌───────┼────────┬──────────┐
   │       │        │          │
   ▼       ▼        ▼          │
┌────┐ ┌────────┐ ┌─────────┐ │
│Git │ │RestAPI │ │Az CLI   │ │
└─┬──┘ └───┬────┘ └────┬────┘ │
  │        │           │       │
  ▼        ▼           ▼       │
┌────────────────────────────┐ │
│   CleanupGitFolder?        │ │
└────────┬───────────────────┘ │
         │                     │
  ┌──────┼──────┐             │
  │YES         │NO            │
  ▼            ▼              │
┌──────┐   ┌────────┐         │
│Remove│   │Keep all│         │
│.git/ │   │files   │         │
└──┬───┘   └───┬────┘         │
   │           │              │
   └───────────┴──────────────┘
               │
               ▼
    ┌────────────────────┐
    │  Compress to ZIP   │
    │  reponame.zip      │
    └──────────┬─────────┘
               │
               ▼
    ┌────────────────────┐
    │  Remove original   │
    │  directory         │
    └────────────────────┘
```

---

## 🔍 Error Handling Flow

```
┌──────────────────────────────────────┐
│        Operation Attempted           │
└────────────────┬─────────────────────┘
                 │
        ┌────────┴────────┐
        │    Success?     │
        └────────┬────────┘
                 │
     ┌───────────┼───────────┐
     │ YES                   │ NO
     ▼                       ▼
┌─────────────┐      ┌──────────────────┐
│  Record     │      │  Error Type?     │
│  Success    │      └────────┬─────────┘
└─────────────┘               │
                    ┌─────────┼─────────┬──────────┐
                    │         │         │          │
                    ▼         ▼         ▼          ▼
            ┌──────────┐ ┌────────┐ ┌────────┐ ┌──────────┐
            │ Missing  │ │ Auth   │ │Network │ │Directory │
            │ Prereq   │ │ Failed │ │ Error  │ │ Exists   │
            └────┬─────┘ └───┬────┘ └───┬────┘ └────┬─────┘
                 │           │          │           │
                 ▼           ▼          ▼           ▼
            ┌──────────────────────────────────────────┐
            │      Show Friendly Error Message         │
            │      with Specific Solution              │
            └──────────────────┬───────────────────────┘
                               │
                               ▼
                    ┌────────────────────┐
                    │  Record Failure    │
                    │  - Error message   │
                    │  - Repository name │
                    │  - Reason          │
                    └────────┬───────────┘
                             │
                             ▼
                    ┌────────────────────┐
                    │  Continue to next  │
                    │  repository        │
                    └────────────────────┘
```

---

## 📊 Data Structures

### Repository Information Object
```powershell
@{
    Organization = "myorg"
    Project = "myproject"
    Repository = "myrepo"
    Url = "https://dev.azure.com/myorg/myproject/_git/myrepo"
    IsValid = $true
}
```

### Result Object
```powershell
@{
    Url = "https://..."
    Repository = "myrepo"
    Success = $true/$false
    Type = "Repository"/"Archive"
    Path = "C:\repos\myrepo"
    Error = "Error message if failed"
    Reason = "AlreadyExists"/"InvalidUrl"/etc.
}
```

---

## 🎯 Function Architecture

```
Download-ADORepositories.ps1
│
├── Validation Functions
│   ├── Test-GitInstalled()
│   ├── Test-AzureCLIInstalled()
│   ├── Test-AzureDevOpsExtension()
│   ├── Test-MethodPrerequisites()
│   └── Show-PrerequisiteError()
│
├── Parsing Functions
│   └── Get-RepositoryInfo()
│
├── Authentication Functions
│   └── Get-AuthenticatedGitUrl()
│
├── Download Functions
│   ├── Invoke-RepositoryClone()      # Git method
│   ├── Invoke-RestAPIDownload()      # REST API method
│   └── Invoke-AzureCLIDownload()     # Azure CLI method
│
├── Output Processing Functions
│   └── New-RepositoryArchive()
│
└── Main Execution Flow
    ├── Validate prerequisites
    ├── Parse input
    ├── Prepare destination
    ├── Process repositories
    └── Generate summary
```

---

## 💻 Example Execution Trace

```
User Command:
.\Download-ADORepositories.ps1 -RepositoryListFile "repos.txt" -Method "Git"

Execution Steps:
1. Parse parameters ✓
2. Display banner ✓
3. Check prerequisites
   - Test-MethodPrerequisites("Git")
   - Check Git installed... ✓
4. Read repository list
   - Get-Content "repos.txt"
   - Filter empty lines
   - Found 3 URLs ✓
5. Create destination directory ✓
6. Process Repository 1
   - Get-RepositoryInfo() → Parse URL ✓
   - Invoke-RepositoryClone()
     - Check directory exists... No ✓
     - Build git URL with auth ✓
     - Execute: git clone ... ✓
     - Clone succeeded ✓
   - Record success ✓
7. Process Repository 2
   - Get-RepositoryInfo() → Parse URL ✓
   - Invoke-RepositoryClone()
     - Check directory exists... Yes ⚠
     - Skip (directory exists) ⚠
   - Record skipped ⚠
8. Process Repository 3
   - Get-RepositoryInfo() → Parse URL ✓
   - Invoke-RepositoryClone()
     - Check directory exists... No ✓
     - Build git URL with auth ✓
     - Execute: git clone ... ✓
     - Clone succeeded ✓
   - Record success ✓
9. Generate summary
   - Total: 3
   - Success: 2
   - Failed: 1 (already exists)
10. Display results ✓
```

---

## 🔄 State Transitions

```
NOT STARTED
    │
    ├─→ VALIDATING PREREQUISITES
    │       │
    │       ├─→ [FAILED] → SHOW ERROR → EXIT
    │       └─→ [PASSED]
    │               │
    ├───────────────┘
    │
    ├─→ PARSING INPUT
    │       │
    │       ├─→ [INVALID] → SHOW ERROR → EXIT
    │       └─→ [VALID]
    │               │
    ├───────────────┘
    │
    ├─→ DOWNLOADING (per repo)
    │       │
    │       ├─→ [SUCCESS] → (Optional: CREATE ZIP)
    │       └─→ [FAILED] → RECORD ERROR
    │               │
    ├───────────────┘
    │
    └─→ GENERATING SUMMARY → DISPLAY → COMPLETE
```

---

This architecture ensures:
- ✅ Clear separation of concerns
- ✅ Robust error handling
- ✅ User-friendly feedback
- ✅ Flexible method selection
- ✅ Maintainable code structure
