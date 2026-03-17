# Mobile Domain - TDD Workflow

Domain-specific guidance for TDD Guide agent working on mobile projects.

## Testing Frameworks by Platform

### Flutter

| Test Type | Framework | Location | Command |
|-----------|-----------|----------|---------|
| Unit | flutter_test | `test/unit/` | `flutter test test/unit/` |
| Widget | flutter_test | `test/widget/` | `flutter test test/widget/` |
| Integration | integration_test | `integration_test/` | `flutter test integration_test/` |

### iOS/Swift

| Test Type | Framework | Location | Command |
|-----------|-----------|----------|---------|
| Unit | XCTest | `ProjectTests/` | `xcodebuild test` |
| UI | XCUITest | `ProjectUITests/` | `xcodebuild test -scheme ProjectUITests` |

### Android

| Test Type | Framework | Location | Command |
|-----------|-----------|----------|---------|
| Unit | JUnit 4/5 | `app/src/test/` | `./gradlew testDebugUnitTest` |
| Instrumented | Espresso | `app/src/androidTest/` | `./gradlew connectedAndroidTest` |

## Flutter TDD Pattern

```dart
// 1. RED - Write failing test
test('calculator adds two numbers', () {
  final calculator = Calculator();
  expect(calculator.add(2, 3), 5); // This fails
});

// 2. GREEN - Minimal implementation
class Calculator {
  int add(int a, int b) => 5; // Minimal fix
}

// 3. REFACTOR - Proper implementation
class Calculator {
  int add(int a, int b) => a + b;
}
```

## Swift TDD Pattern

```swift
// 1. RED - Write failing test
func testCalculatorAddsTwoNumbers() {
    let calculator = Calculator()
    XCTAssertEqual(calculator.add(2, 3), 5)
}

// 2. GREEN - Minimal implementation
class Calculator {
    func add(_ a: Int, _ b: Int) -> Int { 5 }
}

// 3. REFACTOR - Proper implementation
class Calculator {
    func add(_ a: Int, _ b: Int) -> Int { a + b }
}
```

## Mobile-Specific Considerations

### State Management
- Test state changes in BLoC/Provider/Redux
- Mock dependencies (repositories, services)
- Test widget rebuilds with `tester.pump()`

### Platform Channels
- Mock platform channel responses
- Test both success and error paths

### Navigation
- Test navigation flows
- Mock navigation callbacks

### Performance Constraints
- Tests must complete in <100ms
- Use fake implementations for heavy dependencies

## Coverage Requirements

| Test Type | Minimum Coverage |
|-----------|-----------------|
| Unit | 80% |
| Widget | 60% |
| Integration | 100% critical flows |
