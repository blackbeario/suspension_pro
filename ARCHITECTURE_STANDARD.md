# RideMetrx Architecture Standard

**Last Updated:** 2025-12-03

This document defines the **official architecture pattern** for RideMetrx. All new features and refactoring work MUST follow this standard.

---

## 🎯 Core Principle: Simplified MVVM

We use **MVVM (Model-View-ViewModel)** with Riverpod, keeping it simple and avoiding over-engineering.

### Why Not Clean Architecture?
- Too many layers makes it hard to find actual implementation code
- Repository abstraction adds complexity without clear benefit for this app size
- Direct service calls are acceptable and easier to trace

---

## 📁 Feature Folder Structure

Every feature follows this **exact structure**:

```
features/
└── {feature_name}/
    ├── data/                    ← EMPTY (we don't use this)
    ├── domain/
    │   ├── models/              ← Domain models (Bike, Setting, etc.)
    │   │   ├── bike.dart
    │   │   └── bike.g.dart
    │   ├── {feature}_notifier.dart    ← Business logic + state management
    │   ├── {feature}_notifier.g.dart
    │   └── {feature}_state.dart       ← State classes (if needed)
    └── presentation/
        ├── view_models/         ← Screen-specific ViewModels
        │   └── {screen}_view_model.dart
        ├── screens/             ← Full page screens
        │   └── {screen}_screen.dart
        └── widgets/             ← Reusable UI components
            └── {widget}_widget.dart
```

---

## 📋 Layer Responsibilities

### 1. **Domain Layer** (`domain/`)

Contains business logic and state management.

#### `domain/models/`
- Pure Dart classes representing business entities
- Immutable models using `@freezed` or manual copyWith
- Serialization methods: `fromJson()`, `toJson()`, `fromFirestore()`
- **NO** UI logic, **NO** BuildContext

**Example:**
```dart
// domain/models/bike.dart
@HiveType(typeId: 0)
class Bike extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String yearModel;

  Bike({required this.id, required this.yearModel});

  factory Bike.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

#### `domain/{feature}_notifier.dart`
- **This is the heart of your feature's business logic**
- Manages feature-level state using Riverpod Notifier
- Calls services directly (auth_service, db_service, hive_service)
- Handles data synchronization, caching, CRUD operations
- **NO** UI logic, **NO** BuildContext

**Example:**
```dart
// domain/settings_notifier.dart
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  List<Setting> build(String bikeId) {
    // Initialize from Hive
    // Listen to Firebase stream if Pro
    return _getSettingsFromHive(bikeId);
  }

  Future<void> addUpdateSetting(Setting setting) async {
    // Save to Hive immediately
    // Sync to Firebase if Pro
  }

  Future<void> deleteSetting(String settingId) async {
    // Tombstone pattern for offline-first
  }
}
```

**Key Rule:** If it manipulates domain models or calls services, it goes here.

---

### 2. **Presentation Layer** (`presentation/`)

Contains all UI code.

#### `presentation/view_models/`
- **Screen-specific** logic only
- Handles UI-specific operations like formatting, validation, dialog results
- Delegates business operations to domain notifiers
- Uses Riverpod for lightweight state (optional)
- **MAY** have BuildContext for showing dialogs/snackbars

**Example:**
```dart
// presentation/view_models/settings_list_view_model.dart
@riverpod
class SettingsListViewModel extends _$SettingsListViewModel {
  @override
  void build() {}

  // UI-specific operations
  String formatForkProduct(Bike bike) { ... }
  String generateCloneName(String name) => '$name (Copy)';

  // Delegates to domain notifier
  Future<bool> cloneSetting({
    required Setting originalSetting,
    required String newName,
    required String bikeId,
  }) async {
    final notifier = ref.read(settingsNotifierProvider(bikeId).notifier);
    await notifier.addUpdateSetting(clonedSetting);
    return true;
  }
}
```

**Key Rule:** If it's screen-specific or formats data for display, it goes here.

#### `presentation/screens/`
- Full-page screens (routes)
- ConsumerWidget or ConsumerStatefulWidget
- **NO** business logic - only UI structure
- Calls ViewModel methods for operations
- Shows dialogs, navigation, SnackBars

**Example:**
```dart
// presentation/screens/settings_list.dart
class SettingsList extends ConsumerStatefulWidget {
  // Widget keys, UI state (GlobalKeys, controllers)
  final List<GlobalKey<InlineListTileActionsState>> _actionKeys = [];

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifierProvider(bike.id));
    final viewModel = ref.read(settingsListViewModelProvider.notifier);

    return ListView.builder(
      itemBuilder: (context, index) {
        // UI-only code
        onPressed: () async {
          final confirmed = await _showDeleteDialog(context);
          if (confirmed) {
            await viewModel.deleteSetting(...);
          }
        }
      }
    );
  }

  // Dialog methods stay here (presentation concern)
  Future<bool?> _showDeleteDialog(BuildContext context) { ... }
}
```

**Key Rule:** Widgets manage UI state (keys, controllers) and presentation logic only.

#### `presentation/widgets/`
- Reusable UI components
- Dumb widgets that accept props
- **NO** business logic

---

### 3. **Data Layer** (`data/`)

**WE DON'T USE THIS FOLDER.**

Instead:
- All data access goes through `core/services/` (auth_service, db_service, hive_service)
- Domain notifiers call services directly
- Keep it simple - no repository pattern

---

## 🔄 Data Flow

```
User Action in Screen
    ↓
ViewModel method (if needed for UI-specific logic)
    ↓
Domain Notifier method
    ↓
Service (db_service, hive_service, auth_service)
    ↓
