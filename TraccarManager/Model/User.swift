//
//  User.swift
//  TraccarManager
//
//  Created by William Pearse on 4/05/16.
//  Copyright © 2016 Anton Tananaev. All rights reserved.
//

import Foundation
import CoreLocation

class User: NSObject {
    
    static let sharedInstance = User()
    
    var admin: NSNumber?
    var distanceUnit: String?
    var email: String?
    var id: NSNumber?
    var latitude: NSNumber?
    var longitude: NSNumber?
    var map: String?
    var name: String?
    var readonly: NSNumber?
    var speedUnit: String?
    var twelveHourFormat: NSNumber?
    var zoom: NSNumber?
    
    var mapCenter: CLLocationCoordinate2D {
        guard let lat = latitude else {
            return kCLLocationCoordinate2DInvalid
        }
        guard let lon = longitude else {
            return kCLLocationCoordinate2DInvalid
        }
        return CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue)
    }
    
    var isAuthenticated: Bool {
        // TODO: this really isn't a good test
        return email != nil
    }
    
    func logout() {
        NSHTTPCookieStorage.sharedHTTPCookieStorage().removeCookiesSinceDate(NSDate(timeIntervalSinceReferenceDate: 0))
        email = nil
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        // ignore the password, we don't care about it
        if key != "password" {
            print("Tried to set property '\(key)' that doesn't exist on the model")
        }
    }
    
}