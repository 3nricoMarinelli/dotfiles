# Backend Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on backend projects.

## Testing Frameworks

| Language | Framework | Notes |
|----------|-----------|-------|
| Go | built-in testing | Table-driven tests |
| Python | pytest | Fixtures, parametrize |
| Java | JUnit, TestNG | Spring testing |
| Node.js | Jest, Vitest | Mocking, snapshots |

## Testing Approaches

### Unit Tests
- Pure function testing
- Mock external dependencies
- Database mocking (testcontainers)
- HTTP mocking (WireMock)

### Integration Tests
- API endpoint testing
- Database integration
- Message queue testing
- Service-to-service

### E2E Tests
- Full flow testing
- Contract testing
- Performance testing
- Chaos engineering

## Backend Testing Patterns
- Test database per suite
- Fixture management
- HTTP client testing
- Async testing patterns
