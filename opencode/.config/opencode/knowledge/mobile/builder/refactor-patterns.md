# Mobile Domain - Refactor Patterns

Refactoring patterns specific to mobile applications.

## Flutter Refactoring

### Extract Widget
```dart
// Before: Large build method
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      // 50+ lines of widget tree
    ],
  );
}

// After: Extracted widgets
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      _buildHeader(),
      _buildContent(),
      _buildFooter(),
    ],
  );
}

Widget _buildHeader() { ... }
Widget _buildContent() { ... }
Widget _buildFooter() { ... }
```

### Provider/Bloc Extraction
```dart
// Before: Business logic in widget
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = context.watch<MyModel>(); // Too much logic
    // ...
  }
}

// After: Separate state management
class MyBloc extends Bloc<MyEvent, MyState> { ... }

// Widget just renders
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBloc, MyState>(
      builder: (context, state) => // Render only
    );
  }
}
```

## Swift Refactoring

### Extract Method
```swift
// Before: Long function
func processUserData() {
    // 100+ lines
}

// After: Separated concerns
func processUserData() {
    validateInput()
    transformData()
    saveToDatabase()
}
```

### Protocol-Oriented Design
```swift
// Before: Concrete dependency
class UserService {
    let apiClient = APIClient()
}

// After: Protocol injection
protocol APIClientProtocol {
    func request<T: Decodable>(endpoint: String) async throws -> T
}

class UserService {
    let apiClient: APIClientProtocol
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
}
```

## Android Refactoring

### Extract Function (Kotlin)
```kotlin
// Before: Long function
fun processData() {
    // 50+ lines
}

// After: Reusable functions
private fun processData() {
    validateInput()
    transformData()
    persistData()
}
```

### RecyclerView ViewHolder Pattern
```kotlin
// Before: Bloated adapter
class MyAdapter : RecyclerView.Adapter<MyAdapter.ViewHolder>() {
    // 200+ lines
}

// After: Separated ViewHolder
class MyAdapter(
    private val items: List<Item>,
    private val listener: (Item) -> Unit
) : RecyclerView.Adapter<MyAdapter.ViewHolder>() {
    // Clean implementation
}
```

## Dead Code Patterns (Mobile)

### Unused Assets
```yaml
# Check pubspec.yaml
# flutter:
#   assets:
#     - assets/unused_image.png  # Remove unused assets
```

### Unused Translations
- Remove unused keys from ARB files
- Use `flutter gen-l10n` to verify

### Deprecated APIs
- Replace deprecated Flutter widgets
- Update deprecated Swift/Objective-C methods

## Code Smells (Mobile)

### Flag Arguments
```dart
// Bad
void loadData(bool isCached) { ... }

// Good
void loadCachedData() { ... }
void loadFreshData() { ... }
```

### God Widget
- Break widgets > 200 lines
- Extract to smaller composable widgets

### Context Passing
```dart
// Bad: Passing context deep
Widget build(BuildContext context) {
  return DeepWidget(context: context, data: data);
}

// Good: Using InheritedWidget/Provider
Widget build(BuildContext context) {
  final data = context.watch<Data>();
  return DeepWidget(data: data);
}
```

## Performance Refactoring

### Build Cache
- Enable incremental compilation
- Use `flutter pub get` after code changes

### Image Optimization
- Use WebP format
- Lazy load images
- Cache decoded images
