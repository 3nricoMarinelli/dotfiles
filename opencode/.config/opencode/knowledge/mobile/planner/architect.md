# Mobile Domain - Planner & Architect Knowledge

Domain-specific guidance for Planner-Orchestrator and Architect working on mobile projects.

## Architecture Patterns

| Pattern | Description | Best For |
|---------|-------------|----------|
| MVVM | Model-View-ViewModel | UI-heavy apps |
| Clean Architecture | Domain/Data/Presentation layers | Complex business logic |
| MVP | Model-View-Presenter | Testable UI |
| Redux-like | Unidirectional state | Complex state management |
| Repository | Data source abstraction | Multiple data sources |

## Mobile-Specific Considerations

### Offline-First Design
- Local database (SQLite, Realm, CoreData)
- Sync strategies (eventual consistency)
- Conflict resolution
- Background sync

### Responsive UI
- Multiple screen sizes
- Landscape/portrait handling
- Accessibility (VoiceOver, TalkBack)
- Dark mode support

### State Management
- Local UI state (setState, useState)
- App state (Provider, Riverpod, Bloc, GetX)
- Persisted state (UserDefaults, SharedPreferences)
- Network state (online/offline)

## Performance Architecture
- Lazy loading
- Image caching
- Pagination
- Background processing
- Memory management

## Security Architecture
- Data encryption at rest
- Secure communication (TLS)
- Certificate pinning
- Biometric authentication
- Jailbreak/root detection
