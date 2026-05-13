# 📐 Development Guidelines — cloud_computing_2

> **Read this before writing any code.** These rules keep the project clean and consistent across all team members.

---

## 1. Project Structure

Follow this folder structure inside `lib/`. **Do NOT dump everything in `main.dart`.**

```
lib/
├── main.dart                     # App entry point ONLY (runApp + MaterialApp)
│
├── config/                       # App-wide configuration
│   ├── routes.dart               # Named route definitions
│   ├── themes.dart               # ThemeData, colors, typography
│   └── constants.dart            # API URLs, keys, magic numbers
│
├── models/                       # Data classes / entities
│   └── user_model.dart           # Example: class User { ... }
│
├── services/                     # Business logic & external communication
│   ├── api_service.dart          # HTTP client (dio / http)
│   └── auth_service.dart         # Authentication logic
│
├── providers/                    # State management (Provider/Riverpod/Bloc)
│   └── auth_provider.dart        # Example state holder
│
├── screens/                      # Full-page UI (one file per screen)
│   ├── home_screen.dart
│   ├── login_screen.dart
│   └── profile_screen.dart
│
├── widgets/                      # Reusable UI components (buttons, cards, etc.)
│   ├── custom_button.dart
│   └── user_avatar.dart
│
└── utils/                        # Pure helper functions
    ├── validators.dart           # Form validators
    └── formatters.dart           # Date/number formatters
```

### Rules

| Rule | Why |
|---|---|
| **One class per file** | Easy to find, easy to review in PRs |
| **File names = `snake_case.dart`** | Dart convention (`user_model.dart`, not `UserModel.dart`) |
| **Class names = `PascalCase`** | Dart convention (`UserModel`, `HomeScreen`) |
| **No logic in `main.dart`** | It only calls `runApp()` and configures `MaterialApp` |
| **Screens go in `screens/`** | A screen is a full page with its own route |
| **Reusable pieces go in `widgets/`** | If you use it in 2+ places, extract it |
| **API calls go in `services/`** | Never call HTTP directly from a widget |

---

## 2. Naming Conventions

### Files & Folders
```
✅ lib/screens/home_screen.dart
✅ lib/models/event_model.dart
✅ lib/widgets/gradient_button.dart

❌ lib/screens/Home.dart
❌ lib/models/EVENT.dart
❌ lib/homescreen.dart          ← no folder = messy
```

### Classes
```dart
// Screen → suffix "Screen"
class HomeScreen extends StatefulWidget { ... }

// Widget → suffix "Widget" or descriptive name
class GradientButton extends StatelessWidget { ... }

// Model → suffix "Model"
class UserModel { ... }

// Service → suffix "Service"
class ApiService { ... }

// Provider → suffix "Provider" / "Notifier" / "Cubit"
class AuthProvider extends ChangeNotifier { ... }
```

### Variables & Functions
```dart
// camelCase for variables and functions
final String userName = 'Ali';
void fetchUserData() { ... }

// SCREAMING_SNAKE_CASE for constants
const String BASE_URL = 'https://api.example.com';

// Private members start with _
int _counter = 0;
void _incrementCounter() { ... }
```

---

## 3. Git Workflow

### Branch Naming
```
feature/login-page          ← new feature
fix/api-timeout             ← bug fix
refactor/clean-home-screen  ← restructuring
docs/update-readme          ← documentation
```

### Commit Messages
Use clear, descriptive messages:
```
✅ feat: add login screen with email validation
✅ fix: resolve null error on user profile
✅ refactor: extract header widget from home screen
✅ docs: update development guidelines

❌ update
❌ fix bug
❌ asdf
```

### Pull Request Rules
1. **Never push directly to `main`** — always create a branch & PR
2. **At least 1 teammate must review** before merging
3. **PR title** must describe what changed
4. **Delete branch** after merge

---

## 4. Code Style

### Imports Order
Group imports in this order, separated by blank lines:
```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter packages
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// 4. Project files (relative imports)
import '../models/user_model.dart';
import '../services/api_service.dart';
```

### Widget Structure
Keep `build()` methods under **~50 lines**. If it's longer, extract sub-widgets:
```dart
// ❌ BAD — 200-line build method
@override
Widget build(BuildContext context) {
  return Scaffold(
    // ... 200 lines of nested widgets ...
  );
}

// ✅ GOOD — extract pieces
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(),
    body: _buildBody(),
    floatingActionButton: _buildFAB(),
  );
}

Widget _buildAppBar() => AppBar(title: Text('Home'));
Widget _buildBody() => Center(child: Text('Hello'));
Widget _buildFAB() => FloatingActionButton(onPressed: () {}, child: Icon(Icons.add));
```

### State Management
- Pick **one** state management approach and stick with it for the whole project
- Recommended: `Provider` (simple) or `Riverpod` (scalable)
- **Do NOT** mix Provider + setState + Bloc in the same project

---

## 5. Assets & Resources

```
assets/
├── images/          # PNG, JPG, SVG
│   ├── logo.png
│   └── background.jpg
├── icons/           # Custom icon files
├── fonts/           # Custom font files
└── animations/      # Lottie / Rive files
```

Register in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
```

---

## 6. Environment & Secrets

- **NEVER** commit API keys, secrets, or passwords
- Use `.env` file + `flutter_dotenv` package
- Add `.env` to `.gitignore`

```
# .env
API_KEY=your_api_key_here
BASE_URL=https://api.example.com
```

---

## 7. Dependencies

- **Discuss with team** before adding a new package
- Prefer well-maintained packages (check pub.dev scores)
- Document why you added each package in `PROJECT_CONTEXT.md`

---

## 8. Testing

```
test/
├── unit/            # Model & service tests
├── widget/          # Widget tests
└── integration/     # Full flow tests
```

- Name test files: `<original_file>_test.dart`
- Run tests before pushing: `flutter test`

---

## 9. Quick Checklist Before Pushing

- [ ] Code follows the folder structure above
- [ ] File and class names follow conventions
- [ ] No hardcoded strings/URLs (use `constants.dart`)
- [ ] No API keys in source code
- [ ] `flutter analyze` shows no errors
- [ ] Tested on at least one device/emulator
- [ ] Commit message is descriptive
- [ ] PR is linked to the right branch

---

> **📌 Keep this file updated as the team agrees on new conventions.**
