# Atomic - Personal Habit & Wellness Tracker

A comprehensive Flutter mobile application designed to help users build lasting habits, track nutrition, manage tasks, and capture notes. Built with clean architecture principles and modern Flutter development practices, this app empowers users to achieve sustainable personal growth through incremental behavioral changes.

**NEW**: Now featuring an Android home screen widget for quick access to all app features!

## Overview

Atomic is a mobile productivity and wellness app that combines habit tracking, food logging, task management, and note-taking into a single, cohesive experience. By focusing on small, consistent actions, users can create meaningful lifestyle improvements over time.

## Key Features

- **Habit Tracking**: Create and monitor both positive and negative habits with flexible tracking modes
  - Boolean habits (Yes/No checkbox tracking)
  - Counter habits (quantity-based tracking with optional targets)
  - **Date selection**: Submit habits for any past date with calendar picker and navigation
  - **Drag-and-drop reordering**: Organize habits by dragging them into your preferred order
  - Visual progress analytics with weekly and monthly calendar views
  - Per-habit view customization (week or month view for each habit independently)
  - Positive/negative habit differentiation for building or avoiding behaviors
  - Persistent habit ordering across app sessions

- **Food & Nutrition Tracking**: Comprehensive meal logging and nutritional analysis
  - Track meals across breakfast, lunch, dinner, and snacks
  - Create and manage custom food items with detailed nutritional information
  - Daily nutrition totals and progress tracking
  - Analytics dashboard with historical data visualization (calories, protein, carbs, fats)
  - Pre-populated food database for quick logging
  - Robust error handling for edge cases (empty data states)

- **Task Management**: Organize daily tasks and to-dos efficiently
  - Create, edit, and delete tasks with priority levels
  - Mark tasks as complete or incomplete
  - **Drag-and-drop reordering**: Arrange todos in your preferred order
  - Enhanced readability with optimized font sizes
  - Clean, intuitive interface for task organization
  - Persistent todo ordering across sessions

- **Notes with Attachments**: Capture thoughts and ideas with rich media support
  - Create text notes with titles and content
  - Attach images to notes for visual reference
  - Edit and delete notes as needed
  - Persistent local storage for all notes

- **Dashboard & Analytics**: Centralized view of all your data
  - Calendar views for habits with weekly and monthly options
  - Quick access to all features from a single screen
  - Real-time updates across all features

- **Android Home Screen Widget**: Quick access without opening the app
  - **4-section navigation**: Direct access to Todos, Food, Habits, and Notes
  - Compact 3x2 widget size (180dp × 110dp)
  - Custom icons for each section with dark theme design
  - Bidirectional navigation between widget and app
  - App branding with logo and "Atomic Habits" header
  - Tap any section to open directly to that feature

## Tech Stack

### Core Technologies
- **Flutter SDK**: Cross-platform mobile development framework
- **Dart**: Programming language

### Architecture & Patterns
- **Clean Architecture**: Clear separation of concerns across presentation, domain, and data layers
- **BLoC Pattern**: State management using flutter_bloc for predictable state changes
- **Functional Programming**: Error handling with dartz's Either monad pattern
- **Dependency Injection**: GetIt service locator for loosely coupled dependencies

### Key Dependencies
- `flutter_bloc`: State management and business logic separation
- `get_it`: Dependency injection container
- `dartz`: Functional programming utilities (Either, Option)
- `shared_preferences`: Local data persistence
- `sizer`: Responsive UI sizing
- `intl`: Date formatting and internationalization
- `image_picker`: Camera and gallery image selection for notes
- `fl_chart`: Beautiful charts for nutrition analytics
- `home_widget`: Android home screen widget integration
- `table_calendar`: Calendar widgets for date selection
- `reorderable_list`: Drag-and-drop list reordering

## Project Structure

The project follows clean architecture principles with a feature-based organization:

```
lib/
├── core/
│   ├── abstracts/           # Abstract base classes (UseCase)
│   ├── constants/           # App-wide constants (colors, prefs keys)
│   ├── dependency_injection/ # GetIt setup and feature DI modules
│   ├── errors/              # Failure classes for error handling
│   ├── helpers/             # Helper utilities (PrefsHelper, functional types)
│   ├── router/              # App routing configuration
│   └── widgets/             # Shared UI components
│
├── features/
│   ├── habits_feature/
│   │   ├── data/
│   │   │   ├── entities/    # Data transfer objects
│   │   │   ├── repositories/ # Repository implementations
│   │   │   └── sources/     # Data source implementations
│   │   ├── domain/
│   │   │   ├── models/      # Business logic models
│   │   │   ├── repositories/ # Abstract repository interfaces
│   │   │   └── usecases/    # Application business rules
│   │   └── presentation/
│   │       ├── bloc/        # BLoC state management
│   │       ├── pages/       # Screen implementations
│   │       └── widgets/     # Feature-specific widgets
│   │
│   ├── food_feature/        # Same structure as habits_feature
│   ├── dashboard_feature/   # Same structure as habits_feature
│   ├── todos_feature/       # Same structure as habits_feature
│   └── notes_feature/       # Same structure as habits_feature
│
└── main.dart                # App entry point
```

