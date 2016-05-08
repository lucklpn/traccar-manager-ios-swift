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
    
    // url for the server, has a trailing slash
    var serverURL: String?
    
    private var socket: SRWebSocket?
    
    private var allDevices: [Device]?
    
    private var allPositions: [Position]?
    
// MARK: websocket
    
    private func enableWebSocket() {
        socket = SRWebSocket(URL: NSURL(string: serverURL! + "socket"))
        socket?.requestCookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: serverURL!)!)
        socket?.delegate = self
    }
    
    private func disableWebSocket() {
        if let s = socket {
            s.close()
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        
    }
  
// MARK: fetch
    
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
                        
                        self.allDevices = devices
                        
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
                        
                        self.allPositions = positions
                        
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
    
    // utility function to get a position by ID
    func positionByDeviceId(deviceId: NSNumber) -> Position? {
        if let positions = allPositions {
            for p in positions {
                if p.deviceId == deviceId {
                    return p
                }
            }
        }
        return nil
    }
    
    // utility function to get a device by ID
    func deviceById(id: NSNumber) -> Device? {
        if let devices = allDevices {
            for d in devices {
                if d.id == id {
                    return d
                }
            }
        }
        return nil
    }
    
// MARK: auth
    
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
                        self.enableWebSocket()
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