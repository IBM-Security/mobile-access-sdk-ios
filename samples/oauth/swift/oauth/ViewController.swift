import UIKit
import IBMMobileKit
import AVFoundation
import LocalAuthentication

class ViewController: UIViewController
{

    // MARK: Control variables
    @IBOutlet weak var textboxUsername: UITextField!
    @IBOutlet weak var textboxPassword: UITextField!
    @IBOutlet weak var viewQRCamera: UIQRScanView!
    @IBOutlet weak var buttonOK: UIButton!
    @IBOutlet weak var buttonRefresh: UIButton!
    
    // MARK: Variables
    var token: OAuthToken!
    let hostname = "https://sdk.securitypoc.com/mga/sps/oauth/oauth20/token"
    let clientId = "IBMVerifySDK"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Pad the left and right margins of the textboxes.
        textboxUsername.leftView = UIView(frame: CGRect(x: 0, y:0, width: 10, height:10))
        textboxUsername.leftViewMode = .always
        textboxPassword.leftView = UIView(frame: CGRect(x: 0, y:0, width: 10, height:10))
        textboxPassword.leftViewMode = .always;
    }
    
    // Dismiss the keyboard.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch = touches.first else
        {
            return
        }
        
        if(!touch.isMember(of: UITextField.self))
        {
            touch.view?.endEditing(true)
        }
    }
    
    // MARK: Control events
    @IBAction func onOkClick(_ sender: UIButton)
    {
        var alert: UIAlertController!
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        let username = textboxUsername.text
        let password = textboxPassword.text         // passw0rd
        
        NSLog("Username: \(String(describing: username))")
        NSLog("Password: \(String(describing: password))")
        NSLog("Endpoint URL: \(hostname)")
        NSLog("ClientId: \(clientId)")
        
        OAuthContext.sharedInstance.getAccessToken(hostname, clientId, username: username!, password: password!)
        {
            (result) -> Void in
            
            // Process callback on main UI thread to display alert.
            DispatchQueue.main.async
            {
                if result.hasError
                {
                    alert = UIAlertController(title: "OAuth Sample", message: result.errorDescription, preferredStyle: .alert)
                }
                else
                {
                    // We got the token.
                    self.token = result.serializeToToken()
                    self.token.store()
                    
                    alert = UIAlertController(title: "OAuth Sample", message: result.serializeToJson(), preferredStyle: .alert)
                }
                
                // Show the message.
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func onRefreshClick(_ sender: UIButton)
    {
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        var alert: UIAlertController!
        
        // Attempt to load the token.
        token = OAuthToken.retrieve()
        
        // Check for the token.
        guard token != nil else
        {
            // Show the error message.
            alert = UIAlertController(title: "OAuth Sample", message: "No token to refresh.", preferredStyle: .alert)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        NSLog("Endpoint URL: \(hostname)")
        NSLog("ClientId: \(clientId)")
        
        NSLog("== Old Token ==")
        NSLog("Access token: \(self.token.accessToken)")
        NSLog("Refresh token: \(self.token.refreshToken)")
        NSLog("Should refresh: \(self.token.shouldRefresh)")
        
       OAuthContext.sharedInstance.refreshAccessToken(hostname, clientId, refreshToken:token.refreshToken)
       {
            (result) -> Void in
            
            // Process callback on main UI thread and display alert.
            DispatchQueue.main.async
            {
                if(result.hasError)
                {
                    alert = UIAlertController(title: "OAuth Sample", message: result.errorDescription, preferredStyle: .alert)
                }
                else
                {
                    // We got the token, update it.
                    self.token = result.serializeToToken()
                    self.token.store()
                    
                    NSLog("== New Token ==");
                    NSLog("Access token: \(self.token.accessToken)")
                    NSLog("Refresh token: \(self.token.refreshToken)")
                    NSLog("Should refresh: \(self.token.shouldRefresh)")
                    
                    alert = UIAlertController(title: "OAuth Sample", message: result.serializeToJson(), preferredStyle: .alert)
                }
                
                // Show the message.
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

