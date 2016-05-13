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

import Foundation
import Alamofire
import SocketRocket

class WebService: NSObject, SRWebSocketDelegate {
    
    static let sharedInstance = WebService()
    
    // url for the server, has a trailing slash
    var serverURL: String?
    
    private var socket: SRWebSocket?
    
    // map of device id (string) -> device
    private var allDevices: NSMutableDictionary = NSMutableDictionary()
    
    // map of device id (string) -> position
    //
    // this provides an easy way of maintaining only the most-recent position
    // for each device
    private var allPositions: NSMutableDictionary = NSMutableDictionary()
    
    var positions: [Position] {
        get {
            return allPositions.allValues as! [Position]
        }
    }
    
    var devices: [Device] {
        get {
            return allDevices.allValues as! [Device]
        }
    }
    
// MARK: websocket
    
    func disconnectWebSocket() {
        // close and tidy if we already had a socket
        if let s = socket {
            s.close()
            s.delegate = nil
            socket = nil
        }
    }
    
    func reconnectWebSocket() {
        
        disconnectWebSocket()
        
        // if the server URL hasn't been set, there's no point continuing
        guard serverURL != nil else {
            return
        }
        
        let urlString = "\(serverURL!)api/socket"
        
        socket = SRWebSocket(URL: NSURL(string: urlString))
        if let s = socket {
            let cookiePath = "\(serverURL!)api"
            s.requestCookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: cookiePath)!)
            s.delegate = self
            s.open()
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        reconnectWebSocket()
    }
    

    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        if let s = message as? String {
            if let data = s.dataUsingEncoding(NSUTF8StringEncoding) {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                        
                    if let p = json["positions"] as? [[String: AnyObject]] {
                        parsePositionData(p)
                    }
                }
                catch {
                    print("error parsing JSON")
                }
            }
        }
    }

  
// MARK: fetch
    
    private func parsePositionData(data: [[String : AnyObject]]) -> [Position] {
        
        var positions = [Position]()
        
        for p in data {
            let pp = Position()
            pp.setValuesForKeysWithDictionary(p)
            positions.append(pp)
            
            allPositions.setValue(pp, forKey: (pp.deviceId?.stringValue)!)
        }
        
        // tell everyone that the positions have been updated
        NSNotificationCenter.defaultCenter().postNotificationName(Definitions.PositionUpdateNotificationName, object: nil)

        return positions
    }
    
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
                            
                            self.allDevices.setValue(dd, forKey: (dd.id?.stringValue)!)
                        }
                        
                        // tell everyone that the devices have been updated
                        NSNotificationCenter.defaultCenter().postNotificationName(Definitions.DeviceUpdateNotificationName, object: nil)
                        
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
                        
                        let positions = self.parsePositionData(data)
                        
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
    
    // utility function to get a position by device ID
    func positionByDeviceId(deviceId: NSNumber) -> Position? {
        if let p = allPositions[deviceId.stringValue] {
            return p as? Position
        }
        return nil
    }
    
    // utility function to get a device by ID
    func deviceById(id: NSNumber) -> Device? {
        if let d = allDevices[id.stringValue] {
            return d as? Device
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
                        
                        self.reconnectWebSocket()
                        
                        // tell everyone that the user has logged in
                        NSNotificationCenter.defaultCenter().postNotificationName(Definitions.LoginStatusChangedNotificationName, object: nil)
                        
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