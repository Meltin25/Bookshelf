# Bookshelf

A polished Flutter bookshelf app built for the Porcupine Junior Flutter assessment. The project demonstrates a clean Material 3 interface, lightweight state management, local demo data, and a reading experience with adjustable text sizing and theme toggling.

## Overview

Bookshelf is an offline-friendly reading app that lets users:

- browse a curated library of books
- search by title, author, or topic
- filter by category
- save favorites to a dedicated Saved section
- open each book in a reader view
- adjust reading text size
- switch between light and dark themes

The app intentionally avoids network dependencies and credentials. It uses deterministic local data so it can run consistently without an API or login flow.

## Features

- Responsive Material 3 library UI
- Featured books carousel
- Searchable, filterable catalog
- Saved/bookmarked books section
- Book detail and reading experience
- Adjustable text size in the reader
- Light/dark theme toggle
- Empty-state handling for no result and no saved books
- Accessible tooltips and touch-friendly controls

## Screens and UX

The app is organized around a simple browsing flow:

1. Library view: search, category chips, featured titles, and grid of book cards
2. Saved view: quick access to bookmarked items
3. Reader page: read a sample chapter excerpt with text scaling controls and save toggling

## Tech stack

- Flutter
- Dart
- Material 3
- Flutter test for widget validation

## Project structure

```text
Bookshelf/
├── lib/
│   └── main.dart        # App UI, state, data model, and demo content
├── test/
│   └── widget_test.dart  # Basic widget-level validation
├── README.md
├── pubspec.yaml
├── Bookshelf.code-workspace
└── .gitignore
```

## Getting started

### Prerequisites

- Flutter SDK 3.3.0 or newer
- A supported IDE such as VS Code or Android Studio

### Install and run

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

If you are working from a fresh environment, make sure the Flutter SDK is installed and available on your PATH before running the commands above.

## Notes

- The repository intentionally keeps dependencies minimal and relies on Flutter's SDK only.
- Demo data is embedded directly in the app, making the project easy to run offline.
- The app is designed as a lightweight assessment implementation rather than a backend-driven production app.

## Validation

The project includes a widget test to confirm the app loads and renders core UI elements.

```bash
flutter test
```

## License

This project is provided as a sample Flutter implementation for assessment purposes. Check the repository settings for licensing details if you plan to reuse or redistribute the code.
