//
//  SettingsViewController.swift
//  authentication
//
//  Copyright 2017 International Business Machines
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

import Foundation
import UIKit

class SettingsViewController: UITableViewController, UINavigationBarDelegate
{
    // MARK: Control Reference Variables
    @IBOutlet weak var hostnameTextbox: UITextField!
    @IBOutlet weak var clientIdTextbox: UITextField!
    @IBOutlet weak var clientSecretTextbox: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: Variables
    var settingsInfo: SettingsInfo?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Update the settings.
        hostnameTextbox.text = settingsInfo!.hostName
        clientIdTextbox.text = settingsInfo!.clientId
        clientSecretTextbox.text = settingsInfo!.clientSecret
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if saveButton === sender
        {
            settingsInfo?.hostName = hostnameTextbox.text!
            settingsInfo?.clientId = clientIdTextbox.text!
            settingsInfo?.clientSecret = clientSecretTextbox.text!
        }
    }
    
    // MARK: Control Events
       
    // MARK: UITableViewController Functions
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
       return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
}
