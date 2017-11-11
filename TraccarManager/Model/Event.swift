//
//  Event.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 03.11.2017.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//

import Foundation

struct Event: Decodable {
    let id: Int?
    let deviceId: Int?
    let type: String?
    let serverTime: Date?
    let positionId: Int?
    let geofenceId: Int?
    let attributes: AttributeObject?
    
}

struct AttributeObject: Decodable {
    var AttributeName: [String]
    var AttributeValue: [String]
    
    private struct CodingKeys: CodingKey {
        var intValue: Int?
        var stringValue: String
        
        init?(intValue: Int) { self.intValue = intValue; self.stringValue = "" }
        init?(stringValue: String) { self.stringValue = stringValue }
    }
    
    init(from decoder: Decoder) throws {
        self.AttributeName = [String]()
        self.AttributeValue = [String]()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        for key in container.allKeys {
            self.AttributeName.append(key.stringValue)
            if let value = try? container.decode(String.self, forKey: key) {
                self.AttributeValue.append(value)
            } else if let value = try? container.decode(Double.self, forKey: key) {
                var valueUnit = value
                if key.stringValue.lowercased().contains("speed") {
                    valueUnit = value * 1.852
                } else if key.stringValue.lowercased().contains("distance") {
                    valueUnit = value / 1000
                }
                self.AttributeValue.append(valueUnit.stringFormat(round: 1))
            } else {
                self.AttributeValue.append("")
            }
        }
    }
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
            case "deviceOverspeed": return "Device exceeds the speed"
            case "geofenceExit": return "Device has exited geofence"
            case "geofenceEnter": return "Device has entered geofence"
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
                return g.name! + " " + g.description!
            } else {
                return ""
            }
        case "devicename":
            if let d = WebService.sharedInstance.deviceById(deviceId!) {
                return d.name!
            } else {
                return ""
            }
        case "attributes":
            var desc = ""
            let countattr = (attributes?.AttributeName.count)! - 1
            if countattr > 0 {
                for i in 0...countattr {
                    desc += " "
                        + (attributes?.AttributeName[i])! + " = "
                        + (attributes?.AttributeValue[i])!
                }
            }
            return desc
        default: fatalError("Invalid key")
        }
    }
}

