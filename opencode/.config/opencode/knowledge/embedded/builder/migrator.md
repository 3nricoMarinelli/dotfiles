# Embedded Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on embedded projects.

## Migration Paths

| From | To | Considerations |
|------|-----|----------------|
| 8-bit MCU | 32-bit MCU | Toolchain, peripherals |
| Bare-metal | RTOS | Task management, memory |
| Vendor HAL | LLFW / bare-metal | Code size, control |
| Arduino | PlatformIO/STM32 | Performance, features |
| Mbed OS | FreeRTOS | Ecosystem differences |

## Toolchain Migrations
- Compiler: GCC, Clang, IAR, Keil
- Build system: Make, CMake, PlatformIO
- Debugger: OpenOCD, J-Link, ST-Link

## Platform Porting
- Cross-architecture (ARM Cortex-M ↔ RISC-V)
- Pin-compatible MCU upgrades
- Board support package (BSP) development

## Breaking Changes
- API changes in HAL versions
- RTOS API migrations (FreeRTOS v10→v11)
- Toolchain version impacts
- Silicon errata workarounds
