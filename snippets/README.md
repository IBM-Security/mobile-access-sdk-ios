# Code Snippets

<table>
    <tr>
        <th width="300px">Name</th>
        <th>Type</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>Get OAuth token</td>
        <td><a href="#oauthtoken">Snippet</a></td>
        <td> The SDK supports the ROPC grant flow.</td>
    </tr>
    <tr>
        <td>Certificate pinning</td>
        <td><a href="#certpin">Snippet</a></td>
        <td>Compares a certificate stored in the mobile app as being the same certificate presented by the web server that provides the HTTPS connection.</td>
    </tr>
    <tr>
        <td>Key pair generation</td>
        <td><a href="#keypairgen">Snippet</a></td>
        <td>TKey pairs are used in the SDK to sign challenges, coming from IBM Security Access Manager. The private key remains on the device, whereas the public key gets uploaded to the server as part of the mechanisms enrollment.</td>
    </tr>
     <tr>
        <td>Signing data</td>
        <td><a href="#signdata">Snippet</a></td>
        <td>The public key would be stored on a server and provide the challenge text to the client. The client uses the private key to sign the data which is sent back to the server. The server validates the signed data against the public key to verify the keys have not been tampered with.</td>
    </tr>
</table>

<h2 id="oauthtoken">Get OAuth token</h2>
The SDK supports the ROPC grant flow.
<br/>


