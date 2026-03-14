# Embedded Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on embedded projects.

## Testing Frameworks

| Language | Framework | Notes |
|----------|-----------|-------|
| C | Unity, Check, CMocka | Lightweight unit testing |
| C++ | Google Test, Catch2 | Full-featured testing |
| Rust | built-in #[test], proptest | Property-based testing |
| MicroPython | pytest, unittest | Python on microcontrollers |

## Testing Approaches

### Unit Tests
- Host-based testing (x86/x64)
- Cross-compilation for target
- Mocking hardware peripherals

### Integration Tests
- Hardware-in-the-loop (HIL)
- Simulator-based testing
- Peripheral emulation

### Real-Time Testing
- Timing constraint verification
- Interrupt latency measurement
- Deadline miss detection

## Testing Constraints
- Memory limitations (RAM/ROM)
- No dynamic allocation in tests
- Deterministic execution
- Bare-metal vs RTOS considerations
