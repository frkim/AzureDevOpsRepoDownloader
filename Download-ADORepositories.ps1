<#
.SYNOPSIS
    Downloads Azure DevOps repositories from a list of URLs.

.DESCRIPTION
    This script downloads Azure DevOps repositories to local directories using one of three methods:
    1. Git Clone (default) - Uses Git to clone repositories
    2. ADO REST API - Downloads source code via Azure DevOps REST API
    3. Azure DevOps CLI - Uses the official az devops CLI tool
    
.PARAMETER RepositoryUrls
    Array of Azure DevOps repository URLs to download.
    Format: https://dev.azure.com/{organization}/{project}/_git/{repository}
    
.PARAMETER RepositoryListFile
    Path to a text file containing repository URLs (one per line).
    
.PARAMETER DestinationPath
    Base directory where repositories will be downloaded. Defaults to current directory.
    
.PARAMETER Method
    Download method to use: 'Git', 'RestAPI', or 'AzureCLI'.
    Default is 'Git'. Each method has different prerequisites and characteristics.
    
.PARAMETER CreateZipArchive
    If specified, creates ZIP files instead of keeping git repositories.
    Note: Git method keeps git history unless this is specified.
    RestAPI method always downloads as ZIP and extracts (or keeps as ZIP if this is set).
    
.PARAMETER PersonalAccessToken
    Azure DevOps Personal Access Token for authentication.
    Required for RestAPI method. Optional for Git (will use credential manager if not provided).
    Required for AzureCLI if not already logged in.
    
.PARAMETER Username
    Username for authentication (optional, typically not needed with PAT).
    
.PARAMETER CleanupGitFolder
    When used with -CreateZipArchive, removes the .git folder before zipping (Git method only).
    
.PARAMETER Branch
    Specific branch to download. Defaults to the default branch of the repository.

.EXAMPLE
    .\Download-ADORepositories.ps1 -RepositoryUrls @("https://dev.azure.com/myorg/myproject/_git/repo1") -PersonalAccessToken "your-pat-here"
    
.EXAMPLE
    .\Download-ADORepositories.ps1 -RepositoryListFile "repos.txt" -Method "RestAPI" -CreateZipArchive -PersonalAccessToken "your-pat-here" -DestinationPath "C:\ADORepos"

.EXAMPLE
    .\Download-ADORepositories.ps1 -RepositoryListFile "repos.txt" -Method "AzureCLI" -DestinationPath ".\downloads" -Branch "main"

.EXAMPLE
    .\Download-ADORepositories.ps1 -RepositoryListFile "repos.txt" -Method "Git" -CreateZipArchive -CleanupGitFolder -PersonalAccessToken "your-pat-here"

.NOTES
    Author: GitHub Copilot
    Prerequisites vary by method:
    - Git: Requires Git to be installed
    - RestAPI: Requires PowerShell 5.1+ or PowerShell Core, PAT token
    - AzureCLI: Requires Azure CLI with devops extension
#>

[CmdletBinding(DefaultParameterSetName = 'UrlArray')]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'UrlArray', Position = 0)]
    [string[]]$RepositoryUrls,
    
    [Parameter(Mandatory = $true, ParameterSetName = 'FileList')]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$RepositoryListFile,
    
    [Parameter(Mandatory = $false)]
    [string]$DestinationPath = ".",
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('Git', 'RestAPI', 'AzureCLI')]
    [string]$Method = 'Git',
    
    [Parameter(Mandatory = $false)]
    [switch]$CreateZipArchive,
    
    [Parameter(Mandatory = $false)]
    [string]$PersonalAccessToken,
    
    [Parameter(Mandatory = $false)]
    [string]$Username = "git",
    
    [Parameter(Mandatory = $false)]
    [switch]$CleanupGitFolder,
    
    [Parameter(Mandatory = $false)]
    [string]$Branch
)

# Function to check if git is installed
function Test-GitInstalled {
    try {
        $null = git --version 2>&1
        return $LASTEXITCODE -eq 0
    }
    catch {
        return $false
    }
}

