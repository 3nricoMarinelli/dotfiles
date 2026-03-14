# Mobile Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on mobile projects.

## Migration Paths

| From | To | Considerations |
|------|-----|----------------|
| UIWebView | WKWebView | API differences, JS execution |
| Objective-C | Swift | Interop, bridging headers |
| Java | Kotlin | Null safety, coroutines |
| Cordova | Flutter/React Native | Performance, native features |
| Native | Flutter | Shared UI, platform widgets |

## Dependency Upgrades
- **iOS**: Pod update, Xcode migration
- **Android**: Gradle update, SDK version bumps
- **Flutter**: pub upgrade, Dart version

## Platform Porting
- iOS → Android (or vice versa): Flutter for shared codebase
- React Native → Flutter: Rewriting UI layer

## Breaking Changes
- App Store review guideline updates
- Android SDK deprecations
- iOS privacy manifest requirements
- Minimum OS version support
