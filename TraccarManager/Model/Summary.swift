//
//  Summary.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 30.09.2017.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//

import Foundation
import Gloss

//MARK: - modelFilter
public struct Summary: Gloss.Decodable {
    
    public let deviceId : Int?
    public let deviceName : String?
    public let distance : Double?
    public let averageSpeed : Double?
    public let maxSpeed : Double?
    public let engineHours : Int?
    
    //MARK: Decodable
    public init?(json: JSON){
        deviceId = "deviceId" <~~ json
        deviceName = "deviceName" <~~ json
        distance = "distance" <~~ json
        averageSpeed = "averageSpeed" <~~ json
        maxSpeed = "maxSpeed" <~~ json
        engineHours = "engineHours" <~~ json
    }
}
