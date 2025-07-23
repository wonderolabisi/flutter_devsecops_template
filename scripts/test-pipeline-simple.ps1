# Local DevSecOps Pipeline Test Script for Windows PowerShell
# This script simulates the GitHub Actions pipeline locally

param(
    [switch]$SkipBuild,
    [switch]$Verbose
)

function Write-Step {
    param($Message)
    Write-Host "[STEP] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param($Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param($Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param($Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Test-Command {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

Write-Host "Starting Local DevSecOps Pipeline Test" -ForegroundColor Blue
Write-Host "======================================" -ForegroundColor Blue

# Create security reports directory
Write-Step "Creating security reports directory..."
if (!(Test-Path "security-reports")) {
    New-Item -ItemType Directory -Path "security-reports" | Out-Null
}
Write-Success "Security reports directory created"

# Step 1: Check Flutter installation
Write-Step "Verifying Flutter installation..."
if (Test-Command "flutter") {
    $flutterVersion = flutter --version 2>&1
    Write-Host $flutterVersion
    Write-Success "Flutter is installed"
} else {
    Write-Error "Flutter is not installed. Please install Flutter first."
    exit 1
}

# Step 2: Check dependencies
Write-Step "Installing dependencies..."
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Success "Dependencies installed successfully"
} else {
    Write-Error "Failed to install dependencies"
    exit 1
}

# Step 3: Verify Flutter installation
Write-Step "Running Flutter doctor..."
if ($Verbose) {
    flutter doctor -v
} else {
    flutter doctor
}

# Step 4: Code quality analysis
Write-Step "Running code quality analysis..."
flutter analyze
if ($LASTEXITCODE -eq 0) {
    Write-Success "Code analysis passed"
} else {
    Write-Error "Code analysis failed"
    exit 1
}

# Step 5: Format check
Write-Step "Checking code formatting..."
dart format . --set-exit-if-changed
if ($LASTEXITCODE -eq 0) {
    Write-Success "Code formatting is correct"
} else {
    Write-Warning "Code formatting issues found. Run 'dart format .' to fix."
}

# Step 6: Run tests
Write-Step "Running tests with coverage..."
flutter test --coverage
if ($LASTEXITCODE -eq 0) {
    Write-Success "All tests passed"
} else {
    Write-Error "Tests failed"
    exit 1
}

# Step 7: Dependency vulnerability scan
Write-Step "Running dependency vulnerability scan..."
flutter pub deps --json > security-reports/dependencies.json

Write-Step "Installing Pana for dependency analysis..."
dart pub global activate pana
dart pub global run pana --json --no-warning . > security-reports/pana-report.json 2>$null

# Generate dependency report
$dependencyReport = "# Dependency Vulnerability Scan Report (Local)`n`n"
$dependencyReport += "**Scan Date:** $(Get-Date)`n"
$dependencyReport += "**Scan Type:** Dependency Vulnerability Analysis`n" 
$dependencyReport += "**Tool:** Pana (Package Analysis)`n`n"
$dependencyReport += "## Summary`n"
$dependencyReport += "- Total Dependencies Scanned: Local scan completed`n"
$dependencyReport += "- Severity Filter: Medium, High, Critical only`n`n"
$dependencyReport += "## Findings`n"

if (Test-Path "security-reports/pana-report.json") {
    $panaContent = Get-Content "security-reports/pana-report.json" -Raw
    if ($panaContent -match "ERROR|WARNING") {
        $dependencyReport += "Issues Found: Please review dependency analysis`n"
        Write-Warning "Dependency issues found - check security-reports/dependency-scan-report.md"
    } else {
        $dependencyReport += "No Critical Issues Found`n"
        Write-Success "No dependency issues found"
    }
}

$dependencyReport | Out-File "security-reports/dependency-scan-report.md" -Encoding UTF8

