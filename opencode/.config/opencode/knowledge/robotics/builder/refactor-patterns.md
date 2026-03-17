# Robotics Domain - Refactor Patterns

Refactoring patterns specific to ROS2/robotics projects.

## ROS2 C++ Patterns

### Extract Node Component

```cpp
// Before: Large monolithic node
class MyRobotNode : public rclcpp::Node {
public:
    MyRobotNode() : Node("my_robot") {
        // 500+ lines of subscriptions, publishers, timers
    }
};

// After: Component-based architecture
class SensorNode : public rclcpp::Node { /* sensor logic */ };
class ProcessNode : public rclcpp::Node { /* processing logic */ };
class ControlNode : public rclcpp::Node { /* control logic */ };
```

### Separate Callbacks

```cpp
// Before: Heavy callbacks in main node
void MyNode::laserCallback(const sensor_msgs::msg::LaserScan::SharedPtr msg) {
    // Heavy processing
    // Multiple publications
    // Timer creation
}

// After: Separate into dedicated handlers
void SensorHandler::handleLaser(const sensor_msgs::msg::LaserScan::SharedPtr msg) {
    // Just data transformation
}
```

### Use Composition

```cpp
// Before: Single executable node
int main(int argc, char** argv) {
    rclcpp::init(argc, argv);
    rclcpp::spin(std::make_shared<MyNode>());
    rclcpp::shutdown();
}

// After: Composable nodes
int main(int argc, char** argv) {
    rclcpp::init(argc, argv);
    rclcpp::executors::MultiThreadedExecutor executor;
    
    executor.add_node(std::make_shared<SensorNode>());
    executor.add_node(std::make_shared<ProcessNode>());
    
    executor.spin();
    rclcpp::shutdown();
}
```

## ROS2 Python Patterns

### Extract Plugin

```python
# Before: Monolithic node
class RobotNode(Node):
    def __init__(self):
        super().__init__('robot_node')
        # 1000+ lines
        
# After: Plugin-based
class SensorPlugin:
    def process(self, data): ...

class SensorNode(Node):
    def __init__(self):
        super().__init__('sensor_node')
        self.plugins = [SensorPlugin()]
```

### Use Parameters Properly

```python
# Before: Hardcoded values
def process(self):
    threshold = 0.5  # Magic number

# After: Parameter-based
def __init__(self):
    super().__init__('node')
    self.declare_parameter('threshold', 0.5)

def process(self):
    threshold = self.get_parameter('threshold').value
```

### Clean Timer Handlers

```python
# Before: Mixed concerns in timer
def timer_callback(self):
    self.read_sensor()    # I/O
    self.process_data()   # Computation
    self.publish()        # Output
    self.log_status()     # Logging

# After: Separate concerns
def read_callback(self):
    self.data = self.read_sensor()

def process_callback(self):
    self.processed = self.process_data(self.data)

def publish_callback(self):
    self.publisher.publish(self.processed)
```

## Dead Code Patterns (ROS2)

### Unused Subscriptions
```python
# Remove unused subscriptions
# self.sub = self.create_subscription(...)  # DELETE
```

### Unused Parameters
```xml
<!-- Remove from yaml -->
<!-- rate: 10  # DELETE -->
```

### Deprecated Messages
```python
# Replace deprecated
# from geometry_msgs.msg import PoseStamped  # Old
from geometry_msgs.msg import Pose  # New
```

### Dead Launch Files
```bash
# Remove unused launch files
# rm launch/old_launch.py
```

## Code Smells (ROS2)

### Node Naming
```python
# Bad: No namespace
self.node = rclpy.node.Node('my_node')

# Good: With namespace
self.node = rclpy.node.Node('my_node', namespace='/robot1')
```

### QoS Mismatch
```python
# Bad: Default QoS may not match
pub = node.create_publisher(String, 'topic')

# Good: Explicit QoS
pub = node.create_publisher(
    String, 'topic',
    qos_profile=QoSProfile(depth=10, reliability=ReliabilityPolicy.RELIABLE)
)
```

### Missing Error Handling
```python
# Bad: No error handling
def callback(self, msg):
    self.process(msg)  # May throw

# Good: Proper error handling
def callback(self, msg):
    try:
        self.process(msg)
    except Exception as e:
        self.get_logger().error(f'Processing failed: {e}')
```

### Resource Leaks
```python
# Bad: No cleanup
def __init__(self):
    self.timer = self.create_timer(0.1, self.callback)

# Good: Cleanup on shutdown
def __init__(self):
    self.timer = self.create_timer(0.1, self.callback)
    
def __del__(self):
    self.timer.cancel()
```

## Performance Refactoring

### Spin vs MultiThreadedExecutor
```python
# Simple cases: Single-threaded spin
rclpy.spin(node)

# Multi-publisher: Multi-threaded
executor = MultiThreadedExecutor(num_threads=4)
executor.add_node(node)
executor.spin()
```

### Message Copying
```cpp
// Bad: Unnecessary copy
auto msg = *input_msg;

// Good: Const reference
const auto& msg = *input_msg;
```

### Rate Limiting
```python
# Bad: No rate limiting
while True:
    publish()
    time.sleep(0.001)  # Too fast

# Good: Use Rate
rate = node.create_rate(10)  # 10 Hz
while rclpy.ok():
    publish()
    rate.sleep()
```
