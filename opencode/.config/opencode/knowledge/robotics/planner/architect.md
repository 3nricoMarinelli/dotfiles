# Robotics Domain - Planner & Architect Knowledge

Domain-specific guidance for Planner-Orchestrator and Architect working on robotics projects.

## Architecture Patterns

| Pattern | Description | Best For |
|---------|-------------|----------|
| Component-based | ROS2 composition | Modular systems |
| Lifecycle nodes | Managed state | Production robots |
| Nodelet | Zero-copy IPC | Performance-critical |
| Action server | Long-running tasks | Navigation, manipulation |
| Behavior tree | Complex missions | Autonomy |

## ROS-Specific Considerations

### Node Design
- Single Responsibility Principle
- Parameter handling
- Lifecycle management
- State machines

### Communication
- Topic design (frequency, bandwidth)
- Service vs action selection
- Message design
- QoS configurations

### Navigation Stack
- SLAM (localization + mapping)
- Path planning
- Obstacle avoidance
- Motion control

### Perception Pipeline
- Sensor fusion
- Object detection/classification
- Sensor calibration
- Real-time processing

## Safety Architecture
- Safety-rated monitoring
- Emergency stop integration
- Failsafe behaviors
- Watchdog strategies
