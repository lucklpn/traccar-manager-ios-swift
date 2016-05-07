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
    
    override func setValue(value: AnyObject?, forKey key: String) {
        if key == "lastUpdate" {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
            self.lastUpdate = dateFormatter.dateFromString(value as! String)
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
    // returns the time of this device's last update time, as a relative
    // string... something like "about 1 minute ago"
    var lastUpdateString: String {
        get {
            let formatter = NSDateComponentsFormatter()
            formatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Full
            formatter.includesApproximationPhrase = true
            formatter.includesTimeRemainingPhrase = false
            formatter.allowedUnits = [.Year, .Month, .WeekOfMonth, .Day, .Hour, .Minute, .Second]
            formatter.maximumUnitCount = 1
            
            if let dateRelativeString = formatter.stringFromDate(lastUpdate!, toDate: NSDate()) {
                return dateRelativeString
            }
            return ""
        }
    }
    
}