Firebase / Hive
```

**State updates flow back automatically via Riverpod watchers.**

---

## ✅ Decision Tree: Where Does This Code Go?

### Does it manipulate domain models (Bike, Setting)?
→ **Domain Notifier**

### Does it call a service (Firebase, Hive)?
→ **Domain Notifier**

### Does it format data specifically for ONE screen?
→ **ViewModel**

### Does it show a dialog or navigate?
→ **Screen Widget**

### Does it manage widget state (Keys, Controllers)?
→ **Screen Widget**

### Is it a reusable UI component?
→ **Widget**

---

## 🚫 Anti-Patterns to Avoid

❌ **Don't put business logic in screens:**
```dart
// BAD - Business logic in UI
onPressed: () {
  final setting = Setting(...);
  ref.read(settingsNotifierProvider.notifier).addUpdateSetting(setting);
}
```

✅ **Do use ViewModels for screen operations:**
```dart
// GOOD - Delegate to ViewModel
onPressed: () {
  viewModel.cloneSetting(originalSetting, newName, bikeId);
}
```

---

❌ **Don't create ViewModels for every screen:**
```dart
// BAD - Unnecessary ViewModel for simple list
class BikeListViewModel {
  List<Bike> getBikes() => ref.watch(bikesNotifierProvider);
}
```

✅ **Do directly watch notifiers for simple screens:**
```dart
// GOOD - Direct watch for simple display
final bikes = ref.watch(bikesNotifierProvider);
```

---

❌ **Don't move dialog methods to ViewModels:**
```dart
// BAD - Dialog presentation in ViewModel
class MyViewModel {
  Future<bool> showDeleteDialog(BuildContext context) { ... }
}
```

✅ **Do keep dialog methods in widgets:**
```dart
// GOOD - Dialogs are presentation layer
class MyScreen extends ConsumerWidget {
  Future<bool?> _showDeleteDialog(BuildContext context) { ... }
}
```

---

## 📝 File Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Domain Model | `{entity}.dart` | `bike.dart`, `setting.dart` |
| Domain Notifier | `{feature}_notifier.dart` | `settings_notifier.dart` |
| Domain State | `{feature}_state.dart` | `bikes_state.dart` |
| ViewModel | `{screen}_view_model.dart` | `settings_list_view_model.dart` |
| Screen | `{name}_screen.dart` | `bike_details_screen.dart` |
| Widget | `{name}_widget.dart` | `bike_card_widget.dart` |

---

## 🎓 Real Examples from RideMetrx

### ✅ CORRECT: Auth Feature

```
features/auth/
├── domain/
│   ├── models/user.dart           ← Domain model
│   ├── user_notifier.dart         ← Business logic
│   └── user_state.dart            ← State classes
└── presentation/
    ├── auth_view_model.dart       ← Screen-specific operations
    └── screens/
        ├── login_page.dart        ← UI only
        └── signup_page.dart
```

**Why it's correct:**
- `user_notifier.dart` manages user state and auth business logic
- `auth_view_model.dart` handles login/signup UI operations
- Screens are pure presentation

---

### ✅ CORRECT: Bikes Feature (After Refactor)

```
features/bikes/
├── domain/
│   ├── models/
│   │   ├── bike.dart
│   │   └── setting.dart
│   ├── bikes_notifier.dart        ← Bike CRUD + state
│   └── settings_notifier.dart     ← Setting CRUD + state
└── presentation/
    ├── view_models/
    │   └── settings_list_view_model.dart  ← Screen-specific formatting
    ├── screens/
    │   └── settings_list.dart
    └── widgets/
```

**Why it's correct:**
- Clear separation: notifiers handle business logic
- ViewModel handles screen-specific operations (formatting, clone logic)
- Screens handle only UI and dialogs

---

## 🚀 When Building a New Feature

1. **Create the folder structure:**
   ```bash
   mkdir -p features/my_feature/{domain/models,presentation/{screens,widgets,view_models}}
   ```

2. **Start with domain models:**
   - Define your entities
   - Add serialization methods

3. **Create the notifier:**
   - Add business logic methods
   - Set up state management
   - Call services directly

4. **Build the UI:**
   - Create screens (presentation-only)
   - Add ViewModels only if needed for screen-specific logic
   - Extract reusable widgets

5. **Ask yourself:** "Can I easily find where this method is implemented?"
   - If yes: ✅ Good architecture
   - If no: ❌ Refactor for clarity

---

## 📞 Services Layer (`core/services/`)

These are shared across all features:

- `auth_service.dart` - Firebase Auth + Hive auth
- `db_service.dart` - Firestore operations
- `hive_service.dart` - Local storage operations
- `sync_service.dart` - Offline sync logic
- `analytics_service.dart` - Analytics tracking

**Rule:** Services are dumb data pipes. Business logic goes in notifiers.

---

## 🔑 Key Takeaways

1. **Keep it simple** - Don't over-engineer
2. **Consistency > perfection** - Follow this standard always
3. **If you can't find it easily, it's wrong** - Clear is better than clever
4. **ViewModels are optional** - Only use when screen needs specific logic
5. **Notifiers are mandatory** - Every feature has a notifier for business logic

---

## 🤖 For Claude AI Sessions

When helping with this codebase:

1. ✅ **DO** follow this standard exactly
2. ✅ **DO** put business logic in domain notifiers
3. ✅ **DO** create ViewModels for screen-specific operations
4. ✅ **DO** keep dialogs and navigation in widgets
5. ❌ **DON'T** suggest repository patterns
6. ❌ **DON'T** create data layer implementations
7. ❌ **DON'T** move dialog methods to ViewModels
8. ❌ **DON'T** put business logic in widgets

**When in doubt:** Ask "Where would I look for this code?" If the answer isn't obvious, the architecture is wrong.

---

*This is the RideMetrx standard. When it conflicts with textbook architecture patterns, this standard wins.*
