import UIKit
import LocalAuthentication
import AVFoundation
import IBMMobileKit

class ViewController: UIViewController
{

    // MARK: Control variables
    @IBOutlet weak var textboxKeyname: UITextField!
    @IBOutlet weak var switchUseTouchID: UISwitch!
    
    // MARK: Variables
    var domainState: Data?                  // The initial state of the enrolled fingerprints.
    let signingString = "Hello world"       // The sample string to sign with the private key.
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Pad the left and right margins of the textboxes.
        textboxKeyname.leftView = UIView(frame: CGRect(x: 0, y:0, width: 10, height:10))
        textboxKeyname.leftViewMode = .always
        
        // Get the domain state and assign it locally.
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        {
            domainState = context.evaluatedPolicyDomainState
        }
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


    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Control events
    @IBAction func onGenerateClick(_ sender: UIButton)
    {
        var alert: UIAlertController = UIAlertController(title: "Secure Key Sample", message: "Keys successfully generated.", preferredStyle: .alert)
        
        // Check if key already exists
        if KeychainHelper.checkKeyPairExists(textboxKeyname.text!)
        {
            alert = UIAlertController(title: "Secure Key Sample", message: "Key already exists.", preferredStyle: .alert)
        }
        else
        {
            var accessControlFlag: SecAccessControlCreateFlags?
            
            if switchUseTouchID.isOn
            {
                accessControlFlag = .userPresence       // Use Touch ID, but fallback to Passcode.
            }
            
            // Create the private and public keys.
            KeychainHelper.createKeyPair(textboxKeyname.text!, authenticationRequired: accessControlFlag)
            {
                (success, publicKeyData) -> Void in
                
                if !success
                {
                    alert = UIAlertController(title: "Secure Key Sample", message: "Keys not generated.", preferredStyle: .alert)
                }
            }
        }
        
        // Show the message.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    @IBAction func onSignClick(_ sender: UIButton)
    {
        var alert: UIAlertController = UIAlertController(title: "Secure Key Sample", message: "Test string '\(signingString)' signed.", preferredStyle: .alert)
        
        // Check if the state has changed since the app initialized.
        if KeychainHelper.hasAuthenticationSettingsChanged(domainState)
        {
            alert = UIAlertController(title: "secure_key", message: "Fingerprint store has changed sinced app launch.", preferredStyle: .alert)
            
            // Show the message.
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if KeychainHelper.signData(textboxKeyname.text!, value: signingString, localizedReason: "Secure Key Sample") == nil
        {
            alert = UIAlertController(title: "Secure Key Sample", message: "Unable to sign test string '\(signingString)'.", preferredStyle: .alert)
        }
        
        // Show the message.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    @IBAction func onRemoveClick(_ sender: UIButton)
    {
        var alert: UIAlertController = UIAlertController(title: "Secure Key Sample", message: "Private key deleted.", preferredStyle: .alert)
        
        // Delete the private key.
        KeychainHelper.deleteKeyPair(textboxKeyname.text!)
        {
            (success) -> Void in
            
            if(!success)
            {
                alert = UIAlertController(title: "Secure Key Sample", message: "Private key not found.", preferredStyle: .alert)
            }
        }
        
        // Show the message.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
}
