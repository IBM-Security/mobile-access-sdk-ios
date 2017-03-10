# Certificate pinning
Certificate pinning enables setting a custom CA or certificate as permitted in your app.

Certificate pinning can be useful in two major cases:
- In development: enabling self-signed certificates on development servers.
- In production: ensuring that only certificates *you've* pinned to the app are trusted. If some other CA is breached and starts issuing certificates for isam.yourservice.com, you are protected.

Please refer to the relevant platform documentation for best practices.

## Downloading the certificate
Working with a development server, the following is the easiest way to download a certificate chain:
```sh
# for DER:
openssl s_client -connect <host>:<port> -showcerts 2>/dev/null </dev/null | openssl x509 -inform pem -outform der -out <certificate-name>.der
# for PEM:
openssl s_client -connect <host>:<port> -showcerts 2>/dev/null </dev/null | openssl x509 -inform pem -outform pem -out <certificate-name>.pem
```

## iOS

> Need to [download your server's certificate](README.md#downloading-the-certificate)?

Implement a [URLSessionDelegate](https://developer.apple.com/reference/foundation/urlsessiondelegate) and pass it to our `Context` classes.

Note that when calling the completionHandler to approve, you must pass in the `NSURLCredential`.

Refer to Apple's [Secure Transport](https://developer.apple.com/reference/security/secure_transport) documentation for more information.

### Pin a custom CA
To require that *only your* CA can sign:
```swift
// configuring the SDK:
guard let delegate = PinnedCertificateDelegate(forResource: "jenkins", ofType: "der") else {
    // the optional initialiser returned nil (eg unable to load the file);
    // check for this because the SDK treats nil delegate as "use the OS' standard validation", so your certificate will not be pinned
    // for your certificate-pinning app, this is likely a failure condition
}
ChallengeContext.sharedInstance.serverTrustDelegate = delegate

// A URLSessionDelegate which pins the requested certificate as the only accepted CA.
// The essential part is the urlSession(_:challenge:completionHandler) method.
public class PinnedCertificateDelegate: NSObject, URLSessionDelegate {
    let pinnedCertificateData: NSData

    init?(forResource: String, ofType: String?) {
        guard let file = Bundle(for: type(of: self)).path(forResource: forResource, ofType: ofType) else {
            return nil
        }
        do {
            self.pinnedCertificateData = try NSData(contentsOfFile: file)
        } catch {
            return nil
        }
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
            let presentedCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                // this is unusual
                completionHandler(.cancelAuthenticationChallenge, nil) // don't let it fall through to the next validator
                return
        }
        let presentedCertificateData: NSData = SecCertificateCopyData(presentedCertificate)
        if (presentedCertificateData as NSData).isEqual(to: pinnedCertificateData as Data) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil) // don't let it fall through to the next validator
        }
    }
}
```

### Add a custom CA
To enable a custom CA as well as others, the code is very similar, but reject rather than cancel the challenge in your delegate:
```swift
// inside PinnedCertificateDelegate:
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
            let presentedCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                // this is unusual
                completionHandler(.rejectProtectionSpace, nil) // <----
                return
        }
        let presentedCertificateData: NSData = SecCertificateCopyData(presentedCertificate)
        if (presentedCertificateData as NSData).isEqual(to: pinnedCertificateData as Data) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.rejectProtectionSpace, nil) // <---- do let it fall through to other validators
        }
    }
```

### Allow all connections
You should only do this during development, and even then, it's usually better to pin the certificate of your development server.

```swift
ChallengeContext.sharedInstance.serverTrustDelegate = AlwaysApproveDelegate()

class AlwaysApproveDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("Warning: blindly approving an SSL connection.")
        guard let serverTrust: SecTrust = challenge.protectionSpace.serverTrust else {
            print("Warning verifying SSL session: Unknown serverTrust in the protection space")
            completionHandler(.useCredential, nil); return
        }
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}
