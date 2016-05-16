//
//  DevicesTableViewController.swift
//  TraccarManager
//
//  Created by Anton Tananaev on 25/04/16.
//  Copyright © 2016 Anton Tananaev. All rights reserved.
//

import UIKit

class DevicesViewController: UITableViewController {

    var devices: [Device]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // update the list when we're told that a Position has been updated (this is the "Updated ... ago" message)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(DevicesViewController.reloadDevices),
                                                         name: Definitions.PositionUpdateNotificationName,
                                                         object: nil)
        
        // update the list when a Device has been updated (maybe the name has changed, or an addition/removal of a device)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(DevicesViewController.reloadDevices),
                                                         name: Definitions.DeviceUpdateNotificationName,
                                                         object: nil)
        
        if Definitions.isRunningOniPad {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done,
                                                                     target: self,
                                                                     action: #selector(DevicesViewController.close))
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reloadDevices()
    }
    
    func reloadDevices() {
        devices = WebService.sharedInstance.devices
        tableView.reloadData()
    }
    
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let d = devices {
            return d.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        if let d = devices {
            let device = d[indexPath.row]
            
            cell.textLabel!.text = device.name
            
            var lu = device.mostRecentPositionTimeString
            if lu.characters.count > 0 {
                lu = lu.lowercaseString
                cell.detailTextLabel!.text = "Updated \(lu) ago"
            } else {
                cell.detailTextLabel!.text = ""
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationViewController as? DeviceInfoViewController {
            let idxp = tableView.indexPathForSelectedRow
            if let d = devices {
                dvc.device = d[idxp!.row]
            }
        }
    }
}
