# Workflow 08: Release-Readiness Verification

> **Command**: `/release-ready`  
> **Objective**: Execute the comprehensive pre-flight release gauntlet, verify version increments, changelog formatting, multi-ABI build compilation, and release artifact signing.

---

## 1. Preconditions
- Clean Git working tree on a release or release-staging branch (`release`, `beta`, or `main`).
- Android release keystore available (`android/key.properties`).
- Full automated test suite passes 100%.

---

## 2. Release Gauntlet Steps

### Step 1: Version & Metadata Synchronization
1. Inspect `pubspec.yaml` version line:
   ```yaml
   version: X.Y.Z+BUILDNUMBER
   ```
2. Verify synchronization across:
   - `android/local.properties` (`flutter.versionName`, `flutter.versionCode`).
   - `lib/utils/app_utils.dart` (`kAppVersion`, `kAppBuildNumber`).
   - `CHANGELOG.md` (top section updated with date, version, and release highlights).
   - `fastlane/metadata/android/en-US/changelogs/<BUILDNUMBER>.txt`.
   - `versions/vX.Y.Z/version.json`.
3. Alternatively, utilize the automated version script:
   ```powershell
   .\scripts\update-version.ps1 -stable   # For stable release
   # OR: .\scripts\update-version.ps1 -beta    # For beta release
   # OR: .\scripts\update-version.ps1 -security # For security update
   ```

### Step 2: Quality Gates Pre-Check
Run complete code verification:
```powershell
.\scripts\verify.ps1
```
- Code formatting clean.
- Static analysis clean (`flutter analyze --fatal-infos --fatal-warnings`).
- Full test suite passing (`flutter test`).

### Step 3: Multi-ABI Signed Release Build
Execute the multi-ABI release compilation script:
```powershell
.\scripts\build-release-apks.ps1
```
This produces:
- `app-arm64-v8a-release.apk` (modern 64-bit devices).
- `app-armeabi-v7a-release.apk` (legacy 32-bit devices).
- `app-x86_64-release.apk` (emulators & Chromebooks).
- `app-universal-release.apk` (universal bundle).

### Step 4: Checksum & Integrity Generation
Verify SHA-256 checksums are generated for each release APK in `releases/`:
```powershell
Get-FileHash releases/*.apk -Algorithm SHA256
```

### Step 5: Android Version Compatibility & Proguard Verification
1. Inspect `android/app/proguard-rules.pro`. Ensure keep-rules exist for Isar, Hive, and platform channel models.
2. Verify APK builds without obfuscation crashes:
   - Inspect build log for any Proguard / R8 missing classes or resource shrinker warnings.

---

## 3. Safeguards & Abort Conditions
- NEVER publish or push release artifacts if any test failed.
- NEVER push to `release` or `security` without verifying `key.properties` is configured correctly.
- Ensure `key.properties` and `.jks` keystores are in `.gitignore` and NEVER committed to Git.

---

## 4. Completion Criteria
- Signed release APKs generated in `releases/`.
- SHA-256 checksums recorded.
- Release notes formatted in `CHANGELOG.md` and Fastlane changelog.
- Git tag ready to be created (e.g. `vX.Y.Z`).
