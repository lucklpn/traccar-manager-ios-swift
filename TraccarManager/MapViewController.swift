//
//  ViewController.swift
//  TraccarManager
//
//  Created by Anton Tananaev on 2/03/16.
//  Copyright © 2016 Anton Tananaev. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView?
    
    private var updateTimer: NSTimer?
    
    private var devices: [Device] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // don't let user open devices view until the devices have been loaded
        self.navigationItem.rightBarButtonItem?.enabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(30.0,
                                                             target: self,
                                                             selector: #selector(MapViewController.refreshDevices),
                                                             userInfo: nil,
                                                             repeats: true)

        if User.sharedInstance.isAuthenticated {
            
            let centerCoordinates = User.sharedInstance.mapCenter
            assert(CLLocationCoordinate2DIsValid(centerCoordinates), "Map center coordinates aren't valid")
            self.mapView?.setCenterCoordinate(centerCoordinates, animated: true)
            
            // called on a timer anyway, but we'll try and load devices ASAP after a login
            refreshDevices()
            
        } else {
            performSegueWithIdentifier("ShowLogin", sender: self)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateTimer?.invalidate()
    }
    
    @IBAction func logoutButtonPressed() {
        User.sharedInstance.logout()
        performSegueWithIdentifier("ShowLogin", sender: self)
    }

    @IBAction func devicesButtonPressed() {
        performSegueWithIdentifier("ShowDevices", sender: self)
    }
    
    func refreshDevices() {
        WebService.sharedInstance.fetchDevices(onSuccess: { (newDevices) in
            self.navigationItem.rightBarButtonItem?.enabled = true
            self.devices = newDevices
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationViewController as? DevicesViewController {
            dvc.devices = self.devices
        }
    }
    
}
