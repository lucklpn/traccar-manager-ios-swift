//
// Copyright 2016 Anton Tananaev (anton.tananaev@gmail.com)
// Copyright 2016 William Pearse (w.pearse@gmail.com)
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

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var serverField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // user can't do anything until they're logged-in
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let d = UserDefaults.standard
        if let s = d.string(forKey: TCDefaultsServerKey) {
            self.serverField.text = s
        }
        if let e = d.string(forKey: TCDefaultsEmailKey) {
            self.emailField.text = e
        }
        
        if self.serverField.text?.characters.count > 0 && self.emailField.text?.characters.count > 0 {
            self.passwordField.becomeFirstResponder()
        }
        
        emailField!.becomeFirstResponder()
    }

    @IBAction func loginButtonPressed() {
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        WebService.sharedInstance.authenticate(serverField!.text!, email: emailField!.text!, password: passwordField!.text!, onFailure: { errorString in
            
                DispatchQueue.main.async(execute: {
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    let ac = UIAlertController(title: "Couldn't Login", message: errorString, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    ac.addAction(okAction)
                    self.present(ac, animated: true, completion: nil)
                })
            
            }, onSuccess: { (user) in
                
                DispatchQueue.main.async(execute: {
                
                    // save server, user
                    let d = UserDefaults.standard
                    d.setValue(self.serverField!.text!, forKey: TCDefaultsServerKey)
                    d.setValue(self.emailField!.text!, forKey: TCDefaultsEmailKey)
                    d.synchronize()
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                
                    self.dismiss(animated: true, completion: nil)
                })
            }
        )
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
