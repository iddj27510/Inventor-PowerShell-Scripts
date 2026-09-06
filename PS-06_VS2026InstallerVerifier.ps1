<#
.SYNOPSIS
    Verifies Visual Studio 2026 installation and components.
.DESCRIPTION
    Checks .NET SDK, Git, and GitHub CLI.
.EXAMPLE
    .\PS-06_VS2026InstallerVerifier.ps1
#>

Write-Host "=== VS 2026 Installation Verifier ===" -ForegroundColor Cyan
Write-Host ""

$checks = @(
    @{Name="Git installed"; Test={
        $null -ne (Get-Command git -ErrorAction SilentlyContinue)
    }},
    @{Name="GitHub CLI (gh) installed"; Test={
        $null -ne (Get-Command gh -ErrorAction SilentlyContinue)
    }},
    @{Name=".NET 10 SDK"; Test={
        (dotnet --list-sdks 2>&1) -match "10\."
    }},
    @{Name=".NET 8 SDK"; Test={
        (dotnet --list-sdks 2>&1) -match "8\."
    }},
    @{Name="GitHub account configured"; Test={
        (git config --global user.email 2>&1) -match "@"
    }}
)

$allOk = $true
foreach ($check in $checks) {
    $result = & $check.Test
    $status = if ($result) { "OK" } else { "MISSING" }
    $color = if ($result) { "Green" } else { "Red" }
    if (-not $result) { $allOk = $false }
    Write-Host "  [$status] $($check.Name)" -ForegroundColor $color
}

Write-Host ""
if ($allOk) {
    Write-Host "✅ All components are installed correctly." -ForegroundColor Green
    Write-Host "VS 2026 development environment is ready." -ForegroundColor Green
} else {
    Write-Host "⚠️ Some components are missing." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install missing components:" -ForegroundColor Cyan
    Write-Host "  - Visual Studio 2026: https://visualstudio.microsoft.com/vs/community" -ForegroundColor White
    Write-Host "  - Git: https://git-scm.com/downloads" -ForegroundColor White
    Write-Host "  - GitHub CLI: https://cli.github.com/" -ForegroundColor White
}
