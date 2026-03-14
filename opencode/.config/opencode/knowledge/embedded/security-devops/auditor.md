# Embedded Domain - Security & DevOps Knowledge

Domain-specific guidance for Security-DevOps agent working on embedded projects.

## Security Considerations

### Memory Safety
- No buffer overflows
- Stack protection
- MPU/MMU configuration
- Secure boot chain

### Cryptography
- Secure key storage
- OTA update verification
- TLS for network communication
- Secure random number generation

### Firmware Security
- Secure boot
- Flash readout protection
- JTAG/SWD disable
- Code signing

### Common Vulnerabilities
- CWE-119: Buffer overflow
- CWE-120: Classic buffer overflow
- CWE-190: Integer overflow
- CWE-295: Improper certificate validation

## Compliance
- IEC 61508 (functional safety)
- ISO 26262 (automotive)
- IEC 62304 (medical devices)
- NIST embedded security guidelines
