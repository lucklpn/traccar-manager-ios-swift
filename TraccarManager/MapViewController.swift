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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if User.sharedInstance.isAuthenticated {
            
            let centerCoordinates = User.sharedInstance.mapCenter
            assert(CLLocationCoordinate2DIsValid(centerCoordinates), "Map center coordinates aren't valid")
            self.mapView?.setCenterCoordinate(centerCoordinates, animated: true)
            
            WebService.sharedInstance.fetchDevices(onSuccess: { (devices) in
                // TODO
            })
            
        } else {
            performSegueWithIdentifier("ShowLogin", sender: self)
        }
    }
    
    @IBAction func logoutButtonPressed() {
        User.sharedInstance.logout()
        performSegueWithIdentifier("ShowLogin", sender: self)
    }

    @IBAction func devicesButtonPressed() {
        // TODO: show devices list?
    }
    
}
