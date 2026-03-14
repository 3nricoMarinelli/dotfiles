# Robotics Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on robotics projects.

## Debugging Tools

| Tool | Purpose |
|------|---------|
| rqt | Visualization suite |
| rviz | 3D visualization |
| rqt_plot | Real-time plotting |
| rosbag | Message recording/playback |
| GDB | C++ debugging |
| pdb | Python debugging |
| Gazebo | Physics simulation |

## Debugging Approaches

### ROS Topic Debugging
- rostopic list/echo/hz
- rqt_topic_monitor
- Message flow tracing

### Visualization
- rviz for sensor data
- rqt_plot for timing
- rqt_graph for node graph

### Logging
- rosconsole
- rqt_console
- rosout to log files

### Common Issues
- Topic/service name conflicts
- Clock synchronization
- TF transforms
- Message serialization
- Node lifecycle issues
