# Mobile Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on mobile projects.

## Debugging Tools

| Platform | Tool | Purpose |
|----------|------|---------|
| iOS | Xcode Debugger (lldb) | UI debugging, memory graph |
| iOS | Instruments | Performance, leaks, time profiler |
| Android | Android Studio Debugger | Java/Kotlin debugging |
| Android | Android Profiler | CPU, memory, network, battery |
| Flutter | Dart DevTools | Widget inspector, timeline |
| Cross-platform | Flipper | React Native debugging |

## Debugging Approaches

### Crash Analysis
- iOS: Crashlytics, Xcode Organizer
- Android: Firebase Crashlytics, Play Console
- Flutter: Crashlytics, Sentry

### Memory Debugging
- iOS: Memory Graph, Instruments Leaks
- Android: Android Profiler Memory
- Flutter: Dart DevTools memory view

### Network Debugging
- iOS: Charles Proxy, Network Link Conditioner
- Android: Charles Proxy, Stetho
- Flutter: Flipper network plugin

## Platform-Specific Debugging
- App Store review guidelines compliance
- Push notification debugging
- Background execution issues
- Deep link handling
- Security (certificate pinning, biometrics)
