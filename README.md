# Bookshelf

A complete Flutter implementation for the Porcupine Junior Flutter assessment.

## Included

- Responsive Material 3 library UI
- Featured books and searchable catalog
- Category filtering
- Saved/bookmarked books
- Book detail reader screen
- Adjustable reading text size
- Light/dark theme toggle
- Empty states and accessible tooltips
- No network or credentials required; data is local and deterministic

## Run

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

The repository intentionally keeps the first version dependency-light: it uses Flutter's SDK only, so it can be built offline after the Flutter SDK cache is available.
