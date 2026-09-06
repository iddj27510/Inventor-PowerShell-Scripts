<#
.SYNOPSIS
    Monitors Inventor license usage via lmstat.
.DESCRIPTION
    Checks license server for Inventor license availability.
.PARAMETER LicenseServer
    License server hostname (default: LICENSE-SRV-01)
.EXAMPLE
    .\PS-03_InventorLicenseMonitor.ps1 -LicenseServer "lic-server-01"
#>

param(
    [string]$LicenseServer = "LICENSE-SRV-01"
)

Write-Host "=== Inventor License Usage Monitor ===" -ForegroundColor Cyan
Write-Host "Server: $LicenseServer"
Write-Host ""

# Check if lmutil is available
$lmutilPath = Get-Command lmutil -ErrorAction SilentlyContinue
if (-not $lmutilPath) {
    Write-Host "⚠️ lmutil not found in PATH." -ForegroundColor Yellow
    Write-Host "Please install FlexNet License Manager or specify full path to lmutil." -ForegroundColor Yellow
    exit 1
}

try {
    $output = & lmutil lmstat -a -c $LicenseServer 2>&1
    $licenseInfo = $output | Where-Object { $_ -match "Inventor" }
    
    if ($licenseInfo) {
        Write-Host "License Server Status:" -ForegroundColor Green
        $licenseInfo | ForEach-Object { Write-Host "  $_" }
    } else {
        Write-Host "⚠️ No Inventor license information found." -ForegroundColor Yellow
        Write-Host "Server may be unreachable or no licenses available." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error: Could not query license server." -ForegroundColor Red
    Write-Host "  $_" -ForegroundColor Red
}
