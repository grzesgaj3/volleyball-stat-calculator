# Contributing to Volleyball Stat Calculator

Thank you for your interest in contributing to the Volleyball Stat Calculator!

## Development Setup

### Prerequisites
- Flutter SDK (>=3.0.0)
- Git
- A code editor (VS Code, Android Studio, or IntelliJ IDEA recommended)

### Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/volleyball-stat-calculator.git
   cd volleyball-stat-calculator
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Code Style

This project follows Flutter/Dart best practices:

- Use `const` constructors where possible
- Follow the style guide in `analysis_options.yaml`
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Linting

Run the analyzer before committing:
```bash
flutter analyze
```

Fix formatting issues:
```bash
flutter format lib/ test/
```

## Testing

### Running Tests

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/stats_test.dart
```

### Writing Tests

- Add tests for all new features
- Test edge cases (zero values, empty lists, etc.)
- Use descriptive test names
- Follow the existing test structure

Example:
```dart
void main() {
  test('should calculate effectiveness correctly', () {
    final stats = ActionStats(plus: 10, minus: 5, star: 5);
    expect(stats.effectiveness, equals(75.0));
  });
}
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
│   ├── player.dart
│   └── stats.dart
└── screens/               # UI screens
    ├── match_title_screen.dart
    ├── player_entry_screen.dart
    ├── stats_tracking_screen.dart
    └── statistics_screen.dart
```

## Adding New Features

### Adding a New Action Type

1. Update `_actionTypes` list in `stats_tracking_screen.dart`:
   ```dart
   final List<String> _actionTypes = [
     'Attack',
     'Serve',
     'Block',
     'Reception',
     'Dig',
     'YourNewAction', // Add here
   ];
   ```

### Adding a New Player Position

1. Update `_positions` list in `player_entry_screen.dart`:
   ```dart
   final List<String> _positions = [
     'Setter',
     'Outside Hitter',
     'Middle Blocker',
     'Opposite',
     'Libero',
     'YourNewPosition', // Add here
   ];
   ```

### Adding More Sets

1. Update set selector in `stats_tracking_screen.dart`:
   ```dart
   ...List.generate(7, (index) { // Change 5 to 7 for 7 sets
     final setNum = index + 1;
     // ...
   }),
   ```

## Commit Message Guidelines

Use clear, descriptive commit messages:

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

Examples:
```
feat: Add export statistics to PDF feature
fix: Correct effectiveness calculation for zero stats
docs: Update README with installation instructions
test: Add tests for PlayerStats class
```

## Pull Request Process

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit:
   ```bash
   git add .
   git commit -m "feat: your feature description"
   ```

3. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

4. Create a Pull Request on GitHub

5. Ensure all checks pass:
   - Code analysis
   - Tests
   - Build

6. Wait for review and address any feedback

## Reporting Issues

### Bug Reports

Include:
- Description of the bug
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Device/platform information
- Flutter version

### Feature Requests

Include:
- Clear description of the feature
- Use case/motivation
- Proposed solution (optional)
- Alternative solutions considered (optional)

## Code Review Guidelines

When reviewing code:
- Be constructive and respectful
- Focus on code quality, not personal preferences
- Suggest improvements with explanations
- Approve when ready

## Questions?

If you have questions:
1. Check existing documentation (README.md, ARCHITECTURE.md, QUICK_START.md)
2. Search existing issues
3. Create a new issue with the "question" label

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.
