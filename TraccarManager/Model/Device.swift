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
    
    var timeDateRelativeFormatter: NSDateComponentsFormatter
    
    
    override init() {
        
        timeDateRelativeFormatter = NSDateComponentsFormatter()
        timeDateRelativeFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Full
        timeDateRelativeFormatter.includesApproximationPhrase = true
        timeDateRelativeFormatter.includesTimeRemainingPhrase = false
        timeDateRelativeFormatter.allowedUnits = [.Year, .Month, .WeekOfMonth, .Day, .Hour, .Minute, .Second]
        timeDateRelativeFormatter.maximumUnitCount = 1
        
        super.init()
    }
    
    
    // implemented so we don't crash if the model changes
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        print("Tried to set property '\(key)' that doesn't exist on the Device model")
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
    
    var position: Position? {
        get {
            return WebService.sharedInstance.positionByDeviceId(id!)
        }
    }
    
    var statusString: String? {
        get {
            if let s = status {
                return s.capitalizedString
            }
            return nil
        }
    }
    
    // returns the time of this device's last update time, as a relative
    // string... something like "about 1 minute ago"
    var lastUpdateString: String {
        get {
            if let dateRelativeString = timeDateRelativeFormatter.stringFromDate(lastUpdate!, toDate: NSDate()) {
                return dateRelativeString
            }
            return ""
        }
    }
    
    var mostRecentPositionTimeString: String {
        get {
            if let p = WebService.sharedInstance.positionByDeviceId(self.id!) {
                if let dt = p.deviceTime {
                    if let dateRelativeString = timeDateRelativeFormatter.stringFromDate(dt, toDate: NSDate()) {
                        return dateRelativeString
                    }
                }
            }
            return ""
        }
    }
    
}