//
//  Position.swift
//  TraccarManager
//
//  Created by William Pearse on 7/05/16.
//  Copyright © 2016 Anton Tananaev. All rights reserved.
//

import Foundation
import CoreLocation

/*
 
 TODO: Position attributes?
 
    {
     "status": "00000000",
     "charge": true,
     "ignition": false,
     "odometer": 0,
     "ip": "118.148.169.48"
    }
 
*/

class Position: NSObject {
    
    var id: NSNumber?
    var deviceId: NSNumber?
    
    var attributes: [String : AnyObject]?
    
    // protocol is reserved
    var positionProtocol: String?
    
    // type is reserved
    var positionType: String?
    
    var latitude: NSNumber?
    var longitude: NSNumber?
    var speed: NSNumber?
    var course: NSNumber?
    var address: NSString?
    var altitude: NSNumber?
    
    var outdated: Bool?
    var valid: Bool?
    
    var serverTime: NSDate?
    var deviceTime: NSDate?
    var fixTime: NSDate?
    
    var coordinate: CLLocationCoordinate2D {
        guard let lat = latitude else {
            return kCLLocationCoordinate2DInvalid
        }
        guard let lon = longitude else {
            return kCLLocationCoordinate2DInvalid
        }
        return CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue)
    }
    
    var title: String {
        get {
            // todo: show device name?
            return address! as String
        }
    }
    
    // implemented so we don't crash if the model changes
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        print("Tried to set property '\(key)' that doesn't exist on the model")
    }
    
    override func setValue(value: AnyObject?, forKey key: String) {
        if key == "protocol" {
            self.positionProtocol = value as? String
        } else if key == "type" {
            self.positionType = value as? String
        } else if key == "serverTime" {
            if value != nil {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
                self.serverTime = dateFormatter.dateFromString(value as! String)
            }
        } else if key == "deviceTime" {
            if value != nil {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
                self.deviceTime = dateFormatter.dateFromString(value as! String)
            }
        } else if key == "fixTime" {
            if value != nil {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
                self.fixTime = dateFormatter.dateFromString(value as! String)
            }
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
}
