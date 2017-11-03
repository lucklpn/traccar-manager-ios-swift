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
import SwiftyJSON

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
        
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        
        socket = SRWebSocket(urlRequest: request as URLRequest, protocols: nil, allowsUntrustedSSLCertificates: true)
      
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
        //let url = serverURL! + "api/reports/summary"
        
        WebService.Manager.request(url).responseJSON(completionHandler: { response in
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

    func authenticate(_ serverURL: String, email: String, password: String, onFailure: ((NSError) -> Void)? = nil, onSuccess: @escaping (User) -> Void) {
		
        // clear any devices/positions from the previous session
        allPositions = NSMutableDictionary()
        allDevices = NSMutableDictionary()

        guard (serverURL.lowercased().hasPrefix("http://") || serverURL.lowercased().hasPrefix("https://")) else {
            if let fail = onFailure {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Server URL must begin with either http:// or https://"])
                fail(error)
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
        
        WebService.Manager.request(url, method: .post, parameters: parameters).responseJSON(completionHandler: { response in
            switch response.result {
                
            case .success(let JSON):
                if response.response!.statusCode != 200 {
                    if let fail = onFailure {
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid email and/or password"])
                        fail(error)
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
                            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Server response was invalid"])
                            fail(error)
                        }
                    }
                }
                
            case .failure(let error):
                if let fail = onFailure {
                    fail(error as NSError)
                }
            }
        })
    }
    
    func getSummaryData(filter: String, urlPoint: String, onFailure: ((String) -> Void)? = nil, onSuccess: @escaping ([Summary]) -> Void) {
        
        let d = UserDefaults.standard
        //let s = d.string(forKey: TCDefaultsServerKey)
        let e = d.string(forKey: TCDefaultsEmailKey)
        let p = KeychainWrapper.standard.string(forKey: TCDefaultsPassKey)
        
        //serverURL = s
        var url = serverURL
        if !(serverURL?.hasSuffix("/"))! {
            url = url! + "/"
        }
        
        self.serverURL = url
        
        url = url! + "api/reports/summary" + filter //urlPoint
        
        let UserPass = (e! + ":" + p!).data(using: String.Encoding.utf8)!.base64EncodedString()
        let auth = "Basic \(UserPass)"
        
        let urls = URL(string: url!)
        
        var request = URLRequest(url: urls!)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        
        WebService.Manager.request(request).responseArray(Summary.self) { response in
            switch response.result {
                
            case .success(let model):
                if response.response!.statusCode != 200 {
                    if let fail = onFailure {
                        fail("Unknown error")
                    }
                } else {
                    let u = model
                    onSuccess(u)
                }
                
            case .failure(let error):
                if let fail = onFailure {
                    fail(error.localizedDescription)
                }
            }
        }
        
    }
    
    private static var Manager: Alamofire.SessionManager = {
        
        // Create the server trust policies
        var domainTrust = ""
        let d = UserDefaults.standard
        if let s = d.string(forKey: Definitions.TCDefaultsTrustDomain) {
            domainTrust =  s
        }
        
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            domainTrust: .disableEvaluation
        ]
        
        // Create custom manager
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let manager = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        
        return manager
    }()
    
}
