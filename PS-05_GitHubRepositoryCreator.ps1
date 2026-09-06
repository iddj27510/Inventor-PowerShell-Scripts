<#
.SYNOPSIS
    Creates GitHub repositories for Inventor add-ins.
.DESCRIPTION
    Uses GitHub CLI to create public repositories.
.EXAMPLE
    .\PS-05_GitHubRepositoryCreator.ps1
#>

Write-Host "=== GitHub Repository Creator ===" -ForegroundColor Cyan
Write-Host ""

# Check if gh is installed
$ghPath = Get-Command gh -ErrorAction SilentlyContinue
if (-not $ghPath) {
    Write-Host "Error: GitHub CLI (gh) not found." -ForegroundColor Red
    Write-Host "Install from: https://cli.github.com/" -ForegroundColor Yellow
    exit 1
}

# Check authentication
$authCheck = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Not authenticated with GitHub." -ForegroundColor Red
    Write-Host "Run: gh auth login" -ForegroundColor Yellow
    exit 1
}

$addIns = @(
    @{Name="iProps-Checker"; Desc="Assembly-wide iProperties validator for Inventor"},
    @{Name="SmartExport-Inventor"; Desc="Batch export with intelligent naming from iProperties"},
    @{Name="DrawingFix-Inventor"; Desc="Drawing validator and auto-fixer for Inventor"},
    @{Name="ContentCentre-Auditor"; Desc="Content Centre audit tool for Inventor"},
    @{Name="iLogic-RuleOrganizer"; Desc="iLogic rule organizer and documentation tool"},
    @{Name="Parameters-Manager"; Desc="Cross-file parameter manager with ERP export"},
    @{Name="Revision-Tracker"; Desc="Assembly-wide revision tracking with ERP export"},
    @{Name="PositionManager-Inventor"; Desc="Positional Representations manager for Inventor"},
    @{Name="ViewExport-Inventor"; Desc="8 standardized PNG views with auto-lighting"},
    @{Name="ModelStates-Manager"; Desc="Model States manager with per-state iProperties"},
    @{Name="FeatureOrganizer-Inventor"; Desc="Part browser feature organizer using 2027 API"},
    @{Name="ConstraintDoctor-Inventor"; Desc="Assembly constraint diagnostics tool"},
    @{Name="PatternPro-Inventor"; Desc="Irregular pattern distribution using Inventor 2027 API"},
    @{Name="SlotCenter-Inventor"; Desc="Drawing centerlines for SlotFeature in Inventor 2027"},
    @{Name="AssemblyDoctor-Inventor"; Desc="Assembly health dashboard with PDF export"},
    @{Name="iLogic-Library"; Desc="Open source iLogic rules for daily Inventor automation"},
    @{Name="VBA-Macro-Library"; Desc="Open source VBA macros for batch Inventor processing"},
    @{Name="ContentCentre-Library"; Desc="ISO and DIN standard Content Centre components"}
)

$success = 0
$failed = 0

foreach ($repo in $addIns) {
    Write-Host "Creating: $($repo.Name)..." -NoNewline
    $result = gh repo create "iddj27510/$($repo.Name)" --public --description $repo.Desc 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅" -ForegroundColor Green
        $success++
    } else {
        Write-Host " ❌" -ForegroundColor Red
        $failed++
    }
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "✅ Created: $success repositories" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host "❌ Failed: $failed repositories" -ForegroundColor Red
}
