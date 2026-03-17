# Robotics Domain - TDD Workflow

Domain-specific guidance for TDD Guide agent working on ROS2/robotics projects.

## Testing Frameworks

### ROS2 Testing Ecosystem

| Framework | Language | Purpose | Command |
|-----------|----------|---------|---------|
| gtest | C++ | Unit tests | `colcon test` |
| Catch2 | C++ | Unit tests | `colcon test` |
| pytest | Python | Python tests | `colcon test` |
| launch_testing | Python | Integration tests | `colcon test` |
| rostest | Python | Integration tests | `ros2 test` |

## C++ TDD Pattern (ROS2)

```cpp
// 1. RED - Write failing test (gtest)
#include <gtest/gtest.h>
#include <my_package/node.hpp>

TEST(NodeTest, ProcessesSensorData) {
    MyNode node;
    sensor_msgs::msg::Image input;
    input.data = {1, 2, 3};
    
    auto output = node.process(input);
    
    EXPECT_EQ(output.data.size(), 3); // This fails
}

// 2. GREEN - Minimal implementation
std::vector<uint8_t> MyNode::process(const sensor_msgs::msg::Image& input) {
    return {0, 0, 0}; // Minimal fix
}

// 3. REFACTOR - Proper implementation
std::vector<uint8_t> MyNode::process(const sensor_msgs::msg::Image& input) {
    return input.data;
}
```

## Python TDD Pattern (ROS2)

```python
# 1. RED - Write failing test
import pytest
from my_package.node import MyNode

def test_processes_sensor_data():
    node = MyNode()
    input_data = [1, 2, 3]
    
    result = node.process(input_data)
    
    assert len(result) == 3  # This fails

# 2. GREEN - Minimal implementation
def process(self, data):
    return [0, 0, 0]  # Minimal fix

# 3. REFACTOR - Proper implementation
def process(self, data):
    return data
```

## ROS2-Specific Considerations

### Message/Service Testing
- Test with actual msg/srv types
- Use test fixtures for node lifecycle
- Test parameter handling

### Action Testing
```python
def test_action_server():
    action_client = ActionClient(...)
    goal = MyAction.Goal()
    goal.target = 10
    
    # Send goal and wait for result
    result = action_client.send_goal(goal)
    assert result.success
```

### Parameter Testing
```python
def test_node_parameters():
    rclpy.init()
    node = MyNode()
    
    assert node.get_parameter('param_name').value == 'default'
    
    rclpy.shutdown()
```

### Launch File Testing
```python
import launch_testing

def test_launch_file():
    ld = launch_testing.actions.IncludeLaunchDescription(...)
    # Test launch integration
```

## Coverage Requirements

| Test Type | Minimum Coverage |
|-----------|-----------------|
| Unit | 80% |
| Integration | 70% |
| Critical paths | 100% |

## Test Organization

```
my_package/
├── src/
│   └── my_node.cpp
├── include/
│   └── my_package/
│       └── my_node.hpp
├── test/
│   ├── test_my_node.cpp      # Unit tests
│   ├── test_my_node.launch.py # Launch tests
│   └── testfixtures.py        # Test utilities
└── package.xml
```

## Cross-Compilation Testing

```bash
# Build for target
colcon build --target-selections package_name

# Run tests
colcon test --packages-select package_name

# View results
colcon test-result --verbose
```
