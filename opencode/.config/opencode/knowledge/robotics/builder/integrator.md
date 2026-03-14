# Robotics Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on robotics projects.

## Integration Types

| Integration | Protocol | Notes |
|-------------|----------|-------|
| Sensors | ROS messages | laser_scans, point_clouds, images |
| Actuators | ROS commands | cmd_vel, joint_trajectory |
| Cameras | image_transport | Compressed/transportoptimized |
| Lidar | point_cloud_transport | 3D perception |
| IMU | sensor_msgs/Imu | Motion tracking |
| GPS | sensor_msgs/NavSatFix | Localization |

## ROS Communication

### Topics
- Pub/sub for streaming data
- Asynchronous communication
- Topic monitoring and debugging

### Services
- Request/response RPC
- Synchronous calls
- Service introspection

### Actions
- Long-running tasks
- Feedback during execution
- Preemption support

## Hardware Integration
- Arduino/ROS serial
- CAN bus integration
- PWM motor control
- GPIO via embedded boards
