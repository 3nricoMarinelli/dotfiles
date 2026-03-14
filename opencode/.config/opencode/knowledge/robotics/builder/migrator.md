# Robotics Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on robotics projects.

## Migration Paths

| From | To | Considerations |
|------|-----|----------------|
| ROS1 | ROS2 | API changes, DDS, lifecycle |
| Python 2 | Python 3 | Print syntax, unicode |
| Indigo → Melodic → Noetic | ROS2 (Jazzy/Humble) | Major restructuring |
| Groovy/Hydro | Newer | Deprecated packages |

## ROS Version Migrations

### ROS1 → ROS2
- rclcpp/rclpy API
- Ament build system
- DDS middleware
- Lifecycle nodes
- Component-based composition

## Platform Porting
- Embedded platforms (NVIDIA Jetson, Raspberry Pi)
- Real-time extensions
- Cross-compilation

## Breaking Changes
- Message type changes
- Topic namespace changes
- Parameter handling differences
- Launch system differences
