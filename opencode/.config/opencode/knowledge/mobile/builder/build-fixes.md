# Mobile Domain - Build Fixes

Common build errors and fixes for mobile projects.

## Flutter Errors

### pub get failed

**Error:** `Running "flutter pub get"...
Could not resolve package 'xxx'`

**Fix:**
```bash
flutter clean
flutter pub get
```

### Platform Channel Missing

**Error:** `MissingPluginException(No implementation found for method xxx)`

**Fix:**
- Ensure method is registered in `MainActivity.kt` (Android)
- Ensure method is registered in `AppDelegate.swift` (iOS)
- Check plugin is added to pubspec.yaml

### iOS Simulator Not Available

**Error:** `Unable to find a destination matching the provided destination specifier`

**Fix:**
```bash
xcrun simctl list devices available
# Use available device ID
flutter run -d <device-id>
```

### CocoaPods Update Required

**Error:** `The Podfile is out of date`

**Fix:**
```bash
cd ios
pod repo update
pod install
```

## iOS/Swift Errors

### Xcode Build Failed

**Error:** `error: build input file cannot be found`

**Fix:**
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
xcodebuild clean -project Project.xcodeproj
```

### Swift Package Resolution

**Error:** `Package resolution failed`

**Fix:**
```bash
# Resolve packages
xcodebuild -resolvePackageDependencies
```

### Code Signing Error

**Error:** `No signing certificate "iOS Development" found`

**Fix:**
- Open Xcode → Preferences → Accounts
- Download manual profiles
- Or use automatic signing

## Android Errors

### Gradle Sync Failed

**Error:** `Unable to resolve dependency 'com.android.support:appcompat'`

**Fix:**
```bash
# Update gradle wrapper
./gradlew wrapper --gradle-version=8.x

# Clean and rebuild
./gradlew clean
./gradlew assembleDebug
```

### SDK Version Mismatch

**Error:** `CompileSdkVersion xxx should not be smaller than compileSdkVersion in defaultConfig`

**Fix:** Update `android/app/build.gradle`:
```groovy
android {
    compileSdkVersion xxx
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion xxx
    }
}
```

### NDK Not Found

**Error:** `SDK location not found` / `NDK not found`

**Fix:** Set in `local.properties`:
```
sdk.dir=/path/to/android/sdk
ndk.dir=/path/to/android/ndk
```

## Cross-Platform Build Fixes

### Clean Build
```bash
# Flutter
flutter clean
flutter pub get

# iOS
rm -rf ios/Pods ios/Podfile.lock
cd ios && pod install

# Android
./gradlew clean
```

### Dependency Conflicts
- Check pubspec.yaml / Podfile / build.gradle for version conflicts
- Use `flutter pub deps` to check dependency tree
- Run `pod deintegrate && pod install` for CocoaPods
