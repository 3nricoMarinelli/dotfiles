# Robotics Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on robotics projects.

## Testing Frameworks

| Framework | Purpose |
|-----------|---------|
| launch_testing | ROS2 integration testing |
| rostest | ROS1 test runner |
| gtest | C++ unit tests |
| pytest | Python node tests |
| Rocker | Docker-based testing |
| Gazebo | Simulation testing |

## Testing Approaches

### Unit Tests
- C++: gtest, Catch2
- Python: pytest, unittest
- Hardware abstraction mocking

### Integration Tests
- ROS node interaction testing
- Topic/service communication
- Parameter loading
- Launch file testing

### Simulation Testing
- Gazebo simulation
- Stage simulator
- Physics validation
- Sensor/actuator models

### Hardware-in-the-Loop
- Real hardware integration
- Driver testing
- Timing validation
- Sensor calibration

## ROS-Specific Testing
- Message type validation
- Topic/message compatibility
- Service call testing
- Action server testing
- Parameter server testing
