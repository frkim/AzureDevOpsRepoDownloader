# How to Get Repository URLs from Azure DevOps

This guide shows you exactly how to get the correct repository URLs from Azure DevOps for use with the download script.

## 🎯 Quick Summary

**You need URLs in this format:**
```
https://dev.azure.com/{organization}/{project}/_git/{repository}
```

**Example:**
```
https://dev.azure.com/contoso/WebApplication/_git/Frontend
```

⚠️ **Important:** Remove any `username@` prefix if present!

---

## 📋 Method 1: From Clone Button (RECOMMENDED)

This is the fastest and most reliable method.

### Step-by-Step Instructions

1. **Open Azure DevOps** in your web browser
   - Go to: `https://dev.azure.com/{your-organization}`

2. **Navigate to your repository**
   - Click on **Repos** in the left menu
   - Click on **Files** (should be selected by default)
   - Make sure you're viewing the repository you want

3. **Click the Clone button**
   - Look for the **"Clone"** button in the top-right corner
   - It's next to the "..." menu button

4. **Copy the HTTPS URL**
   - A dialog box will appear
   - Make sure **HTTPS** is selected (not SSH)
   - Click the copy icon next to the URL

5. **⚠️ CRITICAL: Clean the URL**
   
   The URL Azure DevOps gives you might look like this:
   ```
   https://john.doe@dev.azure.com/contoso/WebApp/_git/Frontend
   ```
   
   **You MUST remove the `username@` part:**
   ```
   https://dev.azure.com/contoso/WebApp/_git/Frontend
   ```

### Visual Guide

```
┌─────────────────────────────────────────────────────────┐
│ Azure DevOps - Repository Page                         │
├─────────────────────────────────────────────────────────┤
│                                    [Clone] [... More]   │
│                                                         │
│  When you click [Clone]:                               │
│                                                         │
│  ┌────────────────────────────────────────────┐       │
│  │ Clone Repository                 [X]       │       │
│  ├────────────────────────────────────────────┤       │
│  │ HTTPS  SSH                                 │       │
│  │                                            │       │
│  │ https://user@dev.azure.com/org/...  [📋]  │  ← Copy this
│  │                                            │       │
│  │ ⚠️ Remove "user@" from the copied URL!    │       │
│  └────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────┘
```

---

## 📋 Method 2: From Browser Address Bar

### Step-by-Step Instructions

1. **Navigate to your repository**
   - Go to: **Repos** → **Files**

2. **Look at the browser address bar**
   
   You'll see something like:
   ```
   https://dev.azure.com/contoso/WebApp/_git/Frontend?path=/src&version=GBmain
   ```

3. **Extract the clean URL**
   
   Take everything up to (and including) the repository name:
   ```
   https://dev.azure.com/contoso/WebApp/_git/Frontend
   ```
   
   **Remove everything after `/_git/{repository}`** including:
   - `?path=...`
   - `?version=...`
   - `&...`
   - Any other query parameters

### Examples

| Browser URL (what you see) | Clean URL (what you need) |
|----------------------------|---------------------------|
| `https://dev.azure.com/contoso/WebApp/_git/Frontend?path=/src` | `https://dev.azure.com/contoso/WebApp/_git/Frontend` |
| `https://dev.azure.com/contoso/WebApp/_git/API?version=GBmain` | `https://dev.azure.com/contoso/WebApp/_git/API` |
| `https://dev.azure.com/fabrikam/Mobile/_git/iOS?path=/&version=GBdevelop` | `https://dev.azure.com/fabrikam/Mobile/_git/iOS` |

---

## 📋 Method 3: From Repository List

### Step-by-Step Instructions

1. **Go to the Repositories page**
   - Navigate to: **Organization** → **Project** → **Repos** → **Repositories**
   - Or click on the repository dropdown at the top

2. **Find your repository name**
   - All repositories in the project are listed here

3. **Construct the URL manually**
   
   Use this format:
   ```
   https://dev.azure.com/{organization}/{project}/_git/{repository}
   ```
   
   Fill in:
   - `{organization}`: Your organization name
   - `{project}`: The project name
   - `{repository}`: The repository name

### Example

If you see:
- Organization: `contoso`
- Project: `WebApplication`
- Repository: `Frontend`

The URL is:
```
https://dev.azure.com/contoso/WebApplication/_git/Frontend
```

---

## 📋 Method 4: From Project Settings

