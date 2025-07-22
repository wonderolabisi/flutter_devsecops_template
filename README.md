# Flutter DevSecOps Template

🔐 A comprehensive Flutter application template with integrated DevSecOps practices, including automated security scanning, code quality checks, and CI/CD pipeline.

## 🔧 Features

### Security Features
- 🔐 Secret scanning with TruffleHog
- 🛡️ Static Application Security Testing (SAST) with CodeQL
- 📊 Dependency vulnerability scanning
- 🔍 Container security scanning with Trivy
- 🚨 OSSAR (Open Source Static Analysis Runner)

### Development Features
- ✅ Automated testing with coverage reporting
- 📝 Code formatting and linting
- 🏗️ Automated builds (APK and App Bundle)
- 📦 Dependency management with Dependabot
- 🚀 CI/CD with GitHub Actions

## 📁 Folder Structure
- `lib/`: Application source code
- `test/`: Unit and widget tests
- `.github/workflows/`: CI/CD DevSecOps pipelines
- `.github/dependabot.yml`: Automated dependency updates
- `.github/codeql/`: Security analysis configuration

## 🚀 Usage

### Local Development
1. Clone this repo
2. Run `flutter pub get`
3. Run tests: `flutter test`
4. Analyze code: `flutter analyze`
5. Format code: `dart format .`

### CI/CD Pipeline
Push to GitHub — the pipeline will:
1. Install Flutter and dependencies
2. Run security scans (secrets, vulnerabilities)
3. Perform code quality checks
4. Execute tests with coverage
5. Build APK and App Bundle
6. Upload artifacts

## 🧪 Test Locally
```bash
flutter pub get
flutter test
flutter analyze
dart format . --set-exit-if-changed
flutter build apk --release
```

## 🔒 Security Features
- **Secret Detection**: Automatically scans for accidentally committed secrets
- **Dependency Scanning**: Checks for vulnerable dependencies
- **Code Analysis**: Static analysis for security vulnerabilities
- **Automated Updates**: Dependabot keeps dependencies secure

## 📋 Requirements
- Flutter 3.24.0+
- Dart SDK 3.5.0+ (included with Flutter)
- Java 17+ (for Android builds)

## 🤝 Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure all tests pass
5. Submit a pull request

---
**Note**: Never commit secrets or sensitive data. The pipeline includes security scanning to detect and prevent this.
