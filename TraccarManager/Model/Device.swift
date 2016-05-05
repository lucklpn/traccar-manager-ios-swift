//
//  Device.swift
//  TraccarManager
//
//  Created by William Pearse on 5/05/16.
//  Copyright © 2016 Anton Tananaev. All rights reserved.
//

import Foundation

class Device: NSObject {

    var id: NSNumber?
    var uniqueId: String?
    var groupId: NSNumber?
    var lastUpdate: NSDate?
    var positionId: NSNumber?
    var status: String?
    var name: String?
    
    
    // implemented so we don't crash if the model changes
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        print("Tried to set property '\(key)' that doesn't exist on the model")
    }
    
}