# Embedded Domain - Planner & Architect Knowledge

Domain-specific guidance for Planner-Orchestrator and Architect working on embedded projects.

## Architecture Patterns

| Pattern | Description | Best For |
|---------|-------------|----------|
| Bare-metal | No OS, direct hardware control | Simple devices, strict timing |
| RTOS-based | Task scheduling, synchronization | Complex concurrent operations |
| Event-driven | State machine approach | User interface, protocol handling |
| Layered | HAL → Driver → Middleware → App | Maintainability |
| Component-based | Modular, reusable modules | Large codebases |

## Embedded-Specific Considerations

### Real-Time Requirements
- Hard vs soft real-time
- Interrupt latency bounds
- Task scheduling analysis
- Watchdog strategy

### Memory Constraints
- RAM budget per feature
- Stack size estimation
- Memory pool allocation
- No heap (safety-critical)

### Power Management
- Sleep modes (light/deep)
- Dynamic voltage scaling
- Wake-up source analysis
- Battery-backed operations

### Hardware Abstraction
- Portability across MCUs
- Pin multiplexing (AFIO)
- Peripheral initialization sequence
- Clock tree configuration

## Safety Architecture
- SIL rating considerations (IEC 61508)
- Fault detection and recovery
- Watchdog strategy
- Redundancy patterns
