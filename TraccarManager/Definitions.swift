//
//  Definitions.swift
//  TraccarManager
//
//  Created by William Pearse on 11/05/16.
//  Copyright © 2016 Anton Tananaev. All rights reserved.
//

import UIKit

class Definitions {
    
    static let DeviceUpdateNotificationName = "DeviceUpdateNotificationName"
    
    static let PositionUpdateNotificationName = "PositionUpdateNotificationName"
    
    static let LoginStatusChangedNotificationName = "LoginStatusChangedNotificationName"
    
    static var isRunningOniPad: Bool {
        get {
            return UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
        }
    }
    
}
