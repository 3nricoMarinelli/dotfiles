# Robotics Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on robotics projects.

## Profiling Tools

| Tool | Metrics |
|------|---------|
| ros2 profiling | CPU/memory |
| perf | System-wide profiling |
| GPro | ROS2 graph analysis |
| rqt_plot | Real-time data |
| Time profiler | Execution time |

## Performance Targets

| Metric | Target | Notes |
|--------|--------|-------|
| Control loop | 10-100Hz | Task-dependent |
| Sensor processing | < 50ms | Latency-critical |
| Motion planning | < 1s | Obstacle avoidance |
| Image processing | < 100ms | 10fps minimum |

## Optimization Areas
- Message filtering (throttle)
- Nodelet optimization
- Zero-copy transfers
- Component composition
- Intra-process communication
- Message compression
