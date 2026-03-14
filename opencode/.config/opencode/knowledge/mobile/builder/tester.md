# Mobile Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on mobile projects.

## Testing Frameworks

| Platform | Framework | Notes |
|----------|-----------|-------|
| iOS/Swift | XCTest | Built-in, Xcode integration |
| Android | Espresso, JUnit | Native Android testing |
| Flutter | flutter_test, integration_test | Widget and integration tests |
| Cross-platform | Detox, Appium | E2E testing |

## Testing Approaches

### Unit Tests
- **Swift**: XCTest with `@testable import`
- **Kotlin**: JUnit 4/5, Kotlin Test
- **Flutter**: flutter_test package

### Widget/Component Tests
- **iOS**: XCTest UI controls
- **Android**: Espresso for UI interactions
- **Flutter**: flutter_test WidgetTester

### Integration Tests
- **iOS**: XCUITest for app flows
- **Android**: Espresso for multi-app flows
- **Flutter**: integration_test package

### E2E Tests
- **Detox**: React Native, Flutter
- **Appium**: Cross-platform
- **XCUITest**: iOS only
- **Espresso**: Android only

## Performance Constraints
- Battery-aware testing
- Memory footprint validation
- UI thread analysis
- Launch time metrics

## Platform-Specific Considerations
- App Store review requirements
- OS version support windows
- Device fragmentation
- Certificate provisioning for tests
