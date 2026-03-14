# Mobile Domain - Security & DevOps Knowledge

Domain-specific guidance for Security-DevOps agent working on mobile projects.

## Security Considerations

### Data Storage
- Keychain (iOS) / EncryptedSharedPreferences (Android)
- iOS Keychain access control
- Android Keystore for cryptographic keys
- SQLCipher for encrypted databases

### Network Security
- TLS 1.3 minimum
- Certificate pinning (TrustManager customization)
- Certificate transparency
- No cleartext traffic (ATS - iOS)

### Authentication
- OAuth 2.0 with PKCE
- Biometric authentication integration
- Secure token storage
- Session management

### Platform Security
- iOS: Keychain, Secure Enclave, Face ID/Touch ID
- Android: SafetyNet, Play Integrity, BiometricPrompt
- Flutter: local_auth, flutter_secure_storage

### Privacy
- App Tracking Transparency (iOS 14+)
- Privacy nutrition labels
- Permission handling (camera, location, contacts)
- Data minimization

## Compliance
- App Store Review Guidelines
- Google Play Privacy Policy
- GDPR, CCPA compliance
- SOC 2 for enterprise apps
