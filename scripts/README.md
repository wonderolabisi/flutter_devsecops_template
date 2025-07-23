# Local DevSecOps Pipeline Testing

This directory contains scripts to test your DevSecOps pipeline locally before pushing to GitHub Actions.

## 🚀 Quick Start

### Windows (Recommended)

**PowerShell (Most Features):**
```powershell
# Run from project root
.\scripts\test-pipeline-locally.ps1

# Skip build test (faster)
.\scripts\test-pipeline-locally.ps1 -SkipBuild

# Verbose output
.\scripts\test-pipeline-locally.ps1 -Verbose
```

**Command Prompt:**
```cmd
# Run from project root
scripts\test-pipeline-locally.bat
```

### Linux/macOS

**Bash:**
```bash
# Make executable and run
chmod +x scripts/test-pipeline-locally.sh
./scripts/test-pipeline-locally.sh
```

## 📋 What Gets Tested

### ✅ Core Pipeline Steps
1. **Flutter Installation Check**
2. **Dependency Installation** (`flutter pub get`)
3. **Code Quality Analysis** (`flutter analyze`)
4. **Code Formatting** (`dart format`)
5. **Unit Tests with Coverage** (`flutter test --coverage`)
6. **Dependency Vulnerability Scan** (Pana)
7. **Secret Scanning** (TruffleHog - requires Docker)
8. **Build Test** (APK debug build)

### 📊 Generated Reports
- `dependency-scan-report.md` - Dependency vulnerability analysis
- `secret-scan-report.md` - Secret detection results
- `LOCAL_SECURITY_REPORT.md` - Consolidated test summary

## 🔧 Prerequisites

### Required
- ✅ Flutter SDK (3.24.0+)
- ✅ Dart SDK (3.5.0+)
- ✅ Git

### Optional (for full testing)
- 🐳 Docker (for secret scanning with TruffleHog)
- 📱 Android SDK (for APK builds)
- 🔧 jq (for JSON processing - Linux/macOS)

## 📖 Usage Examples

### Quick Test (Skip Build)
```powershell
# Faster testing without build
.\scripts\test-pipeline-locally.ps1 -SkipBuild
```

### Full Test with Verbose Output
```powershell
# Complete test with detailed output
.\scripts\test-pipeline-locally.ps1 -Verbose
```

### CI Simulation Test
```bash
# Linux/macOS - full CI simulation
./scripts/test-pipeline-locally.sh
```

## 🎯 Interpreting Results

### ✅ Success Indicators
- All tests pass
- Code analysis shows no issues
- No verified secrets found
- Build completes successfully

### ⚠️ Warning Signs
- Code formatting issues (easily fixable)
- Dependency warnings
- Build failures (usually local SDK issues)

### ❌ Critical Issues
- Code analysis errors
- Test failures
- Verified secrets detected

## 🔍 Troubleshooting

### Common Issues

**"Flutter not found"**
```bash
# Make sure Flutter is in your PATH
flutter --version
```

**"Docker not available"**
```bash
# Install Docker for secret scanning
# Windows: https://docs.docker.com/desktop/windows/
# macOS: https://docs.docker.com/desktop/mac/
# Linux: https://docs.docker.com/engine/install/
```

**"Build failed"**
```bash
# Check Android SDK setup
flutter doctor -v

# For testing purposes, you can skip builds
.\scripts\test-pipeline-locally.ps1 -SkipBuild
```

**"Permission denied" (Linux/macOS)**
```bash
# Make script executable
chmod +x scripts/test-pipeline-locally.sh
```

## 📈 Best Practices

### Before Every Push
1. **Run local tests**: `.\scripts\test-pipeline-locally.ps1`
2. **Review reports**: Check `security-reports/LOCAL_SECURITY_REPORT.md`
3. **Fix issues**: Address any critical or high-severity findings
4. **Verify clean**: Ensure ✅ status before pushing

### Development Workflow
```bash
# 1. Make code changes
# 2. Run local pipeline test
.\scripts\test-pipeline-locally.ps1

# 3. Fix any issues found
dart format .
flutter test

# 4. Re-test if needed
.\scripts\test-pipeline-locally.ps1 -SkipBuild

# 5. Commit and push
git add .
git commit -m "feat: your changes"
git push origin main
```

## 🔧 Customization

### Modify Test Scripts
You can customize the test scripts to:
- Add additional security tools
- Skip certain tests for faster iteration
- Add custom validation steps
- Integrate with your IDE

### Environment Variables
Set these for enhanced testing:
```bash
# Skip certain tests
export SKIP_BUILD=true
export SKIP_SECRETS=true

# Custom tool paths
export FLUTTER_ROOT=/path/to/flutter
export ANDROID_HOME=/path/to/android-sdk
```

## 🚀 Integration with IDEs

### VS Code
Add to `.vscode/tasks.json`:
```json
{
    "label": "Test Pipeline Locally",
    "type": "shell",
    "command": "./scripts/test-pipeline-locally.ps1",
    "group": "test",
    "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "new"
    }
}
```

### IntelliJ/Android Studio
Create a custom run configuration pointing to the test script.

---

**💡 Pro Tip**: Run these tests regularly during development to catch issues early and ensure your GitHub Actions pipeline will succeed!
