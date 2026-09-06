<#
.SYNOPSIS
    Checks health of Inventor files in a folder.
.DESCRIPTION
    Scans for zero-byte files, large files, and old files.
.PARAMETER SourceFolder
    Folder to scan
.PARAMETER MaxFileSizeMB
    Maximum file size in MB (default: 500)
.PARAMETER DaysNotModified
    Days since last modification (default: 90)
.EXAMPLE
    .\PS-02_BatchFileHealthCheck.ps1 -SourceFolder "C:\Projects"
#>

param(
    [string]$SourceFolder = "C:\Projects",
    [int]$MaxFileSizeMB = 500,
    [int]$DaysNotModified = 90
)

if (-not (Test-Path $SourceFolder)) {
    Write-Host "Error: Folder does not exist - $SourceFolder" -ForegroundColor Red
    exit 1
}

Write-Host "=== Inventor File Health Check ===" -ForegroundColor Cyan
Write-Host "Folder: $SourceFolder"
Write-Host ""

$results = @()
$extensions = @(".ipt", ".iam", ".idw")

Get-ChildItem -Path $SourceFolder -Recurse -Include *.ipt,*.iam,*.idw | ForEach-Object {
    $sizeMB = [Math]::Round($_.Length / 1MB, 2)
    $issues = @()
    
    if ($_.Length -eq 0) { $issues += "Zero-byte file" }
    if ($sizeMB -gt $MaxFileSizeMB) { $issues += "File too large ($sizeMB MB)" }
    
    $daysSince = ((Get-Date) - $_.LastWriteTime).Days
    if ($daysSince -gt $DaysNotModified) {
        $issues += "Not modified in $daysSince days"
    }
    
    $results += [PSCustomObject]@{
        File = $_.Name
        Path = $_.FullName
        SizeMB = $sizeMB
        LastModified = $_.LastWriteTime
        Issues = $issues -join ", "
        Status = if ($issues.Count -eq 0) { "OK" } else { "WARNING" }
    }
}

$ok = $results | Where-Object { $_.Status -eq "OK" }
$warning = $results | Where-Object { $_.Status -eq "WARNING" }

Write-Host "Total files: $($results.Count)"
Write-Host "OK: $($ok.Count)"
Write-Host "WARNINGS: $($warning.Count)"
Write-Host ""

if ($warning.Count -gt 0) {
    Write-Host "Files with issues:" -ForegroundColor Yellow
    $warning | ForEach-Object {
        Write-Host "  ✗ $($_.File) - $($_.Issues)" -ForegroundColor Yellow
    }
}

$results | Export-Csv -Path "FileHealthCheck.csv" -NoTypeInformation
Write-Host ""
Write-Host "✅ Report exported to: FileHealthCheck.csv" -ForegroundColor Green
