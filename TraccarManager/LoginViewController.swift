//
//  LoginViewController.swift
//  TraccarManager
//
//  Created by Anton Tananaev on 25/04/16.
//  Copyright © 2016 Anton Tananaev. All rights reserved.
//

import UIKit

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
        
        emailField!.becomeFirstResponder()
    }

    @IBAction func loginButtonPressed() {
        Traccar.authenticate(serverField!.text!, email: emailField!.text!, password: passwordField!.text!, onFailure: { errorString in
                // TODO: this is a bit plain
                UIAlertView(title: "Couldn't Login", message: errorString, delegate: nil, cancelButtonTitle: "OK").show()
            }, onSuccess: { (user) in
                // TODO: do something with the user
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
