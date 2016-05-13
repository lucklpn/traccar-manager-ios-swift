//
//  DeviceInfoViewController.swift
//  TraccarManager
//
//  Created by William Pearse on 8/05/16.
//  Copyright © 2016 Anton Tananaev. All rights reserved.
//

import UIKit

class DeviceInfoViewController: UITableViewController {
    
    var device: Device?
    
    // list of properties to display for the device
    private var deviceProperties: [String] = [
        "Name",
        "Status"
    ]
    
    private var positionProperties: [String] = [
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = device!.name
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return deviceProperties.count
        } else if section == 1 {
            return positionProperties.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Device"
        } else if section == 1 {
            return "Position"
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // default if no info available
        cell.detailTextLabel!.text = "–"
        
        if let d = device {
            
            if indexPath.section == 0 {
                
                let property = deviceProperties[indexPath.row]
                cell.textLabel!.text = property
                
                var keyPath = property.camelCasedString
                if property == "Status" {
                    keyPath = "statusString"
                }
                
                if let value = d.valueForKey(keyPath) {
                    cell.detailTextLabel!.text = "\(value)"
                }
                
            } else if indexPath.section == 1 {
                
                let property = positionProperties[indexPath.row]
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
                    
                    if let value = position.valueForKey(keyPath) {
                        cell.detailTextLabel!.text = "\(value)"
                    }
                }
                
            }
            
        }
        
        return cell
    }
    
}