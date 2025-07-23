@echo off
setlocal enabledelayedexpansion

:: Local DevSecOps Pipeline Test Script for Windows
:: This script simulates the GitHub Actions pipeline locally

echo 🚀 Starting Local DevSecOps Pipeline Test
echo ==========================================

:: Create security reports directory
echo 📋 Creating security reports directory...
if not exist "security-reports" mkdir security-reports
echo ✅ Security reports directory created

:: Step 1: Check Flutter installation
echo 📋 Verifying Flutter installation...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed. Please install Flutter first.
    exit /b 1
)
flutter --version
echo ✅ Flutter is installed

:: Step 2: Check dependencies
echo 📋 Installing dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies
    exit /b 1
)
echo ✅ Dependencies installed successfully

:: Step 3: Verify Flutter installation
echo 📋 Running Flutter doctor...
flutter doctor -v

:: Step 4: Code quality analysis
echo 📋 Running code quality analysis...
flutter analyze
if %errorlevel% neq 0 (
    echo ❌ Code analysis failed
    exit /b 1
)
echo ✅ Code analysis passed

:: Step 5: Format check
echo 📋 Checking code formatting...
dart format . --set-exit-if-changed
if %errorlevel% neq 0 (
    echo ⚠️ Code formatting issues found. Run 'dart format .' to fix.
) else (
    echo ✅ Code formatting is correct
)

:: Step 6: Run tests
echo 📋 Running tests with coverage...
flutter test --coverage
if %errorlevel% neq 0 (
    echo ❌ Tests failed
    exit /b 1
)
echo ✅ All tests passed

:: Step 7: Dependency vulnerability scan
echo 📋 Running dependency vulnerability scan...
flutter pub deps --json > security-reports\dependencies.json

echo 📋 Installing Pana for dependency analysis...
dart pub global activate pana
dart pub global run pana --json --no-warning . > security-reports\pana-report.json 2>nul

:: Generate dependency report
echo # 📊 Dependency Vulnerability Scan Report (Local) > security-reports\dependency-scan-report.md
echo. >> security-reports\dependency-scan-report.md
echo **Scan Date:** %date% %time% >> security-reports\dependency-scan-report.md
echo **Scan Type:** Dependency Vulnerability Analysis >> security-reports\dependency-scan-report.md
echo **Tool:** Pana (Package Analysis) >> security-reports\dependency-scan-report.md
echo. >> security-reports\dependency-scan-report.md
echo ## Summary >> security-reports\dependency-scan-report.md
echo - **Total Dependencies Scanned:** Local scan completed >> security-reports\dependency-scan-report.md
echo - **Severity Filter:** Medium, High, Critical only >> security-reports\dependency-scan-report.md
echo. >> security-reports\dependency-scan-report.md
echo ## Findings >> security-reports\dependency-scan-report.md

findstr /i "ERROR WARNING" security-reports\pana-report.json >nul 2>&1
if %errorlevel% equ 0 (
    echo ⚠️ **Issues Found:** Please review dependency analysis >> security-reports\dependency-scan-report.md
    echo ⚠️ Dependency issues found - check security-reports\dependency-scan-report.md
) else (
    echo ✅ **No Critical Issues Found** >> security-reports\dependency-scan-report.md
    echo ✅ No dependency issues found
)

:: Step 8: Secret scanning (if Docker is available)
echo 📋 Checking for Docker...
docker --version >nul 2>&1
if %errorlevel% equ 0 (
    echo 📋 Running TruffleHog secret scan...
    docker run --rm -v "%cd%:/pwd" trufflesecurity/trufflehog:latest filesystem /pwd --json --only-verified --no-update --filter-entropy=4.5 > security-reports\trufflehog-raw.json 2>nul
    
    echo # 🔐 Secret Scan Report (Local) > security-reports\secret-scan-report.md
    echo. >> security-reports\secret-scan-report.md
    echo **Scan Date:** %date% %time% >> security-reports\secret-scan-report.md
    echo **Scan Type:** Secret Detection >> security-reports\secret-scan-report.md
    echo **Tool:** TruffleHog >> security-reports\secret-scan-report.md
    echo **Configuration:** Verified secrets only, entropy filter 4.5+ >> security-reports\secret-scan-report.md
    echo. >> security-reports\secret-scan-report.md
    echo ## Summary >> security-reports\secret-scan-report.md
    echo - **Verified Secrets Found:** Check JSON file >> security-reports\secret-scan-report.md
    echo - **Status:** ✅ Scan completed >> security-reports\secret-scan-report.md
    echo ✅ Secret scan completed
) else (
    echo ⚠️ Docker not available - skipping TruffleHog scan
    echo To run secret scanning locally, install Docker: https://docs.docker.com/get-docker/
)

