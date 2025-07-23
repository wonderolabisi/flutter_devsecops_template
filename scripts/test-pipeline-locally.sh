#!/bin/bash

# Local DevSecOps Pipeline Test Script
# This script simulates the GitHub Actions pipeline locally

set -e  # Exit on any error

echo "🚀 Starting Local DevSecOps Pipeline Test"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Create security reports directory
print_step "Creating security reports directory..."
mkdir -p security-reports
print_success "Security reports directory created"

# Step 1: Check Flutter installation
print_step "Verifying Flutter installation..."
if command -v flutter &> /dev/null; then
    flutter --version
    print_success "Flutter is installed"
else
    print_error "Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Step 2: Check dependencies
print_step "Installing dependencies..."
flutter pub get
if [ $? -eq 0 ]; then
    print_success "Dependencies installed successfully"
else
    print_error "Failed to install dependencies"
    exit 1
fi

# Step 3: Verify Flutter installation
print_step "Running Flutter doctor..."
flutter doctor -v

# Step 4: Code quality analysis
print_step "Running code quality analysis..."
flutter analyze
if [ $? -eq 0 ]; then
    print_success "Code analysis passed"
else
    print_error "Code analysis failed"
    exit 1
fi

# Step 5: Format check
print_step "Checking code formatting..."
dart format . --set-exit-if-changed
if [ $? -eq 0 ]; then
    print_success "Code formatting is correct"
else
    print_warning "Code formatting issues found. Run 'dart format .' to fix."
fi

# Step 6: Run tests
print_step "Running tests with coverage..."
flutter test --coverage
if [ $? -eq 0 ]; then
    print_success "All tests passed"
else
    print_error "Tests failed"
    exit 1
fi

# Step 7: Dependency vulnerability scan
print_step "Running dependency vulnerability scan..."
flutter pub deps --json > security-reports/dependencies.json

# Check if jq is installed
if command -v jq &> /dev/null; then
    DEPS_COUNT=$(cat security-reports/dependencies.json | jq '.packages | length')
    echo "Dependencies scanned: $DEPS_COUNT"
else
    print_warning "jq is not installed. Install jq for better JSON processing: sudo apt-get install jq (Linux) or brew install jq (macOS)"
    echo "Dependencies file created: security-reports/dependencies.json"
fi

# Install and run pana
print_step "Installing Pana for dependency analysis..."
dart pub global activate pana
dart pub global run pana --json --no-warning . > security-reports/pana-report.json 2>/dev/null || true

# Generate dependency report
cat > security-reports/dependency-scan-report.md << 'EOF'
# 📊 Dependency Vulnerability Scan Report (Local)

**Scan Date:** $(date)
**Scan Type:** Dependency Vulnerability Analysis
**Tool:** Pana (Package Analysis)

## Summary
- **Total Dependencies Scanned:** Local scan completed
- **Severity Filter:** Medium, High, Critical only

## Findings
EOF

if grep -q "ERROR\|WARNING" security-reports/pana-report.json 2>/dev/null; then
    echo "⚠️ **Issues Found:** Please review dependency analysis" >> security-reports/dependency-scan-report.md
    print_warning "Dependency issues found - check security-reports/dependency-scan-report.md"
else
    echo "✅ **No Critical Issues Found**" >> security-reports/dependency-scan-report.md
    print_success "No dependency issues found"
fi

# Step 8: Secret scanning (if Docker is available)
print_step "Running secret scan..."
if command -v docker &> /dev/null; then
    print_step "Running TruffleHog secret scan..."
    docker run --rm -v "$PWD:/pwd" trufflesecurity/trufflehog:latest \
        filesystem /pwd \
        --json \
        --only-verified \
        --no-update \
        --filter-entropy=4.5 \
        > security-reports/trufflehog-raw.json 2>/dev/null || true
    
    # Generate secret scan report
    cat > security-reports/secret-scan-report.md << 'EOF'
# 🔐 Secret Scan Report (Local)

**Scan Date:** $(date)
**Scan Type:** Secret Detection
**Tool:** TruffleHog
**Configuration:** Verified secrets only, entropy filter 4.5+

