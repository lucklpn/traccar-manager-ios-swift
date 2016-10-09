//
// Copyright 2016 William Pearse (w.pearse@gmail.com)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
    
    // outdated is reserved
    var isOutdated: Bool?
    
    // valid is reserved
    var isValid: Bool?
    
    var serverTime: Date?
    var deviceTime: Date?
    var fixTime: Date?
    
    var device: Device? {
        get {
            return WebService.sharedInstance.deviceById(deviceId!)
        }
    }
    
    // logic derived from public domain code by Martin R, copied on 9 May 2016
    // http://stackoverflow.com/a/13220694/336419
    static let compassDirections = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
    "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
    
    // returns the course of this position as a compass direction
    var courseDirectionString : String? {
        get {
            if let c = course {
                let idx = ((c.doubleValue + 11.25) / 22.5).truncatingRemainder(dividingBy: 16)
                return "\(Position.compassDirections[Int(idx)]), \(c.intValue) º"
            }
            return nil
        }
    }
    
    var speedString: String? {
        get {
            if let s = speed {
                
                // format speed to 1 dp
                let speedFormatter = NumberFormatter()
                speedFormatter.numberStyle = .decimal
                speedFormatter.maximumFractionDigits = 1
                let formattedSpeed = speedFormatter.string(from: s)
                if let fs = formattedSpeed {
                    if let u = User.sharedInstance.speedUnit {
                        return "\(fs) \(u)"
                    } else {
                        return fs
                    }
                }
            }
            return nil
        }
    }
    
    // used to format the latitude and longitudes to 5 dp (fixed),
    // this gives about 10cm resolution and is plenty
    fileprivate var latLonFormatter: NumberFormatter
    
    var latitudeString: String? {
        get {
            if let l = latitude {
                return latLonFormatter.string(from: l)
            }
            return nil
        }
    }
    
    var longitudeString: String? {
        get {
            if let l = longitude {
                return latLonFormatter.string(from: l)
            }
            return nil
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        guard let lat = latitude else {
            return kCLLocationCoordinate2DInvalid
        }
        guard let lon = longitude else {
            return kCLLocationCoordinate2DInvalid
        }
        return CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue)
    }
    
    var annotationTitle: String {
        get {
            if let d = device {
                return d.name!
            }
            return "Device \(deviceId!.int32Value)"
        }
    }
    
    var annotationSubtitle: String {
        get {
            if let a = address {
                return a as String
            }
            return ""
        }
    }
    
    override init() {
        self.latLonFormatter = NumberFormatter()
        self.latLonFormatter.numberStyle = .decimal
        self.latLonFormatter.minimumFractionDigits = 5
        
        super.init()
    }
    
    // implemented so we don't crash if the model changes
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        print("Tried to set property '\(key)' that doesn't exist on the Position model")
    }
    
    override func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "protocol" {
            self.positionProtocol = value as? String
        } else if key == "type" {
            self.positionType = value as? String
        } else if key == "valid" {
            self.isValid = value as? Bool
        } else if key == "outdated" {
            self.isOutdated = value as? Bool
        } else if key == "serverTime" {
            if let v = value as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
                self.serverTime = dateFormatter.date(from: v)
            }
        } else if key == "deviceTime" {
            if let v = value as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
                self.deviceTime = dateFormatter.date(from: v)
            }
        } else if key == "fixTime" {
            if let v = value as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
                self.fixTime = dateFormatter.date(from: v)
            }
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
}
