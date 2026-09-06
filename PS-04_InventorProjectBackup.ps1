<#
.SYNOPSIS
    Creates a backup of an Inventor project folder.
.DESCRIPTION
    Compresses the project folder and keeps last N backups.
.PARAMETER ProjectFolder
    Path to the project folder to backup
.PARAMETER BackupDestination
    Destination folder for backups
.PARAMETER KeepLastNBackups
    Number of backups to keep (default: 10)
.EXAMPLE
    .\PS-04_InventorProjectBackup.ps1 -ProjectFolder "C:\Projects\PROJ-001" -BackupDestination "D:\Backups"
#>

param(
    [string]$ProjectFolder,
    [string]$BackupDestination,
    [int]$KeepLastNBackups = 10
)

if (-not $ProjectFolder -or -not (Test-Path $ProjectFolder)) {
    Write-Host "Error: Project folder does not exist: $ProjectFolder" -ForegroundColor Red
    exit 1
}

if (-not $BackupDestination) {
    $BackupDestination = Join-Path (Split-Path $ProjectFolder -Parent) "Backups"
}

if (-not (Test-Path $BackupDestination)) {
    New-Item -ItemType Directory -Path $BackupDestination -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$projectName = Split-Path $ProjectFolder -Leaf
$backupName = "${projectName}_$timestamp.zip"
$backupPath = Join-Path $BackupDestination $backupName

Write-Host "=== Inventor Project Backup ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectFolder"
Write-Host "Destination: $backupPath"
Write-Host ""

try {
    Compress-Archive -Path $ProjectFolder -DestinationPath $backupPath -CompressionLevel Optimal -Force
    Write-Host "✅ Backup created: $backupName" -ForegroundColor Green
    $size = [Math]::Round((Get-Item $backupPath).Length / 1MB, 2)
    Write-Host "Size: $size MB"
    
    # Clean up old backups
    $oldBackups = Get-ChildItem -Path $BackupDestination -Filter "*.zip" | 
                  Where-Object { $_.Name -like "${projectName}_*" } |
                  Sort-Object LastWriteTime -Descending |
                  Select-Object -Skip $KeepLastNBackups
    
    if ($oldBackups) {
        $oldBackups | Remove-Item -Force
        Write-Host "Removed $($oldBackups.Count) old backup(s)."
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