![Swift Version](https://img.shields.io/badge/swift-3.0-orange.svg)

```swift
let hostname = "https://sdk.securitypoc.com/mga/sps/oauth/oauth20/token"
let clientId = "IBMVerifySDK"
let username = "testuser1"
let password = "passw0rd"
    
OAuthContext.sharedInstance.getAccessToken(hostname, clientId, username: username, password: password)
{
  (result) -> Void in
  
  if result.hasError
  {
    print("Error: \(String(describing: result.errorDescription))")
  }
  else
  {
    // We got the token.
    print("Token: \(String(describing: result.serializeToToken()))")
  }
}
```


![Objective-C Version](https://img.shields.io/badge/Objective--C-2.0-orange.svg)

```objective-c
NSString *hostname = @"https://sdk.securitypoc.com/mga/sps/oauth/oauth20/token";
NSString *clientId = @"IBMVerifySDK";
NSString *username = @"testuser1";
NSString *password = @"passw0rd";

OAuthContext *context = [OAuthContext sharedInstance];

[context getAccessToken :hostname :clientId username:username password:password completion:^(OAuthResult *result) {
    if(result.hasError)
    {
        NSLog(@"Error: %@", result.errorDescription);
    }
    else
    {
        // We got the token.
        NSLog(@"Token: %@", result.serializeToJson);
    }
}];
```

<h2 id="certpin">Certificate pinning</h2>
Compares a certificate stored in the mobile app as being the same certificate presented by the web server that provides the HTTPS connection.  Refer to <a href="https://developer.apple.com/documentation/foundation/urlsessiondelegate">URLSessionDelegate</a> for additional information on session level events.  
<br/>
Assign the class implmentating `URLSessionDelegate` to `serverTrustDelegate` property of the `Context` classes in the SDK.
<br/><br/>
To obtain the certificate chain to include into your Xcode project, run the following command:

```bash
input=tmpinput && touch $input && openssl s_client -connect sdk.securitypoc.com:443 -showcerts 2>/dev/null <$input | openssl x509 -inform pem -outform der -out sdk_cert.der && rm $input
```

> Ensure the certifcate has been copied into the project folder and added to the project in Xcode.

<br/>

![Swift Version](https://img.shields.io/badge/swift-3.0-orange.svg)

```swift
public class PinnedCertificateDelegate: NSObject, URLSessionDelegate
{
    let pinnedCertificateData: Data
    
    // Initialized with the name of the file and the file extension.
    init?(forResource: String, withExtension: String)
    {
        guard let url = Bundle.main.url(forResource: forResource, withExtension: withExtension) else
        {
            return nil
        }
        
        do
        {
            self.pinnedCertificateData = try Data(contentsOf: url)
        }
        catch
        {
            return nil
        }
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        guard let serverTrust = challenge.protectionSpace.serverTrust, let presentedCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else
        {
            // Terminate further processing, no certificate at index 0
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Compare the presented certificate to the pinned certificate.
        let presentedCertificateData: NSData = SecCertificateCopyData(presentedCertificate)
        if presentedCertificateData.isEqual(to: pinnedCertificateData)
        {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            return
        }
        
        // Don't trust the presented certificate by default.
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}


private func execute()
{
    let hostname = "https://sdk.securitypoc.com/mga/sps/oauth/oauth20/token"
    let clientId = "IBMVerifySDK"
    let username = "testuser1"
    let password = "passw0rd"

    let certificateFile = "sdk_cert"
    let certificateExtension = "der"
    
    guard let delegate = PinnedCertificateDelegate(forResource: certificateFile, withExtension: certificateExtension) else
    {
        print("The certificate '\(certificateFile).\(certificateExtension)' was not found in app bundle.")
        return
    }
    
    OAuthContext.sharedInstance.serverTrustDelegate = delegate  // nil will default to standard ATS settings.
    OAuthContext.sharedInstance.getAccessToken(hostname, clientId, username: username, password: password)
    {
        (result) -> Void in

        if result.hasError
        {
            print("Error: \(String(describing: result.errorDescription))")
        }
        else
        {
            // We got the token.
            print("Token: \(String(describing: result.serializeToToken()))")
        }
    }
}
```


## Key pair generation
<h2 id="keypairgen">Key pair generation</h2>
Key pairs are used in the SDK to sign challenges, coming from IBM Security Access Manager. The private key remains on the device, whereas the public key gets uploaded to the server as part of the mechanisms enrollment.
<br/>

![Swift Version](https://img.shields.io/badge/swift-3.0-orange.svg)


```swift
// Create the private and public keys.
KeychainHelper.createKeyPair("sample")
{
    (success, publicKeyData) -> Void in

    if success && publicKeyData != nil
    {
        print("Public key: \(KeychainHelper.exportPublicKey(publicKeyData!)!)")
    }
}

// Delete the private key.
KeychainHelper.deleteKeyPair("sample")
{
    (success) -> Void in
    
    if(success)
    {
        print("Private key deleted.")
    }
}
```


![Objective-C Version](https://img.shields.io/badge/Objective--C-2.0-orange.svg)

```objective-c
// Create the private and public keys.
[KeychainHelper createKeyPair:@"sample" completion:^(BOOL success, NSData *result) {
    if(success)
    {
        NSLog(@"Public key: %@", [KeychainHelper exportPublicKey:result]);
    }
}];

// Delete the private key.
[KeychainHelper deleteKeyPair:@"sample" completion:^(BOOL success) {
    if(success)
    {
        NSLog(@"Private key deleted");
    }
}];
```

## Signing data
<h2 id="signdata">Signing data</h2>
The public key would be stored on a server and provide the challenge text to the client.  The client uses the private key to sign the data which is sent back to the server. The server validates the signed data against the public key to verify the keys have not been tampered with.


![Swift Version](https://img.shields.io/badge/swift-3.0-orange.svg)

```swift
// Create the private and public keys.
KeychainHelper.createKeyPair("sample")
{
    (success, publicKeyData) -> Void in

    if success && publicKeyData != nil
    {
        print("Public key: \(KeychainHelper.exportPublicKey(publicKeyData!)!)")
    }
}

// Sign the data.
print("Signed data: \(String(describing: KeychainHelper.signData("sample", value: "hello world")))")

// Delete the private key.
KeychainHelper.deleteKeyPair("sample")
{
    (success) -> Void in
    
    if(success)
    {
        print("Private key deleted.")
    }
}
```

![Objective-C Version](https://img.shields.io/badge/Objective--C-2.0-orange.svg)

```objective-c
// Create the private and public keys.
[KeychainHelper createKeyPair:@"sample" completion:^(BOOL success, NSData *result) {
    if(success)
    {
        NSLog(@"Public key: %@", [KeychainHelper exportPublicKey:result]);
    }
}];

// Sign the data.
NSLog(@"Signed data: %@", [KeychainHelper signData: @"sample" value: @"hello world"]);

// Delete the private key.
[KeychainHelper deleteKeyPair:@"sample" completion:^(BOOL success) {
    if(success)
    {
        NSLog(@"Private key deleted");
    }
}];
```
