//
//  Traccar.swift
//  TraccarManager
//
//  Created by William Pearse on 4/05/16.
//  Copyright © 2016 Anton Tananaev. All rights reserved.
//

import Foundation
import Alamofire

class Traccar: NSObject {
    
    static func authenticate(serverURL: String, email: String, password: String, onFailure: ((String) -> Void)? = nil, onSuccess: (User) -> Void) -> Bool {
        
        let url = "http://" + serverURL + "/api/session"
        
        let parameters = [
            "email" : email,
            "password": password
        ]
        
        Alamofire.request(.POST, url, parameters: parameters).responseJSON(completionHandler: { response in
                switch response.result {
                    
                case .Success(let JSON):
                    if let data = JSON as? [String : AnyObject] {
                        
                        // the api still returns a 200 status code (and empty
                        // response) on failed login...
                        // we need to catch this and return a failure
                        if data.keys.count == 0 {
                            if let fail = onFailure {
                                fail("Invalid email and/or password")
                            }
                        } else {
                            let u = User.sharedInstance
                            u.setValuesForKeysWithDictionary(data)
                            onSuccess(u)
                        }
                    } else {
                        if let fail = onFailure {
                            fail("Server response was invalid")
                        }
                    }
                    
                case .Failure(let error):
                    if let fail = onFailure {
                        fail(error.description)
                    }
            }
        })
        
        return true
    }
    

    
}