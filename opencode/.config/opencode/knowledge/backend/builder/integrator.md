# Backend Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on backend projects.

## Integration Types

| Integration | Protocol | Notes |
|-------------|----------|-------|
| REST APIs | HTTP/JSON | Standard web APIs |
| gRPC | Protocol Buffers | High-performance RPC |
| GraphQL | Query language | Flexible queries |
| Message Queues | AMQP, Kafka, Redis | Async communication |
| Databases | SQL, NoSQL | Persistent storage |
| Caches | Redis, Memcached | Performance |

## API Integration

### REST
- OpenAPI/Swagger documentation
- Rate limiting
- Authentication (OAuth, JWT, API keys)
- Versioning strategies

### gRPC
- Protocol Buffers definition
- Streaming support
- Code generation
- Interceptors

### GraphQL
- Schema definition
- Resolver composition
- N+1 query prevention
- Subscription support

## Cloud Services
- AWS SDK, GCP SDK, Azure SDK
- Serverless functions
- Container orchestration
