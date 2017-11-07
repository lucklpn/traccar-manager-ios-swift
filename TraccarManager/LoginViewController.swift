//
// Copyright 2016 Anton Tananaev (anton.tananaev@gmail.com)
// Copyright 2016 William Pearse (w.pearse@gmail.com)
// Copyright 2017 Sergey Kruzhkov (s.kruzhkov@gmail.com)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


let TCDefaultsServerKey = "DefaultsServerKey"
let TCDefaultsEmailKey = "DefaultsEmailKey"
let TCDefaultsPassKey = "DefaultsPassKey"

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var serverField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var rememberSwitch: UISwitch!
    @IBOutlet var progressView: UIActivityIndicatorView!
    
    var trustDomain = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // user can't do anything until they're logged-in
        navigationItem.setHidesBackButton(true, animated: false)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        let d = UserDefaults.standard
        if let s = d.string(forKey: TCDefaultsServerKey) {
            self.serverField.text = s
        }
        if let e = d.string(forKey: TCDefaultsEmailKey) {
            self.emailField.text = e
        }
        
        if self.serverField.text?.count > 0 && self.emailField.text?.count > 0 {
            if let p = KeychainWrapper.standard.string(forKey: TCDefaultsPassKey) {
                self.passwordField.text = p
                self.loginButton.becomeFirstResponder()
            } else {
                self.passwordField.becomeFirstResponder()
            }
        }
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func loginButtonPressed() {
        
        progressView.startAnimating()
        
        WebService.sharedInstance.authenticate(serverField!.text!, email: emailField!.text!, password: passwordField!.text!, onFailure: { error in
            
            DispatchQueue.main.async(execute: {
                
                self.progressView.stopAnimating()
                
                if error.code == -1202 {
                    self.trustDomain = (URL(string: self.serverField.text!)?.host)!
                    
                    let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    let btnAllow = UIAlertAction(title: "Allow", style: .default, handler: {action in
                        self.saveDefaults()
                        let at = UIAlertController(title: "", message: self.trustDomain + " add to trusted domains. Restart application", preferredStyle: .alert)
                        at.addAction(UIAlertAction(title: "ОК", style: .cancel, handler: nil))
                        self.present(at, animated: true, completion: nil)
                        
                    })
                    ac.addAction(btnAllow)
                    self.present(ac, animated: true, completion: nil)
                } else {
                    let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                }
                
            })
            
        }, onSuccess: { (user) in
            
            DispatchQueue.main.async(execute: {
                
                self.saveDefaults()
                
                self.progressView.stopAnimating()
                
                self.dismiss(animated: true, completion: nil)
                
                self.performSegue(withIdentifier: "ShowMap", sender: self)
            })
        }
        )
    }
    
    func saveDefaults() {
        let d = UserDefaults.standard
        d.setValue(self.serverField!.text!, forKey: TCDefaultsServerKey)
        d.setValue(self.emailField!.text!, forKey: TCDefaultsEmailKey)
        if trustDomain != "" {
            d.setValue(trustDomain, forKey: Definitions.TCDefaultsTrustDomain)
        }
        d.synchronize()
        
        //save password to keychain
        if self.rememberSwitch.isOn {
            KeychainWrapper.standard.set(self.passwordField.text!, forKey: TCDefaultsPassKey)
        } else {
            KeychainWrapper.standard.removeObject(forKey: TCDefaultsPassKey)
        }
    }
    
    // move between text fields when return button pressed, and login
    // when you press return on the password field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
