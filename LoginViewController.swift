//
//  LoginViewController.swift
//  IOSTestCLOUD
//
//  Created by Omar Skalli on 3/19/16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit
import Firebase
import QuartzCore


class LoginViewController: UIViewController, UITextFieldDelegate {

    let ref = Firebase(url: "https://radiant-heat-681.firebaseio.com/OuiCan%20Users")

    // Constants
    let LoginToDashboard = "LoginToDashboard"
    
    // Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    
    // UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textFieldLoginEmail.delegate = self
        self.textFieldLoginPassword.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func loginDidTouch(sender: AnyObject) {
        
        /*ref.authUser(textFieldLoginEmail.text, password: textFieldLoginPassword.text,
            withCompletionBlock: { (error, auth) in
                if error != nil {
                    // There was an error logging in to this account
                } else {
                    // We are now logged in
                    self.performSegueWithIdentifier(self.LoginToDashboard, sender: nil)

                }
        })
        */
    
        
    }
    
    @IBAction func signUpDidTouch(sender: AnyObject) {
        let alert = UIAlertController(title: "Register",
            message: "Register",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction) -> Void in
                
                let emailField = alert.textFields![0]
                let passwordField = alert.textFields![1]
                //let ouicanIDField = alert.textFields![2]
    
                self.ref.createUser(emailField.text, password: passwordField.text) { (error: NSError!) in
    
                if error == nil {
                self.ref.authUser(emailField.text, password: passwordField.text,
                     withCompletionBlock: { (error, auth) -> Void in
                                // 4
                        })
                }
            }
                
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textEmail) -> Void in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textPassword) -> Void in
            textPassword.secureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textOuicanId) -> Void in
            textOuicanId.placeholder = "Enter your OuiCan ID"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
    }
    
    

}
