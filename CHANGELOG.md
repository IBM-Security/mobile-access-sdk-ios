# Changelog iOS

## Mobile Access SDK v1.2.7 (planned)
- Support for determing biometric sensor on device from FrameworkHelper.
- Support for getting version information from FrameworkHelper.
- Support for Swift 4.1
- Support for Xcode 9.1
- Support for Cloud Identity Verify (CIV) registration, enrollment and verification.

## Mobile Access SDK v1.2.6
- Support for checking if key pair exists.

## Mobile Access SDK v1.2.5
- Build target updated to iOS 9 or greater.
- Support for private key generation with an access control constraint.
- Support for determining if keys may be invalidated for a domain state.
- UIQRScanView exposes configurable properties to display a border on successful and unsuccessful scans.
- Fix issue in UIQRScanView.startCapture() to reactivate the camera after a scan.

## Mobile Access SDK v1.2.4
- Support for custom headers in OAuthContext.
- Support Base64 encoding options for public key export and data signing.
- OAuthContext applies safe url encoding to all parameters.
- String extension urlSafeEncodedValue supports Base64 string encoding.
- Objective-C support for OAuthContext

## Mobile Access SDK v1.2.0
- Support for Swift 3.1
- Support for Xcode universal framework
- Support for internationalisation.
  * Czech, German, Spanish, French, Hungarian, Italian, Japanese, Korean, Polish, Portuguese, Russian, Chinese (Simplified and Taiwan) 
- Support for multi-factor (MFA) and non-MFA authentication enrolment
  * Touch ID
  * User presence enrolment
  * HOTP enrolment
  * TOTP enrolment
- Support for multi-factor (MFA) authentication unenrolment
  * Touch ID
  * User presence enrolment
- Support for context based challenge and verification
  * Touch ID
  * User presence enrolment
  * HOTP enrolment
  * TOTP enrolment
  * Username password
- Support for extending the context based challenge framework
- Support for querying pending challenges

## Mobile Access SDK v1.0.0
- Support for OAuth ROPC and AZN code flow
- Support for HMAC generated one-time password (HOTP)
- Support for time generated one-time password (TOTP)