### Step-by-Step Instructions

1. **Go to Project Settings**
   - Click on **Project Settings** (gear icon at bottom left)

2. **Navigate to Repositories**
   - Under **Repos**, click on **Repositories**

3. **View all repositories**
   - You'll see a list of all repositories in the project
   - Repository names are displayed here

4. **Construct URLs**
   - Use the format: `https://dev.azure.com/{org}/{project}/_git/{repo}`

---

## 🔍 Understanding Azure DevOps URLs

### URL Components

```
https://dev.azure.com/contoso/WebApp/_git/Frontend
│      │                │       │       │       │
│      │                │       │       │       └─ Repository name
│      │                │       │       └───────── Git identifier (always "_git")
│      │                │       └───────────────── Project name
│      │                └───────────────────────── Organization name
│      └────────────────────────────────────────── Azure DevOps domain
└───────────────────────────────────────────────── Protocol (always "https")
```

### Legacy Format (Still Supported)

Some older organizations use:
```
https://contoso.visualstudio.com/WebApp/_git/Frontend
│      │                       │       │       │
│      │                       │       │       └─ Repository name
│      │                       │       └───────── Git identifier
│      │                       └───────────────── Project name
│      └───────────────────────────────────────── Organization subdomain
└──────────────────────────────────────────────── Old Azure DevOps domain
```

Both formats work with the script!

---

## ✅ Validating Your URLs

### Correct Format Examples

```
✅ https://dev.azure.com/contoso/WebApp/_git/Frontend
✅ https://dev.azure.com/fabrikam/MobileApp/_git/iOS
✅ https://dev.azure.com/adventureworks/DataPlatform/_git/ETL
✅ https://contoso.visualstudio.com/LegacyProject/_git/OldRepo
```

### Incorrect Format Examples

```
❌ https://john@dev.azure.com/contoso/WebApp/_git/Frontend
   (Remove "john@")

❌ https://john.doe%40company.com@dev.azure.com/contoso/WebApp/_git/Frontend
   (Remove "john.doe%40company.com@")

❌ https://dev.azure.com/contoso/WebApp/_git/Frontend?path=/src
   (Remove "?path=/src")

❌ https://dev.azure.com/contoso/WebApp/_git/Frontend?version=GBmain
   (Remove "?version=GBmain")

❌ git@ssh.dev.azure.com:v3/contoso/WebApp/Frontend
   (This is SSH format - use HTTPS instead)
```

---

## 🔧 Quick URL Cleanup Tool

If you have a URL with username or query parameters, use this PowerShell snippet to clean it:

```powershell
# Clean Azure DevOps URL
$dirtyUrl = "https://user@dev.azure.com/org/proj/_git/repo?path=/src&version=GBmain"

# Remove username@ prefix
$cleanUrl = $dirtyUrl -replace "https://[^@]+@", "https://"

# Remove query parameters
$cleanUrl = $cleanUrl -replace "\?.*$", ""

Write-Host "Clean URL: $cleanUrl"
# Output: https://dev.azure.com/org/proj/_git/repo
```

---

## 📝 Creating Your Repository List File

### Example File Structure

```text
# Production Repositories
https://dev.azure.com/contoso/ProductionApp/_git/WebFrontend
https://dev.azure.com/contoso/ProductionApp/_git/APIBackend
https://dev.azure.com/contoso/ProductionApp/_git/Database

# Development Repositories
https://dev.azure.com/contoso/DevProject/_git/Experimental
https://dev.azure.com/contoso/DevProject/_git/Testing

# Infrastructure
https://dev.azure.com/contoso/Infrastructure/_git/Terraform
https://dev.azure.com/contoso/Infrastructure/_git/Kubernetes
```

### Best Practices

1. ✅ **Use clean URLs** (no username@ prefix)
2. ✅ **Organize with comments** for clarity
3. ✅ **One URL per line**
4. ✅ **Test with one repository first**
5. ✅ **Remove query parameters** (?path=, ?version=, etc.)

---

## 🔐 Security Reminder

When copying URLs from Azure DevOps:

