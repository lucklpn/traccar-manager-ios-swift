//
//  LoginViewController.swift
//  TraccarManager
//
//  Created by Anton Tananaev on 25/04/16.
//  Copyright © 2016 Anton Tananaev. All rights reserved.
//

import UIKit

let TCDefaultsServerKey = "DefaultsServerKey"
let TCDefaultsEmailKey = "DefaultsEmailKey"

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var serverField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // user can't do anything until they're logged-in
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let d = NSUserDefaults.standardUserDefaults()
        if let s = d.stringForKey(TCDefaultsServerKey) {
            self.serverField.text = s
        }
        if let e = d.stringForKey(TCDefaultsEmailKey) {
            self.emailField.text = e
        }
        
        if self.serverField.text?.characters.count > 0 && self.emailField.text?.characters.count > 0 {
            self.passwordField.becomeFirstResponder()
        }
        
        emailField!.becomeFirstResponder()
    }

    @IBAction func loginButtonPressed() {
        WebService.sharedInstance.authenticate(serverField!.text!, email: emailField!.text!, password: passwordField!.text!, onFailure: { errorString in
                // TODO: this is a bit plain
                UIAlertView(title: "Couldn't Login", message: errorString, delegate: nil, cancelButtonTitle: "OK").show()
            }, onSuccess: { (user) in
                
                // save server, user
                let d = NSUserDefaults.standardUserDefaults()
                d.setValue(self.serverField!.text!, forKey: TCDefaultsServerKey)
                d.setValue(self.emailField!.text!, forKey: TCDefaultsEmailKey)
                d.synchronize()
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        )
    }
    
    // move between text fields when return button pressed, and login
    // when you press return on the password field
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == serverField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            passwordField.resignFirstResponder()
            loginButtonPressed()
        }
        return true
    }

}