# Function to check if Azure CLI is installed
function Test-AzureCLIInstalled {
    try {
        $null = az --version 2>&1
        return $LASTEXITCODE -eq 0
    }
    catch {
        return $false
    }
}

# Function to check if Azure DevOps extension is installed
function Test-AzureDevOpsExtension {
    try {
        $extensions = az extension list 2>&1 | ConvertFrom-Json
        return ($extensions | Where-Object { $_.name -eq 'azure-devops' }) -ne $null
    }
    catch {
        return $false
    }
}

# Function to display missing prerequisites
function Show-PrerequisiteError {
    param(
        [string]$Method,
        [string[]]$MissingItems
    )
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                   MISSING PREREQUISITES                        ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "The selected method '$Method' requires the following:" -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($item in $MissingItems) {
        Write-Host "  ✗ $item" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Please install the missing prerequisites and try again." -ForegroundColor Yellow
    Write-Host ""
    
    switch ($Method) {
        'Git' {
            Write-Host "Git Installation:" -ForegroundColor Cyan
            Write-Host "  1. Download from: https://git-scm.com/downloads" -ForegroundColor Gray
            Write-Host "  2. Run the installer with default settings" -ForegroundColor Gray
            Write-Host "  3. Restart your terminal/PowerShell session" -ForegroundColor Gray
        }
        'RestAPI' {
            Write-Host "REST API Requirements:" -ForegroundColor Cyan
            Write-Host "  1. PowerShell 5.1 or higher is already installed on Windows 10+" -ForegroundColor Gray
            Write-Host "  2. Ensure you have a valid Personal Access Token (PAT)" -ForegroundColor Gray
            Write-Host "  3. Create PAT at: https://dev.azure.com/{org}/_usersSettings/tokens" -ForegroundColor Gray
            Write-Host "     Required permission: Code (Read)" -ForegroundColor Gray
        }
        'AzureCLI' {
            Write-Host "Azure CLI Installation:" -ForegroundColor Cyan
            Write-Host "  1. Download from: https://aka.ms/installazurecliwindows" -ForegroundColor Gray
            Write-Host "  2. Run the MSI installer" -ForegroundColor Gray
            Write-Host "  3. Restart your terminal/PowerShell session" -ForegroundColor Gray
            Write-Host "  4. Install Azure DevOps extension:" -ForegroundColor Gray
            Write-Host "     Run: az extension add --name azure-devops" -ForegroundColor Gray
            Write-Host "  5. Login: az login" -ForegroundColor Gray
            Write-Host "  6. Set default organization (optional):" -ForegroundColor Gray
            Write-Host "     Run: az devops configure --defaults organization=https://dev.azure.com/yourorg" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
}

# Function to validate prerequisites for selected method
function Test-MethodPrerequisites {
    param([string]$Method)
    
    $missing = @()
    
    switch ($Method) {
        'Git' {
            if (-not (Test-GitInstalled)) {
                $missing += "Git (git command-line tool)"
            }
        }
        'RestAPI' {
            # REST API only requires PowerShell which is already running
            # Check for PAT will be done separately as it's a parameter
        }
        'AzureCLI' {
            if (-not (Test-AzureCLIInstalled)) {
                $missing += "Azure CLI (az command-line tool)"
            }
            elseif (-not (Test-AzureDevOpsExtension)) {
                $missing += "Azure DevOps CLI extension (install with: az extension add --name azure-devops)"
            }
        }
    }
    
    return $missing
}

# Function to parse repository information from URL
function Get-RepositoryInfo {
    param([string]$Url)
    
    # Match Azure DevOps URL pattern
    # https://dev.azure.com/{organization}/{project}/_git/{repository}
    # or https://{organization}.visualstudio.com/{project}/_git/{repository}
    
    if ($Url -match 'dev\.azure\.com/([^/]+)/([^/]+)/_git/([^/\?#]+)') {
        return @{
            Organization = $matches[1]
            Project = $matches[2]
            Repository = $matches[3]
            Url = $Url
            IsValid = $true
        }
    }
    elseif ($Url -match '([^.]+)\.visualstudio\.com/([^/]+)/_git/([^/\?#]+)') {
        return @{
            Organization = $matches[1]
            Project = $matches[2]
            Repository = $matches[3]
            Url = $Url
            IsValid = $true
        }
    }
    else {
        Write-Warning "Invalid Azure DevOps URL format: $Url"
        return @{ IsValid = $false }
    }
}

# Function to build authenticated git URL
function Get-AuthenticatedGitUrl {
    param(
        [string]$Url,
        [string]$Pat,
        [string]$User = "git"
    )
    
    if ([string]::IsNullOrEmpty($Pat)) {
        return $Url
    }
    
    # Insert credentials into URL
    if ($Url -match '^https://(.+)$') {
        $urlPart = $matches[1]
        return "https://${User}:${Pat}@${urlPart}"
    }
    
    return $Url
}

# Function to download via REST API
function Invoke-RestAPIDownload {
    param(
        [hashtable]$RepoInfo,
        [string]$Destination,
        [string]$Pat,
        [string]$BranchName
    )
    
    $repoName = $RepoInfo.Repository
    $organization = $RepoInfo.Organization
    $project = $RepoInfo.Project
    
    Write-Host "Downloading repository via REST API: $repoName" -ForegroundColor Cyan
    Write-Host "  Organization: $organization" -ForegroundColor Gray
    Write-Host "  Project: $project" -ForegroundColor Gray
    
    try {
        # Get default branch if not specified
        $branch = $BranchName
        if ([string]::IsNullOrEmpty($branch)) {
            $repoApiUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repoName`?api-version=7.0"
            $headers = @{
                Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
            }
            
            Write-Host "  Getting default branch..." -ForegroundColor Gray
            $repoData = Invoke-RestMethod -Uri $repoApiUrl -Headers $headers -Method Get
            $branch = $repoData.defaultBranch -replace 'refs/heads/', ''
            Write-Host "  Using branch: $branch" -ForegroundColor Gray
        }
        
        # Download ZIP
        $downloadUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repoName/items?path=/&versionDescriptor[versionType]=branch&versionDescriptor[version]=$branch&`$format=zip&api-version=7.0"
        
        $zipPath = Join-Path -Path $Destination -ChildPath "$repoName.zip"
        $tempZipPath = Join-Path -Path $env:TEMP -ChildPath "$repoName-$(Get-Random).zip"
        
        Write-Host "  Downloading ZIP archive..." -ForegroundColor Gray
        
        $headers = @{
            Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
        }
        
        Invoke-RestMethod -Uri $downloadUrl -Headers $headers -Method Get -OutFile $tempZipPath
        
        if (Test-Path $tempZipPath) {
            $targetPath = Join-Path -Path $Destination -ChildPath $repoName
            
            # Check if directory already exists
            if (Test-Path $targetPath) {
                Write-Warning "Directory '$targetPath' already exists. Skipping extraction."
                Remove-Item -Path $tempZipPath -Force
                return @{ Success = $false; Path = $targetPath; Reason = "AlreadyExists" }
            }
            
            Write-Host "  Extracting to: $targetPath" -ForegroundColor Gray
            Expand-Archive -Path $tempZipPath -DestinationPath $targetPath -Force
            
            # Move from ZIP to final location
            Move-Item -Path $tempZipPath -Destination $zipPath -Force
            
            Write-Host "  ✓ Successfully downloaded $repoName" -ForegroundColor Green
            return @{ Success = $true; Path = $targetPath; ZipPath = $zipPath }
        }
        else {
            Write-Error "Failed to download repository ZIP"
            return @{ Success = $false; Path = $null; Error = "Download failed" }
        }
    }
    catch {
        Write-Error "Exception while downloading ${repoName}: $_"
        return @{ Success = $false; Path = $null; Error = $_.Exception.Message }
    }
}

# Function to download via Azure CLI
function Invoke-AzureCLIDownload {
    param(
        [hashtable]$RepoInfo,
        [string]$Destination,
        [string]$Pat,
        [string]$BranchName
    )
    
    $repoName = $RepoInfo.Repository
    $organization = $RepoInfo.Organization
    $project = $RepoInfo.Project
    $targetPath = Join-Path -Path $Destination -ChildPath $repoName
    
    # Check if directory already exists
    if (Test-Path $targetPath) {
        Write-Warning "Directory '$targetPath' already exists. Skipping download."
        return @{ Success = $false; Path = $targetPath; Reason = "AlreadyExists" }
    }
    
    Write-Host "Downloading repository via Azure CLI: $repoName" -ForegroundColor Cyan
    Write-Host "  Organization: $organization" -ForegroundColor Gray
    Write-Host "  Project: $project" -ForegroundColor Gray
    Write-Host "  Destination: $targetPath" -ForegroundColor Gray
    
    try {
        # Set PAT if provided
        if (![string]::IsNullOrEmpty($Pat)) {
            $env:AZURE_DEVOPS_EXT_PAT = $Pat
        }
        
        # Configure organization
        $orgUrl = "https://dev.azure.com/$organization"
        az devops configure --defaults organization=$orgUrl project=$project 2>&1 | Out-Null
        
        # Clone using az repos
        $azArgs = @(
            "repos", "clone",
            "--name", $repoName,
            "--organization", $orgUrl,
            "--project", $project
        )
        
        if (![string]::IsNullOrEmpty($BranchName)) {
            $azArgs += @("--branch", $BranchName)
        }
        
        # Change to destination directory
        $currentDir = Get-Location
        Set-Location -Path $Destination
        
        $output = & az @azArgs 2>&1
        
        Set-Location -Path $currentDir
        
        if ($LASTEXITCODE -eq 0) {
            # Azure CLI clones to repo name directory
            $clonedPath = Join-Path -Path $Destination -ChildPath $repoName
            
            if (Test-Path $clonedPath) {
                Write-Host "  ✓ Successfully downloaded $repoName" -ForegroundColor Green
                return @{ Success = $true; Path = $clonedPath }
            }
            else {
                Write-Error "Clone succeeded but directory not found: $clonedPath"
                return @{ Success = $false; Path = $null; Error = "Directory not found after clone" }
            }
        }
        else {
            Write-Error "Failed to download $repoName via Azure CLI. Exit code: $LASTEXITCODE"
            Write-Error ($output | Out-String)
            return @{ Success = $false; Path = $null; Error = $output }
        }
    }
    catch {
        Set-Location -Path $currentDir
        Write-Error "Exception while downloading ${repoName}: $_"
        return @{ Success = $false; Path = $null; Error = $_.Exception.Message }
    }
}

# Function to clone repository
function Invoke-RepositoryClone {
    param(
        [hashtable]$RepoInfo,
        [string]$Destination,
        [string]$Pat,
        [string]$User,
        [string]$BranchName
    )
    
    $repoName = $RepoInfo.Repository
    $targetPath = Join-Path -Path $Destination -ChildPath $repoName
    
    # Check if directory already exists
    if (Test-Path $targetPath) {
        Write-Warning "Directory '$targetPath' already exists. Skipping clone."
        return @{ Success = $false; Path = $targetPath; Reason = "AlreadyExists" }
    }
    
    Write-Host "Cloning repository: $repoName" -ForegroundColor Cyan
    Write-Host "  Organization: $($RepoInfo.Organization)" -ForegroundColor Gray
    Write-Host "  Project: $($RepoInfo.Project)" -ForegroundColor Gray
    Write-Host "  Destination: $targetPath" -ForegroundColor Gray
    
    $gitUrl = Get-AuthenticatedGitUrl -Url $RepoInfo.Url -Pat $Pat -User $User
    
    try {
        $gitArgs = @("clone")
        
        if (![string]::IsNullOrEmpty($BranchName)) {
            $gitArgs += @("--branch", $BranchName)
        }
        
        $gitArgs += @($gitUrl, $targetPath)
        
        # Redirect stderr to capture errors
        $gitOutput = & git @gitArgs 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Successfully cloned $repoName" -ForegroundColor Green
            return @{ Success = $true; Path = $targetPath }
        }
        else {
            Write-Error "Failed to clone $repoName. Exit code: $LASTEXITCODE"
            Write-Error ($gitOutput | Out-String)
            return @{ Success = $false; Path = $null; Error = $gitOutput }
        }
    }
    catch {
        Write-Error "Exception while cloning ${repoName}: $_"
        return @{ Success = $false; Path = $null; Error = $_.Exception.Message }
    }
}

# Function to create ZIP archive
function New-RepositoryArchive {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [bool]$RemoveGitFolder
    )
    
    $repoName = Split-Path -Path $SourcePath -Leaf
    $zipPath = Join-Path -Path $DestinationPath -ChildPath "$repoName.zip"
    
    Write-Host "Creating ZIP archive: $zipPath" -ForegroundColor Cyan
    
    try {
        # Remove .git folder if requested
        if ($RemoveGitFolder) {
            $gitFolder = Join-Path -Path $SourcePath -ChildPath ".git"
            if (Test-Path $gitFolder) {
                Write-Host "  Removing .git folder..." -ForegroundColor Gray
                Remove-Item -Path $gitFolder -Recurse -Force
            }
        }
        
        # Create ZIP archive
        Compress-Archive -Path "$SourcePath\*" -DestinationPath $zipPath -Force
        
        Write-Host "  ✓ Successfully created archive: $zipPath" -ForegroundColor Green
        
        # Remove source directory after zipping
        Write-Host "  Removing source directory..." -ForegroundColor Gray
        Remove-Item -Path $SourcePath -Recurse -Force
        
        return @{ Success = $true; Path = $zipPath }
    }
    catch {
        Write-Error "Failed to create archive for ${repoName}: $_"
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

# Main script execution
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║        Azure DevOps Repository Downloader v2.0                ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "Download Method: $Method" -ForegroundColor Cyan
Write-Host ""

# Validate prerequisites for selected method
$missingPrereqs = Test-MethodPrerequisites -Method $Method
if ($missingPrereqs.Count -gt 0) {
    Show-PrerequisiteError -Method $Method -MissingItems $missingPrereqs
    exit 1
}

# Validate PAT for REST API method
if ($Method -eq 'RestAPI' -and [string]::IsNullOrEmpty($PersonalAccessToken)) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                   AUTHENTICATION REQUIRED                      ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "The REST API method requires a Personal Access Token (PAT)." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To create a PAT:" -ForegroundColor Cyan
    Write-Host "  1. Go to: https://dev.azure.com/{organization}/_usersSettings/tokens" -ForegroundColor Gray
    Write-Host "  2. Click 'New Token'" -ForegroundColor Gray
    Write-Host "  3. Set name and expiration" -ForegroundColor Gray
    Write-Host "  4. Select scope: Code (Read)" -ForegroundColor Gray
    Write-Host "  5. Click 'Create' and copy the token" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Then run the script with: -PersonalAccessToken 'your-token-here'" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Get list of repository URLs
$urls = @()
if ($PSCmdlet.ParameterSetName -eq 'FileList') {
    Write-Host "Reading repository URLs from file: $RepositoryListFile" -ForegroundColor Cyan
    $urls = Get-Content -Path $RepositoryListFile | Where-Object { $_ -match '\S' } # Filter out empty lines
    Write-Host "Found $($urls.Count) repository URL(s)" -ForegroundColor Gray
}
else {
    $urls = $RepositoryUrls
}

if ($urls.Count -eq 0) {
    Write-Error "No repository URLs provided."
    exit 1
}

# Create destination directory if it doesn't exist
if (-not (Test-Path $DestinationPath)) {
    Write-Host "Creating destination directory: $DestinationPath" -ForegroundColor Cyan
    New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null
}

# Resolve full path
$DestinationPath = Resolve-Path -Path $DestinationPath

# Process each repository
$results = @()
$successCount = 0
$failCount = 0

foreach ($url in $urls) {
    Write-Host ""
    Write-Host ("=" * 80) -ForegroundColor DarkGray
    
    # Parse repository information
    $repoInfo = Get-RepositoryInfo -Url $url.Trim()
    
    if (-not $repoInfo.IsValid) {
        $failCount++
        $results += @{ Url = $url; Success = $false; Reason = "InvalidUrl" }
        continue
    }
    
    # Download repository using selected method
    switch ($Method) {
        'Git' {
            $cloneResult = Invoke-RepositoryClone `
                -RepoInfo $repoInfo `
                -Destination $DestinationPath `
                -Pat $PersonalAccessToken `
                -User $Username `
                -BranchName $Branch
        }
        'RestAPI' {
            $cloneResult = Invoke-RestAPIDownload `
                -RepoInfo $repoInfo `
                -Destination $DestinationPath `
                -Pat $PersonalAccessToken `
                -BranchName $Branch
        }
        'AzureCLI' {
            $cloneResult = Invoke-AzureCLIDownload `
                -RepoInfo $repoInfo `
                -Destination $DestinationPath `
                -Pat $PersonalAccessToken `
                -BranchName $Branch
        }
    }
    
    if ($cloneResult.Success) {
        $successCount++
        
        # For REST API, handle ZIP differently
        if ($Method -eq 'RestAPI') {
            if ($CreateZipArchive) {
                # Already have ZIP, just keep it
                $results += @{ 
                    Url = $url
                    Repository = $repoInfo.Repository
                    Success = $true
                    Type = "Archive"
                    Path = $cloneResult.ZipPath
                }
                # Remove extracted directory
                if (Test-Path $cloneResult.Path) {
                    Remove-Item -Path $cloneResult.Path -Recurse -Force
                }
            }
            else {
                # Keep extracted directory, remove ZIP
                $results += @{ 
                    Url = $url
                    Repository = $repoInfo.Repository
                    Success = $true
                    Type = "Repository"
                    Path = $cloneResult.Path
                }
                if ($cloneResult.ZipPath -and (Test-Path $cloneResult.ZipPath)) {
                    Remove-Item -Path $cloneResult.ZipPath -Force
                }
            }
        }
        else {
            # Git and Azure CLI methods
            # Create ZIP archive if requested
            if ($CreateZipArchive) {
                $archiveResult = New-RepositoryArchive `
                    -SourcePath $cloneResult.Path `
                    -DestinationPath $DestinationPath `
                    -RemoveGitFolder ($CleanupGitFolder -and $Method -eq 'Git')
                
                if ($archiveResult.Success) {
                    $results += @{ 
                        Url = $url
                        Repository = $repoInfo.Repository
                        Success = $true
                        Type = "Archive"
                        Path = $archiveResult.Path
                    }
                }
                else {
                    $results += @{ 
                        Url = $url
                        Repository = $repoInfo.Repository
                        Success = $false
                        Error = $archiveResult.Error
                    }
                    $successCount--
                    $failCount++
                }
            }
            else {
                $results += @{ 
                    Url = $url
                    Repository = $repoInfo.Repository
                    Success = $true
                    Type = "Repository"
                    Path = $cloneResult.Path
                }
            }
        }
    }
    else {
        $failCount++
        $results += @{ 
            Url = $url
            Repository = $repoInfo.Repository
            Success = $false
            Reason = $cloneResult.Reason
            Error = $cloneResult.Error
        }
    }
}

# Summary
Write-Host ""
Write-Host ("=" * 80) -ForegroundColor DarkGray
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║                         SUMMARY                                ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "Download Method:          $Method" -ForegroundColor Cyan
Write-Host "Total Repositories:       $($urls.Count)" -ForegroundColor Cyan
Write-Host "Successful:               $successCount" -ForegroundColor Green
Write-Host "Failed:                   $failCount" -ForegroundColor $(if ($failCount -gt 0) { 'Red' } else { 'Gray' })
Write-Host "Output Format:            $(if ($CreateZipArchive) { 'ZIP Archive' } else { 'Repository Directory' })" -ForegroundColor Cyan
Write-Host ""

if ($successCount -gt 0) {
    Write-Host "Downloaded repositories:" -ForegroundColor Green
    $results | Where-Object { $_.Success } | ForEach-Object {
        Write-Host "  ✓ $($_.Repository) -> $($_.Path)" -ForegroundColor Gray
    }
}

if ($failCount -gt 0) {
    Write-Host ""
    Write-Host "Failed repositories:" -ForegroundColor Red
    $results | Where-Object { -not $_.Success } | ForEach-Object {
        Write-Host "  ✗ $($_.Url) - $($_.Reason)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "All operations completed!" -ForegroundColor Magenta
