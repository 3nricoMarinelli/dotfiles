# Embedded Domain - Build Fixes

Common build errors and fixes for embedded C++/Rust projects.

## CMake Errors

### Target Not Found

**Error:**
```
By not providing "FindXXX.cmake" in CMAKE_MODULE_PATH this project has
asked CMake to find a package configuration file but did not find it.
```

**Fix:**
```cmake
# Option 1: Install dependency
apt install libxxx-dev

# Option 2: Provide find module
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
find_package(XXX REQUIRED)
```

### Undefined Reference

**Error:**
```
undefined reference to `XXX::YYY()'
```

**Fix:**
```cmake
# Link against correct library
target_link_libraries(my_target PRIVATE XXX::XXX)
```

### Header Not Found

**Error:**
```
fatal error: xxx.h: No such file or directory
```

**Fix:**
```cmake
# Add include directory
target_include_directories(my_target PRIVATE ${CMAKE_SOURCE_DIR}/include)
```

## Cargo Errors

### Dependency Version Conflict

**Error:**
```
failed to select a version for `xxx`
... required by `yyy`
```

**Fix:**
```toml
# Check for version conflicts
cargo tree

# Pin compatible version in Cargo.toml
xxx = "=1.2.3"
```

### Feature Flag Disabled

**Error:**
```
the package `xxx` does not have feature `yyy`
```

**Fix:**
```toml
# Enable feature in Cargo.toml
[dependencies.xxx]
features = ["yyy"]
```

### Cross-Compilation Target Not Installed

**Error:**
```
target xxx not installed
```

**Fix:**
```bash
# Install target
rustup target add thumbv7em-none-eabihf

# List available targets
rustup target list
```

## Linker Errors

### Multiple Definition

**Error:**
```
multiple definition of `xxx'
```

**Fix:**
- Use `extern "C"` for C libraries
- Check for header guards
- Use inline or static for definitions

### Relocation R_X86_64_32S

**Error:**
```
relocation R_X86_64_32S against symbol `xxx' can not be used
```

**Fix:**
```cmake
# For embedded, use position-independent code
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
```

## C++ Specific Errors

### No Member Named 'xxx'

**Error:**
```
error: 'class XXX' has no member named 'yyy'
```

**Fix:**
- Check C++ standard version
- Update compiler or library
- Check namespace

### Template Instantiation

**Error:**
```
undefined reference to `void foo<int>'
```

**Fix:**
- Add template implementation to header
- Use `extern template` for explicit instantiation

## Rust Specific Errors

### Borrow Checker

**Error:**
```
cannot borrow `xxx` as mutable more than once
```

**Fix:**
```rust
// Use clone or Rc
let mut data = Rc::new(RefCell::new(Data::new()));
```

### Lifetime Error

**Error:**
```
missing lifetime specifier
```

**Fix:**
```rust
// Add explicit lifetimes
fn foo<'a>(x: &'a str) -> &'a str { x }
```

## Build Command Reference

| Platform | Command |
|----------|---------|
| CMake | `cmake -B build && cmake --build build` |
| Make | `make` |
| Ninja | `cmake -B build -G Ninja && cmake --build build` |
| Cargo | `cargo build` |
| Cross-compile | `cmake -B build -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake` |
