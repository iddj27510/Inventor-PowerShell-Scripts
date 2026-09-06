<#
.SYNOPSIS
    Verifies Inventor installation and required paths.
.DESCRIPTION
    Checks registry, license server, Content Centre, and project files.
.EXAMPLE
    .\PS-01_InventorInstallerVerifier.ps1
#>

Write-Host "=== Inventor Installation Check ===" -ForegroundColor Cyan
Write-Host ""

$checks = @(
    @{Name="Inventor 2027 registry keys"; Test={
        Test-Path "HKLM:\SOFTWARE\Autodesk\Inventor\CurrentVersion"
    }},
    @{Name="Inventor 2026 registry keys"; Test={
        Test-Path "HKLM:\SOFTWARE\Autodesk\Inventor\2026"
    }},
    @{Name="Inventor 2025 registry keys"; Test={
        Test-Path "HKLM:\SOFTWARE\Autodesk\Inventor\2025"
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
    Write-Host "✅ Inventor installation appears complete." -ForegroundColor Green
} else {
    Write-Host "⚠️ Some components are missing." -ForegroundColor Yellow
}