### Architecture Layers

Each feature is organized into three distinct layers:

1. **Presentation Layer**: UI components, screens, and BLoC state management
2. **Domain Layer**: Business logic, models, abstract repositories, and use cases
3. **Data Layer**: Data sources (local/remote), concrete repository implementations, and entities

This separation ensures:
- Clear dependencies flowing inward (presentation → domain → data)
- Easy testability at each layer
- Flexibility to swap implementations without affecting business logic
- Scalability for future feature additions

## Getting Started

### Prerequisites

- Flutter SDK (version 3.0 or higher recommended)
- Dart SDK (included with Flutter)
- Android Studio / Xcode for platform-specific builds
- A connected device or emulator

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd atomic_habits
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

### Development Commands

#### Running the App
```bash
# Run on connected device/emulator
flutter run

# Run in debug mode (default)
flutter run --debug

# Run in release mode (optimized)
flutter run --release

# Run on specific device
flutter devices                    # List available devices
flutter run -d <device-id>         # Run on specific device
```

#### Building
```bash
# Build Android APK
flutter build apk

# Build Android App Bundle (for Play Store)
flutter build appbundle

# Build iOS app (requires macOS and Xcode)
flutter build ios
```

#### Testing & Quality
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Analyze code for issues
flutter analyze

# Format code to Dart style guidelines
dart format lib/
```

#### Maintenance
```bash
# Clean build artifacts
flutter clean

# Update dependencies
flutter pub upgrade

# Check outdated packages
flutter pub outdated
```

## Data Persistence

All user data is stored locally on the device using SharedPreferences:

- **No backend required**: Fully functional offline app
- **Data format**: JSON serialization for complex objects
- **PrefsHelper**: Centralized data access layer in `core/helpers/prefs_helper.dart`
- **Keys management**: Constants defined in `core/constants/prefs_keys.dart`
- **ID generation**: Random IDs using pattern `10000 + Random().nextInt(90000)`

## State Management

The app uses the **BLoC pattern** (Business Logic Component) for predictable state management:

- **Events**: User actions that trigger state changes
- **States**: Immutable representations of UI state
- **BLoCs**: Process events and emit new states
- **Separation of concerns**: Business logic isolated from UI code
- **Easy testing**: BLoCs can be unit tested without UI dependencies

Example flow:
```
User Action → Event → BLoC → UseCase → Repository → DataSource
                ↓
            New State → UI Update
```

## Functional Error Handling

The codebase uses functional programming patterns for robust error handling:

- **FunctionalFuture**: Type alias for `Future<Either<Failure, T>>`
- **Either monad**: Left contains errors (Failure), Right contains success values
- **Explicit error handling**: All async operations return Either types
- **No exceptions thrown**: Errors represented as data

Example:
```dart
FunctionalFuture<Failure, List<HabitModel>> getHabits() async {
  try {
    final habits = _prefsHelper.getHabits();
    return Right(habits);
  } catch (e) {
    return Left(DatabaseFailure('Failed to retrieve habits: $e'));
  }
}
```

## Recent Updates

### Latest Features & Improvements

**Android Home Screen Widget (Major Update)**
- Complete redesign from complex habit tracker to intuitive 4-section navigation widget
- Changed widget size from 4x4 to compact 3x2 (180dp × 110dp)
- Added 4 clickable sections with custom icons: Todos, Food, Habits, Notes
- Implemented bidirectional deep linking between widget and app
- Added app logo and "Atomic Habits" branding to widget header
- Applied modern dark theme design (#1E1E1E background)
- Fixed widget preview display in Android widget picker

**Habits Feature Enhancements**
- Added date selection capability - users can now submit habits for any past date
- Implemented date navigation bar with previous/next day buttons
- Added calendar picker for selecting specific dates
- Implemented drag-and-drop reordering with persistent order
- Fixed widget initialization issue on app startup
- Added `order` field to HabitModel for persistent ordering

**Todos Feature Improvements**
- Implemented drag-and-drop reordering functionality
- Increased font sizes for better readability (title: 16.sp, date: 10.sp)
- Added `order` field to TodoModel for persistent ordering
- Enhanced UI consistency with Notes feature

**Food Analytics Bug Fix**
- Fixed division by zero error in analytics charts when all data is deleted
- Added minimum Y-axis values (100 for calories, 50 for macros) for better visualization
- Improved error handling for empty data states

**App Branding**
- Updated app display name from "atomic" to "Atomic" across all platforms

**Dashboard Improvements**
- Fixed HabitBloc initialization with proper dependency injection
- Enhanced integration with widget updates

## Contributing

When adding new features or modifying existing ones:

1. Follow the established clean architecture pattern
2. Create feature-specific directory structure matching existing features
3. Implement data layer first (entities, sources, repositories)
4. Define domain layer (models, abstract repositories, use cases)
5. Build presentation layer (BLoC, pages, widgets)
6. Register dependencies in the appropriate DI module
7. Run tests and linting before committing
8. Ensure code follows Dart style guidelines

---

Built with Flutter | Clean Architecture | BLoC Pattern
