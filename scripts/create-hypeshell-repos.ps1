param(
    [string]$Owner = "acarlton5",
    [string]$Name = "HYPESHELL",
    [ValidateSet("public", "private")]
    [string]$Visibility = "public"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    $fallbackGh = "C:\Program Files\GitHub CLI\gh.exe"
    if (Test-Path $fallbackGh) {
        Set-Alias gh $fallbackGh
    } else {
        throw "Missing GitHub CLI. Install it from https://cli.github.com/ and run: gh auth login"
    }
}

gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI is not authenticated. Run: gh auth login"
}

$fullName = "$Owner/$Name"
gh repo view $fullName *> $null
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] $fullName already exists."
    exit 0
}

$visibilityFlag = if ($Visibility -eq "private") { "--private" } else { "--public" }
Write-Host "[CREATE] $fullName"
gh repo create $fullName `
    $visibilityFlag `
    --description "HypeShell Hyprland desktop shell, installer, store, gadgets, and themes." `
    --disable-wiki `
    --disable-issues=false

if ($LASTEXITCODE -ne 0) {
    throw "Failed to create $fullName"
}

Write-Host "Done."
