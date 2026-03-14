# Mobile Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on mobile projects.

## Profiling Tools

| Platform | Tool | Metrics |
|----------|------|---------|
| iOS | Instruments | CPU, Memory, Energy, Time Profiler |
| iOS | Xcode Organizer | Launch time, memory, crashes |
| Android | Android Profiler | CPU, Memory, Network, GPU |
| Android | perfetto | System-wide tracing |
| Flutter | Dart DevTools | CPU, Memory, Timeline |
| Flutter | flutter analyze | Performance hints |

## Performance Targets

| Metric | Target | Notes |
|--------|--------|-------|
| Cold launch | < 2s | Time to interactive |
| Hot launch | < 500ms | App already in memory |
| Frame rate | 60fps | Smooth scrolling |
| Memory | < 150MB | iOS memory limit awareness |
| Battery | Minimal background usage | Energy impact |

## Optimization Areas
- UI thread blocking prevention
- Lazy loading and pagination
- Image caching and compression
- List virtualization (long lists)
- Memory leak detection
- APK/IPA size optimization
