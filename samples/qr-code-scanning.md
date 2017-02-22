# Scanning and processing QR codes

The SDK provides `OtpQRScanResult` and `MfaQRScanResult` classes. These are the two kinds of QR code it knows about.

| Type | Purpose | Example |
| ---- | ------- | ------- |
| OtpQRScanResult | A standard one-time password (implemented by many apps) | `otpauth://hotp/Big%20Blue%20Bank:testuser?secret=JBSWY3DPEHPK3PXP` |
| MfaQRScanResult | An ISAM multi-factor-auth account | `{"code": "OAuthAuthorizationCode", "details_url": "https://big-blue-bank.com/registration_details", "client_id": "OAuthClientId", "token_endpoint": "https://big-blue-bank.com/oauth/oauth20/authorize"}` |

The simplest way to scan a QR code is to use the `UIQRScanView` class, which produces these result objects (named `QRScanResultProtocol` or `IQRScanResult`). If you want to use your own scanner, there are `.parse()` methods to generate the results.

## iOS

Register your view controller as a `QRScanResultDelegate`. Upon capture, it will call `didGetScanResult()` upon success with a `QRScanResultProtocol`, and stop scanning.
