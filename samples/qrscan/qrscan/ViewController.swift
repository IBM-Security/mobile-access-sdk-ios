import UIKit
import IBMMobileKit
import AVFoundation
import LocalAuthentication

class ViewController: UIViewController, QRScanResultDelegate
{
    // MARK: Control variables
    @IBOutlet weak var viewQRCamera: UIQRScanView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        viewQRCamera.delegate = self
        viewQRCamera.setNeedsDisplay()
        
        // Set the scan colors (optional)
        viewQRCamera.scanMatchColor = UIColor.green
        viewQRCamera.scanNoMatchColor = UIColor.red
        viewQRCamera.scanOutlineWidth = 3
    }

    // MARK: QRScanResultDelegate method
    
    /**
     The function that contains the result of an successful registrations scan.
     
     - parameter result: An instance of `QRScanResultProtocol`.
     */
    func didGetScanResult(_ result: QRScanResultProtocol)
    {
        var alert: UIAlertController!
        let action = UIAlertAction(title: "OK", style: .default, handler:
        {
            _ in
            self.viewQRCamera.startCapture()
        })
        
        // What kind of QR code was returned.
        if let result = result as? MfaQRScanResult
        {
            alert = UIAlertController(title: "QR Scan Sample", message: "Client ID: \(result.clientId)\nCode: \(result.code)\nIgnore SSL Certs: \(result.ignoreSslCerts)\nMetadata Url: \(result.metadataUrl)\nVersion: \(result.version)", preferredStyle: .actionSheet)
        }
        else if let result = result as? OtpQRScanResult
        {
            alert = UIAlertController(title: "QR Scan Sample", message: "OTP Type: \(result.type)\nAlgorithm: \(result.algorithm)\nDigits: \(result.digits)\nIssuer: \(result.issuer ?? "none")\nUsername: \(result.username ?? "none")", preferredStyle: .actionSheet)
        }
        
        // Show the message.
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

