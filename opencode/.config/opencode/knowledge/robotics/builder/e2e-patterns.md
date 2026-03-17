# Robotics Domain - E2E Patterns

End-to-end testing patterns for ROS2/robotics systems.

## Testing Approaches

### 1. Launch Testing
Integration tests using ROS2 launch system

### 2. Integration Tests
Multi-node test scenarios

### 3. System Tests
Full robot system tests

## ROS2 Launch Testing

### Basic Launch Test (Python)

```python
import unittest
import launch_testing
from launch import LaunchDescription
from launch_ros.actions import Node

def generate_test_description():
    return LaunchDescription([
        Node(
            package='my_package',
            executable='my_node',
            output='screen'
        ),
        launch_testing.actions.ReadyToTest()
    ])

class TestMyNode(unittest.TestCase):
    def test_node_publishes(self, proc_info):
        proc_info.assertWaitForStartup(process=proc_info.processes[0])
        # Test assertions
```

### Launch Test with Multiple Nodes

```python
def generate_test_description():
    return LaunchDescription([
        Node(package='sensor_pkg', executable='sensor_node'),
        Node(package='my_package', executable='processor_node'),
        Node(package='my_package', executable='controller_node'),
        launch_testing.actions.ReadyToTest()
    ])

class TestIntegration(unittest.TestCase):
    def test_sensor_to_controller(self, proc_info):
        # Wait for all nodes
        for p in proc_info.processes:
            proc_info.assertWaitForStartup(process=p)
        
        # Test data flow
```

## Topic Testing

### Subscribe and Verify

```python
import rclpy
from sensor_msgs.msg import LaserScan

def test_laser_scan():
    rclpy.init()
    node = rclpy.node.Node('test_node')
    
    received = []
    
    def callback(msg):
        received.append(msg)
    
    node.create_subscription(LaserScan, '/scan', callback)
    
    # Wait for message
    timeout = node.get_clock().now() + Duration(seconds=5)
    while rclpy.ok() and node.get_clock().now() < timeout:
        rclpy.spin_once(node)
    
    assert len(received) > 0
    rclpy.shutdown()
```

## Action Testing

### Action Server/Client

```python
import rclpy
from action_tutorials_interfaces.action import Fibonacci

def test_action():
    rclpy.init()
    
    client = ActionClient(node, Fibonacci, 'fibonacci')
    goal = Fibonacci.Goal()
    goal.order = 10
    
    # Send goal
    send_goal_future = client.send_goal_async(goal)
    rclpy.spin_until_future_complete(node, send_goal_future)
    
    # Get result
    result_future = client.get_result_async(send_goal_future.result().goal_id)
    rclpy.spin_until_future_complete(node, result_future)
    
    assert result_future.result().result.sequence[-1] == 55
    rclpy.shutdown()
```

## Service Testing

### Service Client Test

```python
def test_add_two_ints():
    rclpy.init()
    node = rclpy.node.Node('test')
    
    client = node.create_client(AddTwoInts, 'add_two_ints')
    
    req = AddTwoInts.Request()
    req.a = 1
    req.b = 2
    
    # Call service
    future = client.call_async(req)
    rclpy.spin_until_future_complete(node, future)
    
    assert future.result().sum == 3
    rclpy.shutdown()
```

## Parameter Testing

```python
def test_parameters():
    rclpy.init()
    
    # Launch with parameters
    # (See launch test setup)
    
    node = rclpy.node.Node('test')
    
    # Test parameter value
    param = node.get_parameter('my_param')
    assert param.value == 'expected_value'
    
    rclpy.shutdown()
```

## Test Execution

### Run All Tests

```bash
# Build and test
colcon test

# View results
colcon test-result --verbose

# Test specific package
colcon test --packages-select my_package
```

### Run Launch Tests

```bash
# Install launch_testing_ros
apt install ros-humble-launch-testing-ros

# Run
ros2 launch test test_my_package.launch.py
```

## Best Practices

### Test Isolation
- Each test should be independent
- Clean up resources in teardown
- Use unique node names per test

### Timing Considerations
- Use appropriate timeouts
- Don't rely on exact timing
- Use message filters for synchronization

### Robot Safety
- Disable motor outputs in tests
- Use simulation when possible
- Test in isolated environment

### Logging
- Use rclpy logging
- Capture output for debugging
- Include test context in failures
