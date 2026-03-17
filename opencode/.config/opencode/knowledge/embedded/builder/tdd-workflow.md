# Embedded Domain - TDD Workflow

Domain-specific guidance for TDD Guide agent working on embedded/C++/Rust projects.

## Testing Frameworks by Language

### C++

| Test Framework | Header-only | CMake Integration | Best For |
|----------------|-------------|------------------|----------|
| Google Test | No | Excellent | Large projects |
| Catch2 | Yes | Good | Header-only projects |
| doctest | Yes | Good | Minimal overhead |
| Unity | Yes | Manual | Embedded/STM32 |

### Rust

| Test Type | Framework | Location | Command |
|-----------|-----------|----------|---------|
| Unit | built-in #[test] | Same file or `tests/` | cargo test |
| Integration | built-in | `tests/*.rs` | cargo test |
| Doc | built-in | In doc comments | cargo test --doc |

## C++ TDD Pattern (Google Test)

```cpp
// 1. RED - Write failing test
#include <gtest/gtest.h>

TEST(MathUtilsTest, AddTwoNumbers) {
    EXPECT_EQ(add(2, 3), 5); // This fails
}

// 2. GREEN - Minimal implementation
int add(int a, int b) {
    return 5; // Minimal fix
}

// 3. REFACTOR - Proper implementation
int add(int a, int b) {
    return a + b;
}
```

## C++ TDD Pattern (Catch2)

```cpp
#define CATCH_CONFIG_MAIN
#include <catch2/catch.hpp>

TEST_CASE("Add two numbers", "[math]") {
    REQUIRE(add(2, 3) == 5);
}
```

## Rust TDD Pattern

```rust
// 1. RED - Write failing test
#[cfg(test)]
mod tests {
    #[test]
    fn test_add_two_numbers() {
        assert_eq!(add(2, 3), 5); // This fails
    }
}

// 2. GREEN - Minimal implementation
fn add(a: i32, b: i32) -> i32 {
    5 // Minimal fix
}

// 3. REFACTOR - Proper implementation
fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

## Embedded-Specific Considerations

### Hardware Abstraction
- Mock hardware registers in tests
- Use dependency injection for peripheral access
- Test business logic without hardware

### Interrupt Handling
- Test ISRs with mocked interrupt controllers
- Verify interrupt enable/disable sequences

### Memory Constraints
- Test memory allocation patterns
- Verify no heap allocations in ISR context

### Real-Time Constraints
- Measure worst-case execution time
- Test timing-critical sections

### Cross-Compilation
```bash
# Rust embedded testing
cargo test --target thumbv7em-none-eabihf

# C++ with QEMU (no hardware)
qemu-arm ./test_executable
```

## Coverage Requirements

| Test Type | Minimum Coverage |
|-----------|------------------|
| Unit | 80% |
| Integration | 70% |
| Critical paths | 100% |

## Embedded Test Patterns

### Mocking Hardware
```cpp
// Mock GPIO peripheral
class MockGPIO {
public:
    static MockGPIO* instance;
    bool write_called = false;
    
    static void write(uint32_t pin, uint32_t value) {
        instance->write_called = true;
    }
};
```

### Fake Timers
```cpp
class FakeTimer {
    uint32_t current_time = 0;
public:
    void advance(uint32_t ms) { current_time += ms; }
    uint32_t now() { return current_time; }
};
```
