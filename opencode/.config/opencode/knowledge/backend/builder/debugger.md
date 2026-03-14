# Backend Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on backend projects.

## Debugging Tools

| Tool | Purpose |
|------|---------|
| Delve | Go debugger |
| pdb | Python debugger |
| lldb | Rust/C++ debugging |
| IDE debuggers | IntelliJ, VSCode |
| postman/curl | API testing |

## Debugging Approaches

### Logging
- Structured logging (JSON)
- Log levels (debug, info, warn, error)
- Request tracing (correlation IDs)
- Distributed tracing (Jaeger, Zipkin)

### Profiling
- pprof (Go)
- cProfile (Python)
- async-profiler (Java)
- APM tools (Datadog, New Relic)

### Common Issues
- Race conditions
- Memory leaks
- Connection pool exhaustion
- Deadlocks
- Timeout handling
- Resource cleanup
