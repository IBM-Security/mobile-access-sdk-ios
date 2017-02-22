//
//  LoginViewController.swift
//  authentication
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//      http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import UIKit
import IBMMobileKit
import AVFoundation
import LocalAuthentication

class LoginViewController: UIViewController
{
    // MARK: Variables
    var settingsInfo = SettingsInfo()
    
    @IBOutlet weak var passwordTextbox: UITextField!
    @IBOutlet weak var usernameTextbox: UITextField!
    
    // MARK: View Controller Functions
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Control Events
    @IBAction func loginClick(sender: UIButton)
    {
        let username = self.usernameTextbox.text
        let password = self.passwordTextbox.text
        
        // Check to make sure that settings have been entered.
        if(self.settingsInfo.hostName.isEmpty || self.settingsInfo.clientId.isEmpty)
        {
            let alert = UIAlertController(title: "Settings", message: "The application settings have not been entered.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        // Show the network actiivity
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        
        OAuthContext.sharedInstance.clientSecret = self.settingsInfo.clientSecret
        OAuthContext.sharedInstance.getAccessToken(self.settingsInfo.hostName, self.settingsInfo.clientId, username: username!, password: password!)
        {
            (result) -> Void in
        
            dispatch_async(dispatch_get_main_queue(),
            {
                if result.hasError
                {
                    // Display an alert before deleting
                    let alert = UIAlertController(title: "Authentication Error", message: result.errorDescription, preferredStyle: .Alert)
                    
                    // Add the alert actions OK and Cancel.
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    
                    // present the ViewController to display the alert.
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else
                {
                    let alert = UIAlertController(title: "Success", message: "Here is the OAuth token.\n\(result.serializeToJson())", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                // Hide the network actiivity
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                return
            })
        }
    }

    // MARK: Navigation
    
    // This segue navigates to the settings view.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "ShowSettings"
        {
            if let destination = segue.destinationViewController as? SettingsViewController
            {
                destination.settingsInfo = self.settingsInfo
            }
        }
    }
    
    // This segue navigates back to the main view when cancel is clicked on settings view.
    @IBAction func cancelFromSettingsViewController(segue:UIStoryboardSegue)
    {
    }
    
    // This seque navigates back to the main view when save is click on the settings view.
    @IBAction func saveSettingsInfo(segue:UIStoryboardSegue)
    {
        if let viewController = segue.sourceViewController as? SettingsViewController
        {
            // Update the settingsInfo object.
            self.settingsInfo = viewController.settingsInfo!
        }
    }
}