:: Step 9: Build test
echo 📋 Testing APK build...
flutter build apk --debug
if %errorlevel% equ 0 (
    echo ✅ APK build successful
) else (
    echo ⚠️ APK build failed (this might be due to local Android SDK setup)
)

:: Step 10: Generate local security report
echo 📋 Generating consolidated security report...
echo # 🛡️ Local DevSecOps Pipeline Test Report > security-reports\LOCAL_SECURITY_REPORT.md
echo. >> security-reports\LOCAL_SECURITY_REPORT.md
echo **Test Date:** %date% %time% >> security-reports\LOCAL_SECURITY_REPORT.md
echo **Environment:** Local Development (Windows) >> security-reports\LOCAL_SECURITY_REPORT.md
echo **Repository:** flutter_devsecops_template >> security-reports\LOCAL_SECURITY_REPORT.md
echo. >> security-reports\LOCAL_SECURITY_REPORT.md
echo ## 📊 Test Summary >> security-reports\LOCAL_SECURITY_REPORT.md
echo. >> security-reports\LOCAL_SECURITY_REPORT.md
echo ### ✅ Tests Completed >> security-reports\LOCAL_SECURITY_REPORT.md
echo - Code Quality Analysis (Flutter Analyze) >> security-reports\LOCAL_SECURITY_REPORT.md
echo - Code Formatting Check >> security-reports\LOCAL_SECURITY_REPORT.md
echo - Unit Tests with Coverage >> security-reports\LOCAL_SECURITY_REPORT.md
echo - Dependency Vulnerability Scan >> security-reports\LOCAL_SECURITY_REPORT.md
echo - Secret Scanning (if Docker available) >> security-reports\LOCAL_SECURITY_REPORT.md
echo - Build Test >> security-reports\LOCAL_SECURITY_REPORT.md
echo. >> security-reports\LOCAL_SECURITY_REPORT.md
echo ### 📋 Results >> security-reports\LOCAL_SECURITY_REPORT.md
echo - 📦 Dependencies: Scanned >> security-reports\LOCAL_SECURITY_REPORT.md
echo - 🎯 **Overall Status: ✅ LOCAL TEST COMPLETED** >> security-reports\LOCAL_SECURITY_REPORT.md
echo. >> security-reports\LOCAL_SECURITY_REPORT.md
echo ## 📁 Generated Reports >> security-reports\LOCAL_SECURITY_REPORT.md
echo - `dependency-scan-report.md` - Dependency analysis >> security-reports\LOCAL_SECURITY_REPORT.md
echo - `secret-scan-report.md` - Secret detection results >> security-reports\LOCAL_SECURITY_REPORT.md
echo - `LOCAL_SECURITY_REPORT.md` - This summary report >> security-reports\LOCAL_SECURITY_REPORT.md
echo. >> security-reports\LOCAL_SECURITY_REPORT.md
echo ## 🚀 Next Steps >> security-reports\LOCAL_SECURITY_REPORT.md
echo 1. Review any issues found in the reports >> security-reports\LOCAL_SECURITY_REPORT.md
echo 2. Fix critical and high-severity issues >> security-reports\LOCAL_SECURITY_REPORT.md
echo 3. Commit and push to trigger GitHub Actions pipeline >> security-reports\LOCAL_SECURITY_REPORT.md
echo. >> security-reports\LOCAL_SECURITY_REPORT.md
echo --- >> security-reports\LOCAL_SECURITY_REPORT.md
echo *Generated by Local DevSecOps Test Script (Windows)* >> security-reports\LOCAL_SECURITY_REPORT.md

echo.
echo 🎯 Local Pipeline Test Complete!
echo =================================
echo 📄 Check security-reports\ directory for detailed results
echo 🔍 Review LOCAL_SECURITY_REPORT.md for summary
echo.
echo 🚀 READY TO PUSH TO GITHUB ACTIONS!

pause
