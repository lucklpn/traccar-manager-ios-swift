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
    
    // if a map pin is tapped by the user, a reference will be stored here 
    var selectedAnnotation: PositionAnnotation?
    
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
        
        // reload Devices and Positions when the user logs in, show login screen when user logs out
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(MapViewController.loginStatusChanged),
                                                         name: Definitions.LoginStatusChangedNotificationName,
                                                         object: nil)

        // we need to fire this manually when the view appears
        loginStatusChanged()
    }
    
    @IBAction func logoutButtonPressed() {
        User.sharedInstance.logout()
        mapView?.removeAnnotations((mapView?.annotations)!)
        shouldCenterOnAppear = true
    }

    @IBAction func devicesButtonPressed() {
        performSegueWithIdentifier("ShowDevices", sender: self)
    }
    
    @IBAction func zoomToAllButtonPressed() {
        mapView?.showAnnotations((mapView?.annotations)!, animated: true)
    }
    
    func loginStatusChanged() {
        
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
                self.refreshPositions()
            })
            
        } else {
            performSegueWithIdentifier("ShowLogin", sender: self)
        }
        
    }
    
    func refreshPositions() {
        
        // positions of devices
        self.positions = WebService.sharedInstance.positions
        
        for device in self.devices {
            
            var annotationForDevice: PositionAnnotation?
            for existingAnnotation in (self.mapView?.annotations)! {
                if let a = existingAnnotation as? PositionAnnotation {
                    if a.deviceId == device.id {
                        annotationForDevice = a
                        break
                    }
                }
            }
            
            if let a = annotationForDevice {
                
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
                    // the position for this device has been removed
                    self.mapView?.removeAnnotation(a)
                }
                
            } else {
                
                // there's no annotation for the device's position, we need to add one
                
                if let p = WebService.sharedInstance.positionByDeviceId(device.id!) {
                    let a = PositionAnnotation()
                    a.coordinate = p.coordinate
                    a.title = p.annotationTitle
                    a.subtitle = p.annotationSubtitle
                    
                    a.positionId = p.id
                    a.deviceId = p.deviceId
                    
                    self.mapView?.addAnnotation(a)
                }
                
            }
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
            
            let btn = UIButton(type: .DetailDisclosure)
            btn.addTarget(self, action: #selector(MapViewController.didTapMapPinDisclosureButton), forControlEvents: UIControlEvents.TouchUpInside)
            pinView?.rightCalloutAccessoryView = btn
        }
        
        pinView!.annotation = annotation
        
        return pinView
    }
    
    // MARK: handle the tap of a map pin info button
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let a = view.annotation as? PositionAnnotation {
            selectedAnnotation = a
        }
    }
    
    func didTapMapPinDisclosureButton(sender: UIButton) {
        if selectedAnnotation != nil {
            performSegueWithIdentifier("ShowDeviceInfo", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // running on iPhone
        if let dvc = segue.destinationViewController as? DeviceInfoViewController {
            
            // set device on the info view
            if let deviceId = selectedAnnotation?.deviceId {
                if let device = WebService.sharedInstance.deviceById(deviceId) {
                    dvc.device = device
                }
            }
            
        } else if let nc = segue.destinationViewController as? UINavigationController {
            
            if let dvc = nc.topViewController as? DeviceInfoViewController {
                
                // set device on the info view
                if let deviceId = selectedAnnotation?.deviceId {
                    if let device = WebService.sharedInstance.deviceById(deviceId) {
                        dvc.device = device
                    }
                }
                
                // show a close button if we're running on an iPad
                dvc.shouldShowCloseButton = true
            }
            
        }
    }
    
}
