# Robotics Domain - Build Fixes

Common build errors and fixes for ROS2/robotics projects.

## colcon Build Errors

### Package Not Found

**Error:**
```
package 'xxx' not found
```

**Fix:**
```bash
# Source ROS2 environment
source /opt/ros/humble/setup.bash

# Source workspace
source install/setup.bash

# Rebuild dependencies
colcon build --packages-up-to <package_name>
```

### Missing Dependencies

**Error:**
```
package 'xxx' is missing a dependency: 'yyy'
```

**Fix:**
```xml
<!-- Add to package.xml -->
<depend>yyy</depend>

<!-- Or -->
<exec_depend>yyy</exec_depend>

<!-- Then rebuild -->
rosdep install --from-paths src --ignore-src -r -y
```

## CMake Errors (ROS2)

### Msg/Srv Generation

**Error:**
```
Could not find messages/service files: MyMsg.msg
```

**Fix:**
```cmake
# In CMakeLists.txt
find_package(rosidl_default_generators REQUIRED)

rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/MyMsg.msg"
  "srv/MyService.srv"
  DEPENDENCIES std_msgs sensor_msgs
)
```

### Missing Header

**Error:**
```
fatal error: my_package/node.hpp: No such file or directory
```

**Fix:**
```cmake
# Add include directories
include_directories(
  include
  ${ament_include_directories}
)
```

## Python Module Not Found

**Error:**
```
ModuleNotFoundError: No module named 'my_package'
```

**Fix:**
```bash
# Source the workspace
source install/setup.bash

# Install package in development mode
colcon build --symlink-install

# Or manually
source install/setup.bash
```

## Type Support Errors

**Error:**
```
Could not find type support for message type 'my_package/msg/MyMsg'
```

**Fix:**
```xml
<!-- In package.xml -->
<depend>rosidl_default_generators</depend>
<depend>rosidl_default_runtime</depend>
<member_of_group>rosidl_interface_packages</member_of_group>
```

## Cross-Compilation Errors

### Target Architecture

**Error:**
```
aarch64: No such file or directory
```

**Fix:**
```bash
# Specify correct toolchain
colcon build \
  --cmake-args \
  -DCMAKE_TOOLCHAIN_FILE=/path/to/aarch64-toolchain.cmake
```

### Missing Sysroot

**Error:**
```
cannot find -lstdc++
```

**Fix:**
```cmake
# In toolchain file
set(CMAKE_SYSROOT /path/to/sysroot)
set(CMAKE_FIND_ROOT_PATH /path/to/rootfs)
```

## Common Quick Fixes

### Clean Build
```bash
# Remove build/install/log directories
rm -rf build/ install/ log/

# Rebuild
colcon build --symlink-install

# Test
colcon test --packages-select <package>
```

### Rebuild Messages
```bash
# Rebuild specific message package
colcon build --packages-up-to <msg_package>
colcon build --packages-select <package>
```

### Environment Issues
```bash
# Source fresh
source /opt/ros/humble/setup.bash
source install/setup.bash

# Check RMW implementation
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
```

## Build Command Reference

| Command | Purpose |
|---------|---------|
| `colcon build` | Build all packages |
| `colcon build --packages-select PKG` | Build specific package |
| `colcon build --symlink-install` | Symlink for development |
| `colcon build --cmake-args -DCMAKE_BUILD_TYPE=Debug` | Debug build |
| `colcon test` | Run tests |
| `colcon test-result` | View test results |
