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

import UIKit

class DeviceInfoViewController: UITableViewController {
    
    var device: Device?
    
    // set to true to show a Close button in the navigation item 
    var shouldShowCloseButton: Bool = false
    
    // list of properties to display for the device
    fileprivate var deviceProperties: [String] = [
        "Name",
        "Status",
        "Time"
    ]
    
    fileprivate var positionProperties: [String] = [
        "Latitude",
        "Longitude",
        /*
         TODO: something weird going on here, can't get the values
         for these two via KVC
         
        "Is Valid",
        "Is Outdated",
        */
        "Altitude",
        "Speed",
        "Course",
        "Address"
    ]
    
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let d = device {
            self.navigationItem.title = d.name
        }
        
        if shouldShowCloseButton {
            
            // it only makes sense to use this on the iPad, when this view is presented modally
            // direct from the map. this is because on an iPad this view can be displayed direct
            // from the map as a standalone modal, and without this close button there is no
            // way of closing the modal
            //
            // on an iPhone/iPod device the storyboard is set up so that this view is present using
            // a navigation controller, so we already have a done button in the top-left corner
            if Definitions.isRunningOniPad {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                                         target: self,
                                                                         action: #selector(DeviceInfoViewController.close))
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return deviceProperties.count
        } else if section == 1 {
            return positionProperties.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Device"
        } else if section == 1 {
            return "Position"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // default if no info available
        cell.detailTextLabel!.text = "–"
        
        if let d = device {
            
            if (indexPath as NSIndexPath).section == 0 {
                
                let property = deviceProperties[(indexPath as NSIndexPath).row]
                cell.textLabel!.text = property
                
                var keyPath = property.camelCasedString
                if property == "Status" {
                    keyPath = "statusString"
                }
                
                if property == "Time" {
                    if let value = d.value(forKey: "lastUpdate") {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd.MM.yy HH:mm:ss"
                        let dt = dateFormatter.string(from: value as! Date)
                        
                        cell.detailTextLabel!.text = dt
                    }
                } else if let value = d.value(forKey: keyPath) {
                    cell.detailTextLabel!.text = "\(value)"
                }
                
            } else if (indexPath as NSIndexPath).section == 1 {
                
                let property = positionProperties[(indexPath as NSIndexPath).row]
                cell.textLabel!.text = property
                
                if let position = d.position {
                    
                    var keyPath = property.camelCasedString
                    if property == "Latitude" {
                        keyPath = "latitudeString"
                    } else if property == "Longitude" {
                        keyPath = "longitudeString"
                    } else if property == "Course" {
                        keyPath = "courseDirectionString"
                    } else if property == "Speed" {
                        keyPath = "speedString"
                    }
                    
                    if let value = position.value(forKey: keyPath) {
                        cell.detailTextLabel!.text = "\(value)"
                    }
                }
                
            }
            
        }
        
        return cell
    }
    
}
