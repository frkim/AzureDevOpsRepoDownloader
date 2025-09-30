# Azure DevOps Repository Downloader - Documentation Index

Welcome! This is your complete guide to the Azure DevOps Repository Downloader.

## 📚 Documentation Files

### 🚀 [QUICK-START.md](QUICK-START.md)
**Start here!** Get up and running in under 5 minutes.
- Super quick 3-step guide
- Common scenarios with copy-paste examples
- Installation instructions
- Basic troubleshooting

**Best for:** First-time users, quick reference

---

### 📘 [README.md](README.md)
**Complete reference documentation** for the script.
- Full parameter reference
- All features explained
- Authentication options
- Security best practices
- Detailed troubleshooting
- Advanced usage examples

**Best for:** Comprehensive understanding, advanced usage

---

### 🔍 [METHOD-COMPARISON.md](METHOD-COMPARISON.md)
**Detailed comparison** of all three download methods.
- Git Clone vs REST API vs Azure CLI
- Pros and cons of each method
- Performance benchmarks
- Decision flowchart
- Use case examples
- Feature comparison tables

**Best for:** Choosing the right method for your needs

---

### 📄 [repos-example.txt](repos-example.txt)
**Example repository list file** showing the format.
- URL format examples
- Comments support
- Both Azure DevOps URL formats

**Best for:** Creating your own repository list

---

## 🎯 Quick Navigation

### By User Type

#### 👤 First-Time User
1. Start with [QUICK-START.md](QUICK-START.md)
2. Look at [repos-example.txt](repos-example.txt) for URL format
3. Run your first download
4. Read [METHOD-COMPARISON.md](METHOD-COMPARISON.md) to understand options

#### 👨‍💼 Decision Maker
1. Read [METHOD-COMPARISON.md](METHOD-COMPARISON.md)
2. Check the decision flowchart
3. Review performance benchmarks
4. Choose method based on requirements

#### 👨‍💻 Power User
1. Read [README.md](README.md) for all parameters
2. Check [METHOD-COMPARISON.md](METHOD-COMPARISON.md) for optimization
3. Review security best practices
4. Set up automation scripts

---

## 🔧 By Task

### Setting Up

| Task | Document | Section |
|------|----------|---------|
| Install Git | [QUICK-START.md](QUICK-START.md) | Installing Git |
| Install Azure CLI | [QUICK-START.md](QUICK-START.md) | Installing Azure CLI |
| Create PAT token | [QUICK-START.md](QUICK-START.md) | Get Your Personal Access Token |
| Create repo list | [repos-example.txt](repos-example.txt) | Full file |

### Downloading

| Task | Document | Section |
|------|----------|---------|
| Download with Git | [QUICK-START.md](QUICK-START.md) | Scenario 2 |
| Download with REST API | [QUICK-START.md](QUICK-START.md) | Scenario 1 |
| Download with Azure CLI | [README.md](README.md) | Example 6 |
| Create ZIP archives | [QUICK-START.md](QUICK-START.md) | Scenario 3 |
| Specific branch | [QUICK-START.md](QUICK-START.md) | Scenario 4 |

### Choosing Methods

| Question | Document | Section |
|----------|----------|---------|
| Which method is best? | [METHOD-COMPARISON.md](METHOD-COMPARISON.md) | Quick Decision Matrix |
| Need git history? | [METHOD-COMPARISON.md](METHOD-COMPARISON.md) | Detailed Comparison |
| Performance comparison | [METHOD-COMPARISON.md](METHOD-COMPARISON.md) | Performance Benchmarks |
| Feature comparison | [METHOD-COMPARISON.md](METHOD-COMPARISON.md) | Feature Comparison Table |

### Troubleshooting

| Issue | Document | Section |
|-------|----------|---------|
| Missing prerequisites | [README.md](README.md) | Missing Prerequisites Error |
| Authentication issues | [README.md](README.md) | Authentication failures |
| Script errors | [README.md](README.md) | Troubleshooting |
| Quick fixes | [QUICK-START.md](QUICK-START.md) | Quick Troubleshooting |

---

## 📊 Visual Overview

```
Azure DevOps Repository Downloader
│
├─── 📋 Input Options
│    ├── Single URL (-RepositoryUrls)
│    └── File List (-RepositoryListFile)
│
├─── 🔧 Download Methods
│    ├── Method 1: Git Clone
│    │   ├── Fast, full history
│    │   └── Requires: Git
│    │
│    ├── Method 2: REST API
│    │   ├── Simple, no dependencies
│    │   └── Requires: PowerShell only
│    │
│    └── Method 3: Azure CLI
│        ├── Enterprise-friendly
│        └── Requires: Azure CLI + Extension
│
├─── 🔐 Authentication
│    ├── Personal Access Token (PAT)
│    ├── Git Credential Manager
│    └── Azure AD Login (CLI only)
│
├─── 📦 Output Options
│    ├── Git Repository (with history)
│    ├── Source Directory (no git)
│    └── ZIP Archive
│
└─── ✨ Features
     ├── Batch downloads
     ├── Branch selection
     ├── Error handling
     ├── Progress tracking
     └── Prerequisite checking
```

