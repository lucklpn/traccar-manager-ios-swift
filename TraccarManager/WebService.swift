//
//  WebService.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 03.11.2017.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//  Copyright 2016 Anton Tananaev (anton.tananaev@gmail.com)
//  Copyright 2016 William Pearse (w.pearse@gmail.com)
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
    
    fileprivate var allGeofences: NSMutableDictionary = NSMutableDictionary()
    
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
    
    var geofence: [Geofence] {
        get {
            return allGeofences.allValues as! [Geofence]
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
            
            allPositions.setValue(pp, forKey: String(pp.deviceId!))
        }
        
        // tell everyone that the positions have been updated
        NotificationCenter.default.post(name: Notification.Name(rawValue: Definitions.PositionUpdateNotificationName), object: nil)
    }
    
    // utility function to get a position by device ID
    func positionByDeviceId(_ deviceId: Int) -> Position? {
        if let p = allPositions[String(deviceId)] {
            return p as? Position
        }
        return nil
    }
    
    // utility function to get a geofence by geofence ID
    func geofenceById(_ geofinceId: Int) -> Geofence? {
        if let g = allGeofences[String(geofinceId)] {
            return g as? Geofence
        }
        return nil
    }
    
    // utility function to get a device by ID
    func deviceById(_ id: Int) -> Device? {
        if let d = allDevices[String(id)] {
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
    
    func fetchDevices(_ onFailure: ((String) -> Void)? = nil, onSuccess: @escaping ([Device]) -> Void) {

        WebService.sharedInstance.getDataServer(filter: "", urlPoint: "devices", onFailure: { errorString in

            if let fail = onFailure {
                fail(errorString)
            }

        }, onSuccess: { (data) in

            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let ds: [Device] = try! decoder.decode([Device].self, from: data)
            for d in ds {
                self.allDevices.setValue(d, forKey: String(d.id!))
            }
            
            // tell everyone that the devices have been updated
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Definitions.DeviceUpdateNotificationName), object: nil)
            
            onSuccess(ds)

        })

    }
    
    func fetchGeofences(_ onFailure: ((String) -> Void)? = nil, onSuccess: @escaping ([Geofence]) -> Void) {
        
        WebService.sharedInstance.getDataServer(filter: "", urlPoint: "geofences", onFailure: { errorString in
            
            if let fail = onFailure {
                fail(errorString)
            }
            
        }, onSuccess: { (data) in
            let decoder = JSONDecoder()
            let gs: [Geofence] = try! decoder.decode([Geofence].self, from: data)
            for g in gs {
                self.allGeofences.setValue(g, forKey: String(g.id!))
            }
            
            // tell everyone that the devices have been updated
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Definitions.DeviceUpdateNotificationName), object: nil)
            
            onSuccess(gs)
            
        })
        
    }
    
    func getDataServer (filter: String, urlPoint: String, onFailure: ((String) -> Void)? = nil, onSuccess: @escaping (Data) -> Void) {
        
        let url = serverURL! + "api/" + urlPoint + filter
        
        WebService.Manager.request(url).responseString(encoding: .utf8, completionHandler: { response in
            
            switch response.result {
                
                case .success(let res):
                    if response.response!.statusCode != 200 {
                        if let fail = onFailure {
                            fail("Error " + String(response.response!.statusCode))
                        }
                    } else {
                        onSuccess(res.data(using: .utf8)!)
                    }
                case .failure(let error):
                    if let fail = onFailure {
                        fail(error.localizedDescription)
                    }
            }

        })
        
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
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Accept"] = "application/json"
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
        let manager = Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        
        return manager
    }()
    
}