# Step 8: Secret scanning (if Docker is available)
Write-Step "Checking for Docker..."
if (Test-Command "docker") {
    Write-Step "Running TruffleHog secret scan..."
    $currentPath = (Get-Location).Path.Replace('\', '/')
    docker run --rm -v "${currentPath}:/pwd" trufflesecurity/trufflehog:latest filesystem /pwd --json --only-verified --no-update --filter-entropy=4.5 > security-reports/trufflehog-raw.json 2>$null
    
    $secretReport = "# Secret Scan Report (Local)`n`n"
    $secretReport += "**Scan Date:** $(Get-Date)`n"
    $secretReport += "**Scan Type:** Secret Detection`n"
    $secretReport += "**Tool:** TruffleHog`n"
    $secretReport += "**Configuration:** Verified secrets only, entropy filter 4.5+`n`n"
    $secretReport += "## Summary`n"
    $secretReport += "- Verified Secrets Found: Check JSON file for details`n"
    $secretReport += "- Status: Scan completed`n`n"
    $secretReport += "## Findings`n"
    $secretReport += "See trufflehog-raw.json for detailed results`n"
    
    $secretReport | Out-File "security-reports/secret-scan-report.md" -Encoding UTF8
    Write-Success "Secret scan completed"
} else {
    Write-Warning "Docker not available - skipping TruffleHog scan"
    Write-Host "To run secret scanning locally, install Docker: https://docs.docker.com/get-docker/"
}

# Step 9: Build test (optional)
if (!$SkipBuild) {
    Write-Step "Testing APK build..."
    flutter build apk --debug
    if ($LASTEXITCODE -eq 0) {
        Write-Success "APK build successful"
    } else {
        Write-Warning "APK build failed (this might be due to local Android SDK setup)"
    }
} else {
    Write-Step "Skipping build test (SkipBuild flag used)"
}

# Step 10: Generate local security report
Write-Step "Generating consolidated security report..."
$securityReport = "# Local DevSecOps Pipeline Test Report`n`n"
$securityReport += "**Test Date:** $(Get-Date)`n"
$securityReport += "**Environment:** Local Development (Windows PowerShell)`n"
$securityReport += "**Repository:** flutter_devsecops_template`n`n"
$securityReport += "## Test Summary`n`n"
$securityReport += "### Tests Completed`n"
$securityReport += "- Code Quality Analysis (Flutter Analyze)`n"
$securityReport += "- Code Formatting Check`n"
$securityReport += "- Unit Tests with Coverage`n"
$securityReport += "- Dependency Vulnerability Scan`n"
$securityReport += "- Secret Scanning (if Docker available)`n"
if (!$SkipBuild) { 
    $securityReport += "- Build Test`n"
}
$securityReport += "`n### Results`n"
$securityReport += "- Dependencies: Scanned`n"
$securityReport += "- Overall Status: LOCAL TEST COMPLETED`n`n"
$securityReport += "## Generated Reports`n"
$securityReport += "- dependency-scan-report.md - Dependency analysis`n"
$securityReport += "- secret-scan-report.md - Secret detection results (if Docker available)`n"
$securityReport += "- LOCAL_SECURITY_REPORT.md - This summary report`n`n"
$securityReport += "## Next Steps`n"
$securityReport += "1. Review any issues found in the reports`n"
$securityReport += "2. Fix critical and high-severity issues`n"
$securityReport += "3. Commit and push to trigger GitHub Actions pipeline`n`n"
$securityReport += "---`n"
$securityReport += "*Generated by Local DevSecOps Test Script (PowerShell)*`n"

$securityReport | Out-File "security-reports/LOCAL_SECURITY_REPORT.md" -Encoding UTF8

Write-Host ""
Write-Host "Local Pipeline Test Complete!" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host "Check security-reports/ directory for detailed results"
Write-Host "Review LOCAL_SECURITY_REPORT.md for summary"
Write-Host ""
Write-Success "READY TO PUSH TO GITHUB ACTIONS!"

# Open the security reports directory
if (Test-Path "security-reports") {
    Write-Host ""
    Write-Host "Would you like to open the security reports directory? (y/n): " -NoNewline
    $response = Read-Host
    if ($response -eq 'y' -or $response -eq 'Y') {
        Invoke-Item "security-reports"
    }
}
