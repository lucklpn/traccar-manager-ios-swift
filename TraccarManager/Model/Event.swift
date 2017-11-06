//
//  Event.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 03.11.2017.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//

import Foundation

struct Event: Codable {
    let id : Int?
    let deviceId : Int?
    let type : String?
    let serverTime : Date?
    let positionId : Int?
    let geofenceId : Int?
}

extension Event {
    var geofence: Geofence {
        get {
            return WebService.sharedInstance.geofenceById(geofenceId!)!
        }
    }
    
    func valueString(forKey: String) -> String {
        switch forKey.localizedLowercase {
        case "id": return String(self.id!)
        case "deviceId": return String(self.deviceId!)
        case "type":
            switch self.type! {
            case "deviceOnline": return "Device is online"
            case "deviceMoving": return "Device is moving"
            case "deviceStopped": return "Device has stopped"
            case "deviceUnknown": return "Device status is unknown"
            default: return self.type!
            }
        case "servertime":
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy HH:mm:ss"
            return dateFormatter.string(from: self.serverTime!)
        case "time":
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy HH:mm:ss"
            return dateFormatter.string(from: self.serverTime!)
        case "positionid": return String(self.positionId!)
        case "geofenceid": return String(self.geofenceId!)
        case "geofence":
            if let g = WebService.sharedInstance.geofenceById(geofenceId!) {
                return g.description!
            } else {
                return ""
            }
        case "devicename":
            if let d = WebService.sharedInstance.deviceById(deviceId!) {
                return d.name!
            } else {
                return ""
            }
        default: fatalError("Invalid key")
        }
    }
}

