# Contributing to NoteKar Android

Thank you for your interest in contributing to NoteKar Android! NoteKar Android is a native Flutter application built with an **offline-first and privacy-focused** architecture.

---

## 📜 Code of Conduct

Please review and follow our **[Code of Conduct](CODE_OF_CONDUCT.md)** in all repository interactions.

---

## 🛠️ Local Development Setup

1. **Prerequisites:**
   - Flutter SDK (`^3.12.0` or higher) installed and configured in system PATH.
   - Android Studio with Android SDK (API 21+).
2. **Fork & Clone:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/Notekar-Android.git
   cd Notekar-Android
   ```
3. **Install Dependencies:**
   ```bash
   flutter pub get
   ```
4. **Run the App:**
   ```bash
   flutter run
   ```

---

## 🚀 How to Contribute

### 1. Code Analysis & Formatting
Before committing changes, ensure your code passes static analysis and formatting:
```bash
flutter analyze
flutter format .
```

### 2. Translating the App
Want to add or improve a language translation? Check out our dedicated **[Translation Guide (TRANSLATIONS.md)](TRANSLATIONS.md)** for a 3-step walkthrough on working with `.arb` localization files.

### 3. Submitting Pull Requests
1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. Test thoroughly on an Android device or emulator.
3. Commit with clear, descriptive messages:
   ```bash
   git commit -m "feat(hive): add custom export options"
   ```
4. Push to your branch and submit a Pull Request.

> [!WARNING]
> **Do NOT commit signing credentials or keystores (`key.properties`, `*.jks`).** Verify `.gitignore` rules before pushing.

---

## ☕ Questions & Support

Reach out via [Email](mailto:yabp.support@gmail.com) or submit issues on GitHub.
