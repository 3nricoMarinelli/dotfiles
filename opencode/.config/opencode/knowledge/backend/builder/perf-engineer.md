# Backend Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on backend projects.

## Profiling Tools

| Language | Tool |
|----------|------|
| Go | pprof, trace |
| Python | cProfile, py-spy |
| Java | async-profiler, JMC |
| Node.js | 0x, clinic.js |

## Performance Targets

| Metric | Target | Notes |
|--------|--------|-------|
| P99 latency | < 200ms | API response |
| Throughput | Context-dependent | Requests/sec |
| CPU usage | < 70% | Sustained load |
| Memory | Stable baseline | No leaks |

## Optimization Areas
- Database query optimization
- Caching strategies
- Connection pooling
- Async I/O
- Load balancing
- Horizontal scaling
