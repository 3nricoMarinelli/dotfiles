# Embedded Domain - Refactor Patterns

Refactoring patterns specific to embedded C++/Rust projects.

## C++ Patterns

### Extract Function

```cpp
// Before: Monolithic function
void processSensor() {
    // Read sensor
    uint16_t raw = readADC(0);
    // Filter
    float filtered = lowPassFilter(raw);
    // Scale
    float value = filtered * 3.3f / 4096.0f;
    // Output
    sendUART(value);
}

// After: Clear separation
void processSensor() {
    uint16_t raw = readRawValue();
    float filtered = applyFilter(raw);
    float scaled = scaleToVoltage(filtered);
    outputResult(scaled);
}
```

### Replace Magic Numbers

```cpp
// Before
if (value > 4095) { // What is 4095?

}

// After
static constexpr uint16_t ADC_MAX = 0xFFF;
if (value > ADC_MAX) { }
```

### RAII for Resources

```cpp
// Before: Manual resource management
void process() {
    enableClock();
    // ... lots of code
    disableClock(); // Easy to forget
}

// After: RAII
class ClockGuard {
public:
    ~ClockGuard() { disableClock(); }
};
// Usage:
ClockGuard guard;
```

### Policy-Based Design

```cpp
// Before: Conditional compilation
#ifdef USE_DMA
    transferDMA();
#else
    transferPolling();
#endif

// After: Policy template
template<typename TransferPolicy>
class Sensor : public TransferPolicy {
    void read() { 
        // Use policy
        TransferPolicy::transfer(buffer, size);
    }
};
```

## Rust Patterns

### Extract Function

```rust
// Before: Long function
fn process_data() {
    // Read
    let raw = read_sensor();
    // Filter
    let filtered = low_pass_filter(raw);
    // Transform
    let value = filtered * SCALE;
    // Output
    send(value);
}

// After: Clear separation
fn process_data() {
    let raw = read_raw();
    let filtered = apply_filter(raw);
    let scaled = scale_value(filtered);
    output(scaled);
}
```

### Error Handling

```rust
// Before: Unwrap everywhere
fn read() -> u16 {
    let mut buf = [0u8; 2];
    i2c.read(&mut buf).unwrap(); // Panics on error
}

// After: Proper error handling
fn read() -> Result<u16, Error> {
    let mut buf = [0u8; 2];
    i2c.read(&mut buf)?;
    Ok(u16::from_le_bytes(buf))
}
```

### Trait Bounds

```rust
// Before: Concrete types
fn process<T: Read>(reader: &mut T) { }

// After: Trait bounds for testability
fn process<R: Read + Write>(io: &mut R) { }
```

## Dead Code Patterns (Embedded)

### Unused ISRs
```cpp
// Remove unused interrupt handlers
// void USART1_IRQHandler(void) { } // DELETE if not used
```

### Unused Configuration
```cpp
// Remove unused #defines
// #define UNUSED_PIN 42 // DELETE
```

### Dead Code in #ifdef
```cpp
#ifdef LEGACY_SUPPORT
    // Old code not compiled
#endif // Remove if LEGACY_SUPPORT never defined
```

## Code Smells (Embedded)

### Global State
```cpp
// Bad: Global variables
uint16_t global_adc_value;

// Good: Passed context
void processADC(ADCContext& ctx);
```

### Magic Numbers
```cpp
// Bad
if (value > 4095)

// Good
static constexpr uint16_t ADC_MAX_VALUE = 4095;
if (value > ADC_MAX_VALUE)
```

### Interrupt-Safe Code
```cpp
// Bad: Complex operations in ISR
void TIM2_IRQHandler() {
    // Don't do this in ISR
    std::string s = formatData();
    uart.send(s);
}

// Good: Simple flag setting
volatile bool data_ready = false;
void TIM2_IRQHandler() {
    data_ready = true;
}
```

### Heap Allocation in Critical Code
```cpp
// Bad: Dynamic allocation
auto* data = new uint8_t[100];

// Good: Static buffer
uint8_t data[100];
```

## Performance Refactoring

### Use constexpr
```cpp
// Before: Runtime calculation
float pi = 3.14159f;

// After: Compile-time
constexpr float PI = 3.14159f;
```

### Inline Hot Paths
```cpp
// Force inline for small, called frequently
inline uint32_t getBit(uint32_t val, int bit) {
    return (val >> bit) & 1;
}
```
