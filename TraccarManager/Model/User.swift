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
        
        WebService.sharedInstance.disconnectWebSocket()
        email = nil
        NSHTTPCookieStorage.sharedHTTPCookieStorage().removeCookiesSinceDate(NSDate(timeIntervalSinceReferenceDate: 0))
        
        // tell everyone that the user has logged out
        NSNotificationCenter.defaultCenter().postNotificationName(Definitions.LoginStatusChangedNotificationName, object: nil)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        // ignore the password, we don't care about it
        if key != "password" {
            print("Tried to set property '\(key)' that doesn't exist on the User model")
        }
    }
    
}