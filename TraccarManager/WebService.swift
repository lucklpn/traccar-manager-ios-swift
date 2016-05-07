//
//  WebService.swift
//  TraccarManager
//
//  Created by William Pearse on 4/05/16.
//  Copyright © 2016 Anton Tananaev. All rights reserved.
//

import Foundation
import Alamofire

class WebService {
    
    static let sharedInstance = WebService()
    
    // url for the server, has a trailing slash
    var serverURL: String?
    
    func fetchDevices(onFailure: ((String) -> Void)? = nil, onSuccess: ([Device]) -> Void) -> Bool {
        guard serverURL != nil else {
            return false
        }
        
        let url = serverURL! + "api/devices"
        
        Alamofire.request(.GET, url).responseJSON(completionHandler: { response in
            switch response.result {
                
            case .Success(let JSON):
                if response.response!.statusCode != 200 {
                    if let fail = onFailure {
                        fail("Invalid server response")
                    }
                } else {
                    if let data = JSON as? [[String : AnyObject]] {
                        
                        var devices = [Device]()
                        
                        for d in data {
                            let dd = Device()
                            dd.setValuesForKeysWithDictionary(d)
                            devices.append(dd)
                        }
                        
                        onSuccess(devices)
                        
                    } else {
                        if let fail = onFailure {
                            fail("Server response was invalid")
                        }
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
    
    func fetchPositions(onFailure: ((String) -> Void)? = nil, onSuccess: ([Position]) -> Void) -> Bool {
        guard serverURL != nil else {
            return false
        }
        
        let url = serverURL! + "api/positions"
        
        Alamofire.request(.GET, url).responseJSON(completionHandler: { response in
            switch response.result {
                
            case .Success(let JSON):
                if response.response!.statusCode != 200 {
                    if let fail = onFailure {
                        fail("Invalid server response")
                    }
                } else {
                    if let data = JSON as? [[String : AnyObject]] {
                        
                        var positions = [Position]()
                        
                        for p in data {
                            let pp = Position()
                            pp.setValuesForKeysWithDictionary(p)
                            positions.append(pp)
                        }
                        
                        onSuccess(positions)
                        
                    } else {
                        if let fail = onFailure {
                            fail("Server response was invalid")
                        }
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

    
    func authenticate(serverURL: String, email: String, password: String, onFailure: ((String) -> Void)? = nil, onSuccess: (User) -> Void) -> Bool {
        
        guard (serverURL.lowercaseString.hasPrefix("http://") || serverURL.lowercaseString.hasPrefix("https://")) else {
            if let fail = onFailure {
                fail("Server URL must begin with either http:// or https://")
            }
            return false
        }
        
        var url = serverURL
        if !serverURL.hasSuffix("/") {
            url = url + "/"
        }
        
        self.serverURL = url
        
        url = url + "api/session"
        
        let parameters = [
            "email" : email,
            "password": password
        ]
        
        Alamofire.request(.POST, url, parameters: parameters).responseJSON(completionHandler: { response in
            switch response.result {
                
            case .Success(let JSON):
                if response.response!.statusCode != 200 {
                    if let fail = onFailure {
                        fail("Invalid email and/or password")
                    }
                } else {
                    if let data = JSON as? [String : AnyObject] {
                        let u = User.sharedInstance
                        u.setValuesForKeysWithDictionary(data)
                        onSuccess(u)
                    } else {
                        if let fail = onFailure {
                            fail("Server response was invalid")
                        }
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
    
    
    static func authenticate(serverURL: String, email: String, password: String, onFailure: ((String) -> Void)? = nil, onSuccess: (User) -> Void) -> Bool {
        
        guard (serverURL.lowercaseString.hasPrefix("http://") || serverURL.lowercaseString.hasPrefix("https://")) else {
            if let fail = onFailure {
                fail("Server URL must begin with either http:// or https://")
            }
            return false
        }
        
        var url = serverURL
        if !serverURL.hasSuffix("/") {
            url = url + "/"
        }
        
        url = url + "api/session"
        
        let parameters = [
            "email" : email,
            "password": password
        ]
        
        Alamofire.request(.POST, url, parameters: parameters).responseJSON(completionHandler: { response in
                switch response.result {
                    
                case .Success(let JSON):
                    if response.response!.statusCode != 200 {
                        if let fail = onFailure {
                            fail("Invalid email and/or password")
                        }
                    } else {
                        if let data = JSON as? [String : AnyObject] {
                            let u = User.sharedInstance
                            u.setValuesForKeysWithDictionary(data)
                            onSuccess(u)
                        } else {
                            if let fail = onFailure {
                                fail("Server response was invalid")
                            }
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