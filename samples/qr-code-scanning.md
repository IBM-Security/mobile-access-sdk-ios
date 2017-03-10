# Scanning and processing QR codes

The SDK provides `OtpQRScanResult` and `MfaQRScanResult` classes. These are the two kinds of QR code it knows about.

| Type | Purpose | Example |
| ---- | ------- | ------- |
| OtpQRScanResult | A standard one-time password (implemented by many apps) | `otpauth://hotp/Big%20Blue%20Bank:testuser?secret=JBSWY3DPEHPK3PXP` |
| MfaQRScanResult | An ISAM multi-factor-auth account | `{"code": "OAuthAuthorizationCode", "details_url": "https://big-blue-bank.com/registration_details", "client_id": "OAuthClientId", "token_endpoint": "https://big-blue-bank.com/oauth/oauth20/authorize", "version": 1}` |

Use the `UIQRScanView` class to scan a QR code, which produces these result objects named `QRScanResultProtocol`. If you want to use your own scanner, there are `.parse()` methods to generate the results.

## iOS

Register a view controller as a `QRScanResultDelegate`. Upon capture, it will call `didGetScanResult()` upon success with a `QRScanResultProtocol`, and stop scanning.