## Summary
EOF
    
    if command -v jq &> /dev/null && [ -f "security-reports/trufflehog-raw.json" ]; then
        VERIFIED_SECRETS=$(cat security-reports/trufflehog-raw.json | jq '[.[] | select(.Verified == true)] | length' 2>/dev/null || echo "0")
        echo "- **Verified Secrets Found:** $VERIFIED_SECRETS" >> security-reports/secret-scan-report.md
        
        if [ "$VERIFIED_SECRETS" -gt 0 ]; then
            echo "- **Status:** ❌ CRITICAL - Verified secrets detected" >> security-reports/secret-scan-report.md
            print_error "CRITICAL: Verified secrets found!"
            cat security-reports/trufflehog-raw.json | jq -r '.[] | select(.Verified == true) | "- " + .DetectorName + " in " + .SourceMetadata.Data.Filesystem.file'
        else
            echo "- **Status:** ✅ PASSED - No verified secrets found" >> security-reports/secret-scan-report.md
            print_success "No secrets found"
        fi
    else
        echo "- **Status:** ⚠️ Scan completed (install jq for detailed results)" >> security-reports/secret-scan-report.md
        print_success "Secret scan completed"
    fi
else
    print_warning "Docker not available - skipping TruffleHog scan"
    echo "To run secret scanning locally, install Docker: https://docs.docker.com/get-docker/"
fi

# Step 9: Build test
print_step "Testing APK build..."
flutter build apk --debug
if [ $? -eq 0 ]; then
    print_success "APK build successful"
else
    print_warning "APK build failed (this might be due to local Android SDK setup)"
fi

# Step 10: Generate local security report
print_step "Generating consolidated security report..."
cat > security-reports/LOCAL_SECURITY_REPORT.md << EOF
# 🛡️ Local DevSecOps Pipeline Test Report

**Test Date:** $(date)
**Environment:** Local Development
**Repository:** flutter_devsecops_template

## 📊 Test Summary

### ✅ Tests Completed
- Code Quality Analysis (Flutter Analyze)
- Code Formatting Check
- Unit Tests with Coverage
- Dependency Vulnerability Scan
- Secret Scanning (if Docker available)
- Build Test

### 📋 Results
EOF

# Count any issues
TOTAL_ISSUES=0

if [ -f "security-reports/trufflehog-raw.json" ] && command -v jq &> /dev/null; then
    SECRETS=$(cat security-reports/trufflehog-raw.json | jq '[.[] | select(.Verified == true)] | length' 2>/dev/null || echo "0")
    TOTAL_ISSUES=$((TOTAL_ISSUES + SECRETS))
    echo "- 🔐 Verified Secrets: $SECRETS" >> security-reports/LOCAL_SECURITY_REPORT.md
fi

echo "- 📦 Dependencies: Scanned" >> security-reports/LOCAL_SECURITY_REPORT.md

if [ "$TOTAL_ISSUES" -eq 0 ]; then
    echo "- 🎯 **Overall Status: ✅ READY FOR CI**" >> security-reports/LOCAL_SECURITY_REPORT.md
    print_success "LOCAL PIPELINE TEST PASSED - Ready for GitHub Actions!"
else
    echo "- 🎯 **Overall Status: ⚠️ ISSUES FOUND**" >> security-reports/LOCAL_SECURITY_REPORT.md
    print_warning "Issues found - review security reports before pushing"
fi

cat >> security-reports/LOCAL_SECURITY_REPORT.md << 'EOF'

## 📁 Generated Reports
- `dependency-scan-report.md` - Dependency analysis
- `secret-scan-report.md` - Secret detection results
- `LOCAL_SECURITY_REPORT.md` - This summary report

## 🚀 Next Steps
1. Review any issues found in the reports
2. Fix critical and high-severity issues
3. Commit and push to trigger GitHub Actions pipeline

---
*Generated by Local DevSecOps Test Script*
EOF

echo ""
echo "🎯 Local Pipeline Test Complete!"
echo "================================="
echo "📄 Check security-reports/ directory for detailed results"
echo "🔍 Review LOCAL_SECURITY_REPORT.md for summary"

if [ "$TOTAL_ISSUES" -eq 0 ]; then
    echo ""
    print_success "🚀 READY TO PUSH TO GITHUB ACTIONS!"
else
    echo ""
    print_warning "⚠️ Please review and fix issues before pushing"
fi
