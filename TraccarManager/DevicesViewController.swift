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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
            
            var lu = device.lastUpdateString
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
