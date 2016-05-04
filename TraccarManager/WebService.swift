//
//  WebService.swift
//  TraccarManager
//
//  Created by William Pearse on 4/05/16.
//  Copyright © 2016 Anton Tananaev. All rights reserved.
//

import Foundation
import Alamofire
import SocketRocket

class WebService: NSObject, SRWebSocketDelegate {
    
    static let sharedInstance = WebService()
    
    private var socket: SRWebSocket?
    
    // ends with a "/"
    private var serviceUrl: String?
    
    private func enableWebSocket() {
        socket = SRWebSocket(URL: NSURL(string: serviceUrl! + "socket"))
        socket?.requestCookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: serviceUrl!)!)
        socket?.delegate = self
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        // required for SRWebSocketDelegate
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
        
        serviceUrl = url
        
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