# Embedded Domain - E2E Patterns

End-to-end testing patterns for embedded systems.

## Testing Approaches

### 1. Hardware-in-the-Loop (HIL)
Real hardware with test harness controlling inputs/outputs

### 2. Software-in-the-Loop (SIL)
Full software simulation without hardware

### 3. Processor-in-the-Loop (PIL)
Code running on target processor, simulated peripherals

## C++ E2E Test Framework

### Google Test + Custom Harness

```cpp
// test_harness.h
class EmbeddedTestHarness {
public:
    void setInput(uint8_t pin, bool value);
    bool getOutput(uint8_t pin);
    void tick(uint32_t ms);
    void reset();
};
```

### Unity Test Framework (Embedded)

```c
// For STM32/Arduino
#include "unity.h"

void setUp(void) {
    hardware_reset();
}

void tearDown(void) {
}

void test_led_toggles(void) {
    LED_on();
    TEST_ASSERT_TRUE(LED_read());
    LED_off();
    TEST_ASSERT_FALSE(LED_read());
}
```

## Rust E2E Test Pattern

### Integration Tests

```rust
// tests/integration_test.rs
use embedded_hal::digital::v2::OutputPin;

#[test]
fn test_led_blink() {
    let led = // initialize LED pin;
    for _ in 0..5 {
        led.set_high().unwrap();
        delay_ms(100);
        led.set_low().unwrap();
        delay_ms(100);
    }
}
```

## Test Fixtures for Embedded

### Mock Peripherals

```cpp
class MockUART {
    std::queue<uint8_t> rx_queue;
    std::vector<uint8_t> tx_buffer;
    
public:
    void write(uint8_t data) { tx_buffer.push_back(data); }
    bool readable() { return !rx_queue.empty(); }
    uint8_t read() { auto v = rx_queue.front(); rx_queue.pop(); return v; }
};
```

### Fake ADC

```cpp
class FakeADC {
    std::vector<uint16_t> readings;
    size_t index = 0;
    
public:
    void setReadings(std::vector<uint16_t> vals) {
        readings = vals;
        index = 0;
    }
    
    uint16_t read() {
        return readings[index++ % readings.size()];
    }
};
```

## ROS2 Integration (If Applicable)

### Launch Testing

```python
# test_node.py
import unittest
from launch_testing import LaunchTestService
from my_package import MyNode

class TestMyNode(unittest.TestCase):
    def test_node_publishes(self):
        # Test node publishes correctly
        pass
```

## Test Execution

### CMake/CTest

```cmake
enable_testing()
add_test(NAME LedTest COMMAND LedTest)

# Run
ctest --output-on-failure
```

### Cargo

```bash
# Unit tests
cargo test

# Integration tests
cargo test --test integration_test

# With coverage
cargo tarpaulin test
```

## Best Practices

### Test Isolation
- Each test resets hardware state
- Use dependency injection for peripherals

### Deterministic Tests
- No random values in tests
- Mock random number generators
- Use deterministic timing

### Real-Time Considerations
- Set appropriate timeouts
- Don't test timing in CI (use dedicated hardware)

### Memory Safety
- Check for memory leaks
- Use static analysis tools
- Verify no buffer overflows
