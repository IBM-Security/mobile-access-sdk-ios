import UIKit
import IBMMobileKit
import AVFoundation
import LocalAuthentication

class ViewController: UIViewController
{

    // MARK: Control variables
    @IBOutlet weak var textboxUsername: UITextField!
    @IBOutlet weak var textboxPassword: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonInvoke: UIButton!
    
    // MARK: Variables
    var token: OAuthToken!
    var challenge: ChallengeProtocol!
    let hostname = "https://sdk.securitypoc.com/mga/sps/oauth/oauth20/token"
    let policyUri = "https://sdk.securitypoc.com/mga/sps/apiauthsvc?PolicyId=urn:ibm:security:authentication:asf:password"
    let clientId = "IBMVerifySDK"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Pad the left and right margins of the textboxes.
        textboxUsername.leftView = UIView(frame: CGRect(x: 0, y:0, width: 10, height:10))
        textboxUsername.leftViewMode = .always
        textboxPassword.leftView = UIView(frame: CGRect(x: 0, y:0, width: 10, height:10))
        textboxPassword.leftViewMode = .always;
        
        // Register the UsernamePassword challenge.  This is done to ensure that the ChallengeContext.sharedInstance.invoke parses the correct challenge.
        ChallengeContext.sharedInstance.register(UsernamePasswordChallenge())
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
    @IBAction func onLoginClick(_ sender: UIButton)
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
                    alert = UIAlertController(title: "Password Policy Sample", message: result.errorDescription, preferredStyle: .alert)
                }
                else
                {
                    // We got the token.
                    self.token = result.serializeToToken()
                    self.token.store()
                    
                    alert = UIAlertController(title: "Password Policy Sample", message: result.serializeToJson(), preferredStyle: .alert)
                }
                
                // Show the message.
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    
    @IBAction func onInvokeClick(_ sender: UIButton)
    {
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        var alert: UIAlertController!
        
        // Attempt to load the token.
        token = OAuthToken.retrieve()
        
        // Check for the token.
        guard token != nil else
        {
            // Show the message.
            alert = UIAlertController(title: "Password Policy Sample", message: "No OAuth token available.", preferredStyle: .alert)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
                
                
        // Invoke the username password policy.
        ChallengeContext.sharedInstance.invoke(policyUri, token: token)
        {
            (result) -> Void in
            
            // Process callback on main UI thread and display alert.
            DispatchQueue.main.async
            {
                guard result.error == nil else
                {
                    // Show the error message.
                    alert = UIAlertController(title: "Password Policy Sample", message: result.errorDescription, preferredStyle: .alert)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                // Launch the challenge.
                self.challenge = result.nextChallenge
                self.challenge.launchUI(self.verifyUserInput)
            }
        }
    }
    
    /**
     Completion handler of the user interaction from *launchUI*.
     - parameter data: The user data provided by the dialog.
     - parameter error: The error returned.
    */
    func verifyUserInput(data: [String: Any], error: Error?) -> Void
    {
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        var alert: UIAlertController!
        
        guard error == nil else
        {
            // Show the error message.
            alert = UIAlertController(title: "Password Policy Sample", message: error.debugDescription, preferredStyle: .alert)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Verify the challenge data collected from the dialog.
        ChallengeContext.sharedInstance.verify(challenge.postbackUri, token: token, data: data)
        {
            (result) in
            
            // Get the response from the challenge verify.
            DispatchQueue.main.sync
            {
                guard result.error == nil else
                {
                    // Show the error message with a Try Again and Cancel option.
                    alert = UIAlertController(title: "Password Policy Sample", message: result.error.debugDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Try Again", style: .default)
                    {
                        (_) in
                        result.nextChallenge!.launchUI(self.verifyUserInput)
                    })
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel)
                    {
                        (_) in
                        self.dismiss(animated: true, completion: nil)
                    })

                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                // Check if the user data was verified.
                if result.status
                {
                    // Check if there are any other challenges, if not then show a success alert.
                    guard result.nextChallenge == nil else
                    {
                        // Launch the challenge.
                        self.challenge = result.nextChallenge
                        self.challenge.launchUI(self.verifyUserInput)
                        return
                    }
                    
                    
                    // Show the success message.
                    alert = UIAlertController(title: "Password Policy Sample", message: "Challenge was succesful.", preferredStyle: .alert)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