- ⚠️ The URL itself is **not sensitive** (it's just a path)
- ⚠️ Your **Personal Access Token (PAT) is sensitive** - never commit it to files
- ✅ Store PAT in environment variables
- ✅ Never include PAT in URL files

---

## 🎯 Method Compatibility

Different download methods have different URL requirements:

| Method | Username@ Prefix | Query Parameters | Legacy Format |
|--------|-----------------|------------------|---------------|
| **Git Clone** | ❌ Must remove | ✅ Ignored | ✅ Supported |
| **REST API** | ✅ Works either way | ✅ Ignored | ✅ Supported |
| **Azure CLI** | ❌ Must remove | ✅ Ignored | ✅ Supported |

**Recommendation:** Always use clean URLs for maximum compatibility.

---

## 💡 Pro Tips

### Tip 1: Bulk URL Collection

Use this PowerShell script to collect all repository URLs from a project:

```powershell
# Replace with your values
$organization = "contoso"
$project = "WebApp"
$pat = "your-pat-token"

# Call Azure DevOps REST API
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat"))
$headers = @{Authorization=("Basic {0}" -f $base64AuthInfo)}

$uri = "https://dev.azure.com/$organization/$project/_apis/git/repositories?api-version=7.0"
$repos = Invoke-RestMethod -Uri $uri -Headers $headers

# Output clean URLs
foreach ($repo in $repos.value) {
    Write-Output "https://dev.azure.com/$organization/$project/_git/$($repo.name)"
}
```

### Tip 2: URL Validation

Test if your URL is correct:

```powershell
$url = "https://dev.azure.com/contoso/WebApp/_git/Frontend"

# Should match this pattern
if ($url -match '^https://(dev\.azure\.com|[^.]+\.visualstudio\.com)/[^/]+/[^/]+/_git/[^/?#]+$') {
    Write-Host "✅ URL format is correct!" -ForegroundColor Green
} else {
    Write-Host "❌ URL format is incorrect!" -ForegroundColor Red
}
```

### Tip 3: Convert SSH to HTTPS

If you have SSH URLs, convert them:

```powershell
# SSH format
$sshUrl = "git@ssh.dev.azure.com:v3/contoso/WebApp/Frontend"

# Extract components
if ($sshUrl -match 'git@ssh\.dev\.azure\.com:v3/([^/]+)/([^/]+)/(.+)$') {
    $org = $matches[1]
    $project = $matches[2]
    $repo = $matches[3]
    
    # Construct HTTPS URL
    $httpsUrl = "https://dev.azure.com/$org/$project/_git/$repo"
    Write-Output $httpsUrl
}
```

---

## ❓ Frequently Asked Questions

**Q: Why do I need to remove the username@ prefix?**  
A: Git and Azure CLI interpret this as part of the hostname, causing "Bad hostname" errors. Only REST API can parse it correctly.

**Q: Can I use SSH URLs?**  
A: No, the script only supports HTTPS URLs. Convert SSH URLs to HTTPS format.

**Q: What if my organization name has special characters?**  
A: Azure DevOps automatically URL-encodes them. Use the URL exactly as shown in Azure DevOps.

**Q: Can I mix different projects and organizations in one file?**  
A: Yes! You can have URLs from multiple organizations and projects in the same file.

**Q: How do I know if my URL is correct?**  
A: Paste it in a browser - if it takes you to the repository, it's correct (though you may need to remove query parameters).

---

## 🆘 Troubleshooting

### Problem: "Bad hostname" error

**Cause:** URL contains `username@` prefix

**Solution:**
```
Change: https://user@dev.azure.com/org/proj/_git/repo
To:     https://dev.azure.com/org/proj/_git/repo
```

### Problem: "Invalid URL format"

**Cause:** URL has query parameters or incorrect structure

**Solution:**
```
Change: https://dev.azure.com/org/proj/_git/repo?path=/src
To:     https://dev.azure.com/org/proj/_git/repo
```

### Problem: Can't find the Clone button

**Solution:** 
1. Make sure you're on the **Repos** → **Files** page
2. The Clone button is in the top-right corner
3. If you don't see it, you may not have read access to the repository

---

## 📚 Related Documentation

- [README.md](README.md) - Full script documentation
- [QUICK-START.md](QUICK-START.md) - Quick start guide
- [METHOD-COMPARISON.md](METHOD-COMPARISON.md) - Download method comparison
- [repos-example.txt](repos-example.txt) - Example repository list file

---

## 📄 License & Author

**MIT License** - Copyright (c) 2025 François-Xavier Kim

**Author:** François-Xavier Kim

---

**Need help?** Follow Method 1 (Clone button) - it's the most reliable way to get URLs! 🎯
