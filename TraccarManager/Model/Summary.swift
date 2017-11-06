//
//  Summary.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 30.09.2017.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//

import Foundation

public struct Summary: Codable {
    
    public let deviceId : Int?
    public let deviceName : String?
    public let distance : Double?
    public let averageSpeed : Double?
    public let maxSpeed : Double?
    public let engineHours : Int?
    
}

extension Summary {
    
    func valueString(forKey: String) -> String {
        switch forKey.localizedLowercase {
            case "deviceid": return String(self.deviceId!)
            case "devicename": return self.deviceName!
            case "distance": return formatNumber.sharedInstance.string(from: NSNumber(value: Int(self.distance! / 1000)))!
            case "averagespeed": return formatNumber.sharedInstance.string(from: NSNumber(value: Int(self.averageSpeed! * 1.852)))!
            case "maxspeed": return formatNumber.sharedInstance.string(from: NSNumber(value: Int(self.maxSpeed! * 1.852)))!
            case "enginehours": return formatNumber.sharedInstance.string(from: NSNumber(value: self.engineHours!))!
            default: fatalError("Invalid key")
        }
    }
}