---

## 🎓 Learning Path

### Beginner Path (30 minutes)
1. **Read**: [QUICK-START.md](QUICK-START.md) (10 min)
2. **Install**: Git or Azure CLI (5 min)
3. **Create**: PAT token (5 min)
4. **Try**: Download one repository (5 min)
5. **Experiment**: Try different options (5 min)

### Intermediate Path (1 hour)
1. **Read**: [README.md](README.md) (20 min)
2. **Compare**: [METHOD-COMPARISON.md](METHOD-COMPARISON.md) (20 min)
3. **Practice**: Try all three methods (15 min)
4. **Automate**: Create your own script (5 min)

### Advanced Path (2 hours)
1. **Master**: All documentation (45 min)
2. **Optimize**: Choose best method for your workflow (15 min)
3. **Secure**: Implement security best practices (20 min)
4. **Integrate**: Add to your CI/CD pipeline (40 min)

---

## 💡 Common Questions & Where to Find Answers

### "How do I get started?"
➜ [QUICK-START.md](QUICK-START.md) - Super Quick Start

### "Which method should I use?"
➜ [METHOD-COMPARISON.md](METHOD-COMPARISON.md) - Quick Decision Matrix

### "What are all the parameters?"
➜ [README.md](README.md) - Parameters section

### "How do I handle authentication?"
➜ [README.md](README.md) - Authentication section

### "What if I get an error?"
➜ [QUICK-START.md](QUICK-START.md) - Quick Troubleshooting
➜ [README.md](README.md) - Detailed Troubleshooting

### "How fast is each method?"
➜ [METHOD-COMPARISON.md](METHOD-COMPARISON.md) - Performance Benchmarks

### "Can I download specific branches?"
➜ [QUICK-START.md](QUICK-START.md) - Scenario 4

### "How do I create ZIP files?"
➜ [QUICK-START.md](QUICK-START.md) - Scenario 3

---

## 📁 Repository Structure

```
2025 - ADORepoDownload/
│
├── 📜 Download-ADORepositories.ps1    # Main script
│
├── 📚 Documentation
│   ├── README.md                       # Complete reference
│   ├── QUICK-START.md                  # Quick start guide
│   ├── METHOD-COMPARISON.md            # Method comparison
│   └── INDEX.md                        # This file
│
└── 📄 Examples
    └── repos-example.txt               # Example repo list
```

---

## 🔗 Quick Links

### Script
- [Download-ADORepositories.ps1](Download-ADORepositories.ps1) - Main PowerShell script

### Documentation
- [Quick Start](QUICK-START.md) - Get started fast
- [Full README](README.md) - Complete documentation
- [Method Comparison](METHOD-COMPARISON.md) - Choose your method
- [Example Repo List](repos-example.txt) - URL format example

### External Resources
- [Git Download](https://git-scm.com/downloads)
- [Azure CLI Download](https://aka.ms/installazurecliwindows)
- [Azure DevOps PAT Creation](https://dev.azure.com/_usersSettings/tokens)
- [Azure DevOps REST API Docs](https://learn.microsoft.com/en-us/rest/api/azure/devops/)

---

## 🆘 Getting Help

### Step 1: Check Documentation
Most questions are answered in the docs above. Use the navigation sections to find your topic.

### Step 2: Try the Examples
The documentation includes many copy-paste examples. Try the ones that match your scenario.

### Step 3: Read Error Messages
The script provides detailed, friendly error messages with solutions.

---

## 📝 Script Capabilities Summary

### ✅ What It Can Do
- Download multiple repositories in batch
- Use Git Clone, REST API, or Azure CLI
- Create ZIP archives automatically
- Handle authentication securely
- Download specific branches
- Check prerequisites automatically
- Provide detailed error messages
- Show progress and summary reports

### ❌ What It Cannot Do
- Push changes back to Azure DevOps (use git commands after download)
- Merge repositories
- Modify repository content
- Handle Git LFS files automatically (requires manual Git LFS setup)
- Download work items or pipelines (only source code)

---

## 🎯 Success Criteria

After using this tool, you should be able to:

✅ Download Azure DevOps repositories using any of the three methods  
✅ Choose the right method for your specific needs  
✅ Handle authentication securely with PAT  
✅ Create ZIP archives when needed  
✅ Download specific branches  
✅ Troubleshoot common issues  
✅ Automate repository downloads  

---

## 📊 Version History

### v2.0 (Current)
- ✨ Added REST API method
- ✨ Added Azure CLI method
- ✨ Added automatic prerequisite checking
- ✨ Enhanced error messages with solutions
- ✨ Improved documentation
- ✨ Added method comparison guide

### v1.0
- Initial release with Git Clone method only

---

## 🤝 Feedback

This tool is designed to make your life easier. If you have suggestions for improvements or find issues, please provide feedback!

---

**Ready to start?** Go to [QUICK-START.md](QUICK-START.md) now! 🚀
