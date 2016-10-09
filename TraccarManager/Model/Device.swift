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

class Device: NSObject {

    var id: NSNumber?
    var uniqueId: String?
    var groupId: NSNumber?
    var lastUpdate: Date?
    var positionId: NSNumber?
    var status: String?
    var name: String?
    
    var timeDateRelativeFormatter: DateComponentsFormatter
    
    override init() {
        
        timeDateRelativeFormatter = DateComponentsFormatter()
        timeDateRelativeFormatter.unitsStyle = DateComponentsFormatter.UnitsStyle.full
        timeDateRelativeFormatter.includesApproximationPhrase = true
        timeDateRelativeFormatter.includesTimeRemainingPhrase = false
        timeDateRelativeFormatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        timeDateRelativeFormatter.maximumUnitCount = 1
        
        super.init()
    }
    
    
    // implemented so we don't crash if the model changes
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        print("Tried to set property '\(key)' that doesn't exist on the Device model")
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "lastUpdate" {
            if let v = value as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
                self.lastUpdate = dateFormatter.date(from: v)
            } else {
                self.lastUpdate = nil
            }
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
                return s.capitalized
            }
            return nil
        }
    }
    
    // returns the time of this device's last update time, as a relative
    // string... something like "about 1 minute ago"
    var lastUpdateString: String {
        get {
            if let dateRelativeString = timeDateRelativeFormatter.string(from: lastUpdate!, to: Date()) {
                return dateRelativeString
            }
            return ""
        }
    }
    
    var mostRecentPositionTimeString: String {
        get {
            if let p = WebService.sharedInstance.positionByDeviceId(self.id!) {
                if let dt = p.deviceTime {
                    if let dateRelativeString = timeDateRelativeFormatter.string(from: dt, to: Date()) {
                        return dateRelativeString
                    }
                }
            }
            return ""
        }
    }
    
}
