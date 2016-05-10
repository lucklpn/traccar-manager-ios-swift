//
//  ViewController.swift
//  TraccarManager
//
//  Created by Anton Tananaev on 2/03/16.
//  Copyright © 2016 Anton Tananaev. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView?
    
    private var devices: [Device] = []
    
    private var positions: [Position] = []
    
    // controls whether the map view should center on user's default location
    // when the view appears. we use this variable to prevent re-centering the
    // map every single time this view appears
    private var shouldCenterOnAppear: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // don't let user open devices view until the devices have been loaded
        self.navigationItem.rightBarButtonItem?.enabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // update the map when we're told that a Position has been updated 
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(MapViewController.refreshPositions),
                                                         name: Definitions.PositionUpdateNotificationName,
                                                         object: nil)
        
        if User.sharedInstance.isAuthenticated {
            
            if shouldCenterOnAppear {
                let centerCoordinates = User.sharedInstance.mapCenter
                assert(CLLocationCoordinate2DIsValid(centerCoordinates), "Map center coordinates aren't valid")
                self.mapView?.setCenterCoordinate(centerCoordinates, animated: true)
                
                shouldCenterOnAppear = false
            }
            
            WebService.sharedInstance.fetchDevices(onSuccess: { (newDevices) in
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.devices = newDevices
                
                // if devices are added/removed from the server while user is logged-in, the
                // positions will be added/removed from the map here
                
                self.mapView?.removeAnnotations((self.mapView?.annotations)!)
                
                for d in self.devices {
                    if let p = WebService.sharedInstance.positionByDeviceId(d.id!) {
                        let a = PositionAnnotation()
                        a.coordinate = p.coordinate
                        a.title = p.annotationTitle
                        a.subtitle = p.annotationSubtitle
                        
                        a.positionId = p.id
                        a.deviceId = p.deviceId
                        
                        self.mapView?.addAnnotation(a)
                    }
                }
                
            })
            
        } else {
            performSegueWithIdentifier("ShowLogin", sender: self)
        }
    }
    
    @IBAction func logoutButtonPressed() {
        User.sharedInstance.logout()
        shouldCenterOnAppear = true
        performSegueWithIdentifier("ShowLogin", sender: self)
    }

    @IBAction func devicesButtonPressed() {
        performSegueWithIdentifier("ShowDevices", sender: self)
    }
    
    @IBAction func zoomToAllButtonPressed() {
        mapView?.showAnnotations((mapView?.annotations)!, animated: true)
    }
    
    func refreshPositions() {
        
        // positions of devices
        self.positions = WebService.sharedInstance.positions
        
        // loop through all our current annotations, if the position ID
        // of each annotation matches a position ID from the webservice
        // then it's a current position ID, and it shouldn't be modified
        // else, we update the annotation to match what it should be
        for existingAnnotation in (self.mapView?.annotations)! {
            
            if let a = existingAnnotation as? PositionAnnotation {
                if let p = WebService.sharedInstance.positionByDeviceId(a.deviceId!) {
                    if p.id == a.positionId {
                        // this annotation is still current, don't change it
                    } else {
                        a.coordinate = p.coordinate
                        a.title = p.annotationTitle
                        a.subtitle = p.annotationSubtitle
                        a.positionId = p.id
                        // device ID will not have changed
                    }
                } else {
                    // there's a problem -- the position for this device has been removed!
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationViewController as? DevicesViewController {
            dvc.devices = self.devices
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKindOfClass(MKUserLocation.self) {
            return nil
        }
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("Pin")
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            pinView!.canShowCallout = true
        }
        
        pinView!.annotation = annotation
        
        return pinView
    }
    
}
