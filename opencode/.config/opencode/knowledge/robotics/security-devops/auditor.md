# Robotics Domain - Security & DevOps Knowledge

Domain-specific guidance for Security-DevOps agent working on robotics projects.

## Security Considerations

### Network Security
- TLS for ROS communication
- Authentication (SROS)
- Network segmentation
- Firewall rules

### ROS Security
- SROS2 (Security Meta-ACL)
- Encrypted topics/services
- Node authentication
- Access control policies

### Physical Security
- Robot access control
- Emergency stop network
- Sensor tampering detection
- Firmware integrity

### Data Security
- Sensor data protection
- Privacy (camera feeds)
- Secure storage
- Audit logging

## Common Vulnerabilities
- Unencrypted ROS topics
- No authentication on interfaces
- Default credentials
- Missing firmware signing
