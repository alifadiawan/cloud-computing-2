# 🤖 PROJECT_CONTEXT.md — AI/LLM Reference File

> **⚠️ ATTENTION AI / LLM / Copilot / ChatGPT / Claude / Gemini / Any Assistant:**
>
> **READ THIS FILE FIRST** before making any changes to this project.
> This file is the single source of truth for project context.
> **UPDATE THIS FILE** whenever you add features, change architecture, or modify dependencies.
> **Tell your human** to point the next AI to this file.

---

## 📋 Project Overview

| Field | Value |
|---|---|
| **Project Name** | cloud_computing_2 |
| **Type** | Flutter Mobile Application |
| **Dart SDK** | ^3.11.4 |
| **Flutter Version** | Latest stable |
| **State Management** | *Not yet chosen — team must decide* |
| **Target Platforms** | Android, iOS, Web (optional) |
| **Team Size** | Multiple developers (academic project) |
| **Last Updated** | 2026-05-13 |

---

## 📁 Project Structure

> See `DEVELOPMENT_GUIDELINES.md` for the full conventions.

```
lib/
├── main.dart              # Entry point — runApp() only
├── config/                # Routes, themes, constants
├── models/                # Data classes
├── services/              # API & business logic
├── providers/             # State management
├── screens/               # Full-page views
├── widgets/               # Reusable UI components
└── utils/                 # Helpers & formatters
```

**Current state:** The project is in its initial state with only `lib/main.dart` containing the default Flutter counter demo. No custom screens, models, or services have been created yet.

---

## 🧩 Features & Screens

> Update this table as new features are added.

| # | Feature | Screen File | Status | Owner |
|---|---------|-------------|--------|-------|
| 1 | Counter Demo | `main.dart` (default) | ✅ Default | — |

<!-- 
TEMPLATE — copy and fill when adding a new feature:
| # | Feature Name | `screens/feature_screen.dart` | 🚧 In Progress | @member_name |
-->

---

## 📦 Dependencies

> Update this table when adding or removing packages.

| Package | Version | Purpose | Added By | Date |
|---------|---------|---------|----------|------|
| flutter | SDK | Core framework | default | — |
| cupertino_icons | ^1.0.8 | iOS-style icons | default | — |
| flutter_lints | ^6.0.0 | Lint rules (dev) | default | — |

<!--
TEMPLATE — copy and fill when adding a new package:
| package_name | ^x.x.x | What it does | @member_name | YYYY-MM-DD |
-->

---

## 🗄️ Data Models

> Update this section as models are created.

*No models have been created yet.*

<!--
TEMPLATE:
### ModelName (`lib/models/model_name.dart`)
```dart
class ModelName {
  final int id;
  final String name;
  // ...
}
```
**Used by:** ScreenName, ServiceName
-->

---

## 🌐 API Endpoints

> Document all API endpoints the app communicates with.

*No API endpoints configured yet.*

<!--
TEMPLATE:
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | /api/users | Fetch all users | Yes |
| POST | /api/login | User login | No |
-->

---

## 🔀 Routes / Navigation

> Document all app routes.

*Using default MaterialApp home — no named routes configured yet.*

<!--
TEMPLATE:
| Route Name | Path | Screen | Auth Guard |
|------------|------|--------|------------|
| home | / | HomeScreen | No |
| login | /login | LoginScreen | No |
| profile | /profile | ProfileScreen | Yes |
-->

---

## 🎨 Theme & Design

| Property | Value |
|----------|-------|
| **Primary Color** | `Colors.deepPurple` (default seed) |
| **Theme Mode** | Light only (default) |
| **Custom Fonts** | None |
| **Design System** | Material 3 (default) |

---

## 🔧 Environment Setup

```bash
# Clone the project
git clone <repo-url>
cd cloud_computing_2

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test
```

---

## 📝 Changelog

> Add entries here whenever significant changes are made.

| Date | Change | By |
|------|--------|----|
| 2026-05-13 | Project initialized with Flutter default template | Team |
| 2026-05-13 | Added DEVELOPMENT_GUIDELINES.md and PROJECT_CONTEXT.md | AI Assistant |

---

## 🚨 Known Issues & Technical Debt

*No known issues yet.*

<!--
TEMPLATE:
| Issue | Severity | File(s) | Notes |
|-------|----------|---------|-------|
| Hardcoded API URL | Medium | services/api_service.dart | Move to .env |
-->

---

## 🧠 Instructions for AI Assistants

### Before making any change:
1. **Read this file completely**
2. **Read `DEVELOPMENT_GUIDELINES.md`** for coding conventions
3. **Check the Features table** to understand what exists
4. **Check the Dependencies table** before adding packages

### After making any change:
1. **Update the Features table** if you added/modified a screen
2. **Update the Dependencies table** if you added/removed a package
3. **Update the Data Models section** if you created/changed a model
4. **Update the API Endpoints section** if you added API calls
5. **Update the Routes section** if you added navigation routes
6. **Update the Changelog** with a one-line summary of what you did
7. **Update "Current state"** description if the project status changed

### Code placement rules:
- New screens → `lib/screens/`
- New reusable widgets → `lib/widgets/`
- New data models → `lib/models/`
- New API/service logic → `lib/services/`
- New state management → `lib/providers/`
- Constants/config → `lib/config/`
- Helper functions → `lib/utils/`
- **NEVER** put everything in `main.dart`

### Style rules:
- File names: `snake_case.dart`
- Class names: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `SCREAMING_SNAKE_CASE`
- Max 50 lines in a `build()` method — extract sub-widgets
- Group imports: Dart SDK → Flutter → Third-party → Project

---

> **🔄 This file is a living document. Keep it updated as the project evolves.**
> **📎 Tell your teammates and any AI assistant to read this file first.**
