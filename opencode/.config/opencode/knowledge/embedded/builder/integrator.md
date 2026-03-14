# Embedded Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on embedded projects.

## Integration Types

| Integration | Protocols | Notes |
|-------------|-----------|-------|
| Sensors | I2C, SPI, UART | Common sensor interfaces |
| Actuators | PWM, GPIO, DAC | Motor, servo control |
| Communication | CAN, LIN, UART, SPI | Inter-device communication |
| Storage | SD Card, EEPROM, Flash | Data logging |
| Wireless | BLE, WiFi, LoRa, Zigbee | IoT connectivity |

## Hardware Abstraction

### HAL (Hardware Abstraction Layer)
- Vendor-provided HAL (STM32 HAL, NXP SDK)
- Lightweight HAL implementations
- Portable across hardware variants

### Driver Types
- **Polling**: Simple, CPU-intensive
- **Interrupt-driven**: Efficient, complex
- **DMA**: High-throughput, memory intensive
- **RTOS-based**: Concurrent, complex synchronization

## Communication Protocols
- I2C: Master/slave, 100kHz-400kHz
- SPI: Full-duplex, configurable clock
- UART: Async, baud rate selection
- CAN: Automotive, robust error handling
- USB: HID, CDC, bulk transfers
