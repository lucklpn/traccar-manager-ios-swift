//
//  Deviced.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 04.11.2017.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//

import Foundation

struct Device: Codable {
    let id: Int?
    let name: String?
    let uniqueId: String?
    let status: String?
    let lastUpdate: Date?
    let positionId: Int?
    let groupId: Int?
    let phone: String?
    let model: String?
    let contact: String?
    let category: String?
    let geofenceIds: [Int]?
}

extension Device {
    var position: Position {
        get {
            return WebService.sharedInstance.positionByDeviceId(id!)!
        }
    }
    
    var mostRecentPositionTimeString: String {
        get {
            if let p = WebService.sharedInstance.positionByDeviceId(self.id!) {
                if let dt = p.deviceTime {
                    
                    let timeDateRelativeFormatter = DateComponentsFormatter()
                    timeDateRelativeFormatter.unitsStyle = DateComponentsFormatter.UnitsStyle.full
                    timeDateRelativeFormatter.includesApproximationPhrase = true
                    timeDateRelativeFormatter.includesTimeRemainingPhrase = false
                    timeDateRelativeFormatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
                    timeDateRelativeFormatter.maximumUnitCount = 1
                    
                    if let dateRelativeString = timeDateRelativeFormatter.string(from: dt, to: Date()) {
                        return dateRelativeString
                    }
                }
            }
            return ""
        }
    }
    
    func valueString(forKey: String) -> String {
        switch forKey.localizedLowercase {
            case "id": return String(self.id!)
            case "uniqueId": return self.uniqueId!
            case "groupId": return String(self.groupId!)
            case "lastUpdate":
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yy HH:mm:ss"
                return dateFormatter.string(from: self.lastUpdate!)
            case "time":
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yy HH:mm:ss"
                return dateFormatter.string(from: self.lastUpdate!)
            case "positionId": return String(self.positionId!)
            case "status": return self.status!.capitalized
            case "name": return self.name!
            case "category": return self.category!
            case "phone": return self.phone!
            case "model": return self.model!
            case "contact": return self.contact!
        default: fatalError("Invalid key")
        }
    }
}



