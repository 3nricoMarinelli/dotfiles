# Backend Domain - Planner & Architect Knowledge

Domain-specific guidance for Planner-Orchestrator and Architect working on backend projects.

## Architecture Patterns

| Pattern | Description | Best For |
|---------|-------------|----------|
| Monolith | Single deployable | Small teams, startups |
| Microservices | Distributed services | Large scale, teams |
| Serverless | Function-as-a-Service | Event-driven, scale |
| Event-driven | Async messaging | Loose coupling |
| Hexagonal | Ports and adapters | Testability |

## Architecture Considerations

### Microservices
- Service boundaries
- API gateway pattern
- Service mesh
- Distributed tracing
- Circuit breakers

### Data Architecture
- Database per service
- CQRS pattern
- Event sourcing
- Read replicas
- Caching layers

### Scalability
- Horizontal vs vertical
- Auto-scaling
- Load balancing
- Stateless design
- Session management

### Reliability
- Circuit breakers
- Retry policies
- Bulkheads
- Dead letter queues
- Graceful degradation
