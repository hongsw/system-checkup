# Contributing to System Checkup

First off, thank you for considering contributing to System Checkup! It's people like you that make this tool better for everyone.

## 🌟 Ways to Contribute

### 🐛 Bug Reports
Found a bug? Help us by reporting it!
- Open an issue with a clear title and description
- Include steps to reproduce the bug
- Add system information (OS version, Flutter version)
- Include screenshots if applicable

### 💡 Feature Requests
Have an idea for a new feature?
- Open an issue with the "enhancement" label
- Describe the feature and its use case
- Explain why this feature would be useful

### 📸 Screenshots
Help us showcase the application!
- Take high-quality screenshots
- Save them in the `screenshots/` directory
- Name them descriptively (e.g., `main-screen.png`)
- Update README.md to include them

### 🌍 Translations
Want to add support for your language?
- Create a new language file
- Translate all strings
- Test thoroughly
- Submit a pull request

### 📝 Documentation
Improve our documentation!
- Fix typos or clarify existing docs
- Add examples or tutorials
- Improve installation instructions
- Write blog posts or guides

### 💻 Code Contributions
Ready to code? Here's how:

## 🚀 Development Setup

### Prerequisites
- Flutter 3.27.3 or higher
- Dart 3.6.1 or higher
- Linux (Ubuntu/Debian recommended)
- Git

### Getting Started

1. **Fork the repository**
   ```bash
   # Click the "Fork" button on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR-USERNAME/system-checkup.git
   cd system_checkup
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/ORIGINAL-OWNER/system-checkup.git
   ```

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **Run the app**
   ```bash
   flutter run -d linux
   ```

## 📋 Development Guidelines

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` before committing
- Keep functions small and focused
- Add comments for complex logic

### Commit Messages
Follow the [Conventional Commits](https://www.conventionalcommits.org/) format:

```
feat: add dark mode support
fix: resolve disk usage calculation bug
docs: update installation instructions
style: format code with flutter format
refactor: simplify history service
test: add unit tests for claude service
chore: update dependencies
```

### Branch Naming
- `feature/feature-name` - New features
- `fix/bug-description` - Bug fixes
- `docs/what-changed` - Documentation
- `refactor/what-changed` - Code refactoring

### Pull Request Process

1. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

2. **Make your changes**
   - Write clean, readable code
   - Add tests if applicable
   - Update documentation

3. **Test your changes**
   ```bash
   flutter test
   flutter analyze
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add amazing feature"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```

6. **Open a Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your branch
   - Fill in the PR template
   - Wait for review

### Pull Request Checklist
- [ ] Code follows the style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings or errors
- [ ] Tests added/updated (if applicable)
- [ ] PR description is clear

## 🧪 Testing

### Run Tests
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart
```

### Code Analysis
```bash
# Run static analysis
flutter analyze

# Check formatting
flutter format --set-exit-if-changed .
```

## 📦 Project Structure

```
lib/
├── main.dart                      # Main app entry
├── models/                        # Data models
│   └── analysis_history.dart
├── services/                      # Business logic
│   ├── claude_service.dart
│   ├── storage_service.dart
│   └── history_service.dart
└── screens/                       # UI screens
    ├── settings_screen.dart
    ├── ai_analysis_screen.dart
    ├── history_screen.dart
    └── history_detail_screen.dart
```

## 🎨 UI/UX Guidelines

- Follow Material Design 3 principles
- Maintain consistent spacing (8px grid)
- Use theme colors from `colorScheme`
- Ensure accessibility (contrast, font sizes)
- Test on different screen sizes

## 🔐 Security

- Never commit API keys or secrets
- Use `flutter_secure_storage` for sensitive data
- Validate all user inputs
- Follow OWASP guidelines

## 📝 Documentation

When adding new features:
- Update README.md
- Add inline code comments
- Update DEVELOPMENT.md if needed
- Create examples if complex

## ❓ Questions?

- Open a [Discussion](https://github.com/OWNER/system-checkup/discussions)
- Ask in [Issues](https://github.com/OWNER/system-checkup/issues)
- Check existing documentation

## 🎉 Recognition

Contributors will be:
- Listed in README.md
- Mentioned in release notes
- Part of our amazing community!

## 📄 Code of Conduct

### Our Pledge
We pledge to make participation in our project a harassment-free experience for everyone.

### Our Standards
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community

### Enforcement
Unacceptable behavior may be reported to the project team. All complaints will be reviewed and investigated.

---

Thank you for contributing to System Checkup! 🚀

**Happy Coding!** 💻
