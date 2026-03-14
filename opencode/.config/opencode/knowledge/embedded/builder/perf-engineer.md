# Embedded Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on embedded projects.

## Profiling Tools

| Tool | Metrics |
|------|---------|
| perf | CPU sampling on Linux hosts |
| SEGGER SystemView | RTOS event visualization |
| Ozone / J-Link | Instruction trace, timeline |
| OpenOCD + GDB | Breakpoint profiling |
| Arm DS-5 | Streamline performance analyzer |
| Valgrind (host) | Memory analysis in simulation |

## Performance Targets

| Metric | Target | Notes |
|--------|--------|-------|
| Interrupt latency | < 10μs | Hard real-time |
| Task context switch | < 5μs | RTOS overhead |
| Memory usage | < 50% RAM | Headroom for stack |
| Code size | Fit in ROM | Optimization tradeoffs |
| Power consumption | Target uA/mA | Battery-powered devices |

## Optimization Areas
- ISR optimization (minimal work)
- DMA for data transfers
- Sleep mode utilization
- Clock frequency optimization
- Code size vs speed tradeoff
- Memory allocation strategies
