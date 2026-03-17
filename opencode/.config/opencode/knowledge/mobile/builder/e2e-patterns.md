# Mobile Domain - E2E Patterns

End-to-end testing patterns for mobile applications.

## Framework Selection

| Framework | Platform | Language | Best For |
|-----------|----------|----------|----------|
| Detox | Flutter, React Native | JavaScript | Cross-platform React Native |
| Appium | All | Python/Java | Cross-platform generic |
| XCUITest | iOS | Swift | Native iOS |
| Espresso | Android | Kotlin/Java | Native Android |
| integration_test | Flutter | Dart | Flutter apps |

## Detox Pattern (Flutter/React Native)

### Setup
```yaml
# detox.config.js
module.exports = {
  apps: {
    'ios': {
      type: 'ios.app',
      build: 'xcodebuild -scheme App',
      binaryPath: 'ios/build/Build/Products/Debug-iphonesimulator/App.app'
    }
  },
  devices: {
    'ios.simulator': {
      type: 'ios.simulator',
      device: { id: 'iPhone 15' }
    }
  }
};
```

### Test Structure
```javascript
describe('Login Flow', () => {
  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should login successfully', async () => {
    await element(by.id('email')).typeText('test@example.com');
    await element(by.id('password')).typeText('password123');
    await element(by.id('login')).tap();
    await expect(element(by.id('home'))).toBeVisible();
  });
});
```

## XCUITest Pattern (iOS)

### Test Structure
```swift
class LoginUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testLoginSuccess() {
        let emailField = XCUIApplication().textFields["email"]
        emailField.tap()
        emailField.typeText("test@example.com")

        let passwordField = XCUIApplication().secureTextFields["password"]
        passwordField.tap()
        passwordField.typeText("password123")

        XCUIApplication().buttons["login"].tap()

        XCTAssertTrue(XCUIApplication().staticTexts["Home"].exists)
    }
}
```

## Espresso Pattern (Android)

### Test Structure
```kotlin
@RunWith(AndroidJUnit4::class)
class LoginActivityTest {
    @Rule
    val activityRule = ActivityTestRule(LoginActivity::class.java)

    @Test
    fun testLoginSuccess() {
        onView(withId(R.id.email)).perform(typeText("test@example.com"))
        onView(withId(R.id.password)).perform(typeText("password123"))
        onView(withId(R.id.login)).perform(click())
        onView(withId(R.id.home)).check(matches(isVisible()))
    }
}
```

## Flutter Integration Test Pattern

### Test Structure
```dart
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow', () {
    testWidgets('successful login', (WidgetTester tester) async {
      // Build app
      app.main();
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(find.byKey('email'), 'test@example.com');
      await tester.enterText(find.byKey('password'), 'password123');

      // Tap login
      await tester.tap(find.byKey('login'));
      await tester.pumpAndSettle();

      // Verify
      expect(find.byKey('home'), findsOneWidget);
    });
  });
}
```

## Best Practices

### Test Isolation
- Each test starts with clean state
- Use `beforeEach` to reset app state
- Clear user data between tests

### Locators Priority
1. Accessibility ID (best)
2. Resource ID (Android) / Accessibility Label (iOS)
3. Text
4. XPath (last resort)

### Waits
- Use explicit waits, never sleep
- `await tester.pumpAndSettle()` for Flutter
- `waitFor` for Detox

### Screenshots
- Capture on failure
- Attach to test reports
