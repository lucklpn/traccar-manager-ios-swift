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
    
    fileprivate var socket: SRWebSocket?
    
    // map of device id (string) -> device
    fileprivate var allDevices: NSMutableDictionary = NSMutableDictionary()
    
    // map of device id (string) -> position
    //
    // this provides an easy way of maintaining only the most-recent position
    // for each device
    fileprivate var allPositions: NSMutableDictionary = NSMutableDictionary()
    
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
        
        socket = SRWebSocket(url: URL(string: urlString)!)
        if let s = socket {
            let cookiePath = "\(serverURL!)api"
            s.requestCookies = HTTPCookieStorage.shared.cookies(for: URL(string: cookiePath)!)
            s.delegate = self
            s.open()
        }
    }
    
    func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
        reconnectWebSocket()
    }
    

    func webSocket(_ webSocket: SRWebSocket, didReceiveMessageWith string: String) {
        if let data = string.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                
                if let p = json["positions"] as? [[String: AnyObject]] {
                    parsePositionData(p)
                }
            }
            catch {
                print("error parsing JSON")
            }
        }
    }

  
// MARK: fetch
    
    fileprivate func parsePositionData(_ data: [[String : AnyObject]]) {
        
        var positions = [Position]()
        
        for p in data {
            let pp = Position()
            pp.setValuesForKeys(p)
            positions.append(pp)
            
            allPositions.setValue(pp, forKey: (pp.deviceId?.stringValue)!)
        }
        
        // tell everyone that the positions have been updated
        NotificationCenter.default.post(name: Notification.Name(rawValue: Definitions.PositionUpdateNotificationName), object: nil)
    }
    
    func fetchDevices(_ onFailure: ((String) -> Void)? = nil, onSuccess: @escaping ([Device]) -> Void) {
        guard serverURL != nil else {
            return
        }
        
        let url = serverURL! + "api/devices"
        
        Alamofire.request(url).responseJSON(completionHandler: { response in
            switch response.result {
                
            case .success(let JSON):
                if response.response!.statusCode != 200 {
                    if let fail = onFailure {
                        fail("Invalid server response")
                    }
                } else {
                    
                    if let data = JSON as? [[String : AnyObject]] {
                        
                        var devices = [Device]()
                        
                        for d in data {
                            let dd = Device()
                            dd.setValuesForKeys(d)
                            devices.append(dd)
                            
                            self.allDevices.setValue(dd, forKey: (dd.id?.stringValue)!)
                        }
                        
                        // tell everyone that the devices have been updated
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Definitions.DeviceUpdateNotificationName), object: nil)
                        
                        onSuccess(devices)
                        
                    } else {
                        if let fail = onFailure {
                            fail("Server response was invalid")
                        }
                    }
                }
                
            case .failure(let error):
                if let fail = onFailure {
                    fail(error.localizedDescription)
                }
            }
        })
    }
    
    // utility function to get a position by device ID
    func positionByDeviceId(_ deviceId: NSNumber) -> Position? {
        if let p = allPositions[deviceId.stringValue] {
            return p as? Position
        }
        return nil
    }
    
    // utility function to get a device by ID
    func deviceById(_ id: NSNumber) -> Device? {
        if let d = allDevices[id.stringValue] {
            return d as? Device
        }
        return nil
    }
    
// MARK: auth
    
    func authenticate(_ serverURL: String, email: String, password: String, onFailure: ((String) -> Void)? = nil, onSuccess: @escaping (User) -> Void) {
		
        // clear any devices/positions from the previous session
        allPositions = NSMutableDictionary()
        allDevices = NSMutableDictionary()
		
        guard (serverURL.lowercased().hasPrefix("http://") || serverURL.lowercased().hasPrefix("https://")) else {
            if let fail = onFailure {
                fail("Server URL must begin with either http:// or https://")
            }
            return
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
        
        Alamofire.request(url, method: .post, parameters: parameters).responseJSON(completionHandler: { response in
            switch response.result {
                
            case .success(let JSON):
                if response.response!.statusCode != 200 {
                    if let fail = onFailure {
                        fail("Invalid email and/or password")
                    }
                } else {
            
                    if let data = JSON as? [String : AnyObject] {
                        let u = User.sharedInstance
                        u.setValuesForKeys(data)
                        
                        self.reconnectWebSocket()
                        
                        // tell everyone that the user has logged in
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Definitions.LoginStatusChangedNotificationName), object: nil)
                        
                        onSuccess(u)
                    } else {
                        if let fail = onFailure {
                            fail("Server response was invalid")
                        }
                    }
                }
                
            case .failure(let error):
                if let fail = onFailure {
                    fail(error.localizedDescription)
                }
            }
        })
    }
    
}
