# Embedded Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on embedded projects.

## Debugging Tools

| Tool | Purpose |
|------|---------|
| GDB | Command-line debugger |
| LLDB | LLVM debugger |
| OpenOCD | JTAG/SWD debug probe interface |
| J-Link | SEGGER debug probes |
| ST-Link | STM32 debugging |
| Segger RTT | Real-time terminal output |
| Ozzone | Percepio trace visualization |

## Debugging Approaches

### Hardware Debugging
- JTAG/SWD interfaces
- Breakpoints (hardware, software)
- Watchpoints for memory changes
- Register inspection

### Trace Debugging
- ARM ETM/ITM instruction tracing
- RTOS kernel tracing
- Event tracing
- Performance profiling

### Serial Debugging
- UART/USB CDC debug output
- SEGGER RTT
- SWO (Serial Wire Output)

## Common Embedded Issues
- Stack overflow
- Memory corruption
- Race conditions in ISRs
- Watchdog resets
- Hard faults (ARM Cortex-M)
- Missing volatile keyword
