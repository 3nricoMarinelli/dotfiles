# Mobile Domain - Builder Knowledge

Domain-specific guidance for Builder agent working on mobile projects.

## Integration Types

| Integration | SDK/Tool | Notes |
|-------------|----------|-------|
| Analytics | Firebase Analytics, Mixpanel, Amplitude | Event tracking |
| Auth | Firebase Auth, Auth0, Cognito | Social + email |
| Push | Firebase Cloud Messaging, APNs | Notifications |
| Storage | Firebase Storage, AWS S3, Cloudinary | Media handling |
| Payments | Stripe, PayPal, IAP | In-app purchases |
| Maps | Google Maps, MapKit, Mapbox | Location services |
| Hardware | HealthKit, ARKit, CoreMotion | Platform sensors |

## Authentication Flows
- OAuth 2.0 / OpenID Connect
- Biometric authentication (Face ID, Touch ID, Fingerprint)
- Certificate pinning
- Secure token storage (Keychain, EncryptedSharedPreferences)

## Platform SDKs
- **iOS**: CocoaPods, Swift Package Manager
- **Android**: Gradle, Maven
- **Flutter**: pub.dev packages

## Common Integration Issues
- API key management (never in code)
- Network reachability handling
- Offline mode support
- Deep link handling
- App group sharing (iOS)
