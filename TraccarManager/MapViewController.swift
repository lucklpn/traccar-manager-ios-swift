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
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView?
    
    fileprivate var devices: [Device] = []
    
    fileprivate var positions: [Position] = []
    
    // controls whether the map view should center on user's default location
    // when the view appears. we use this variable to prevent re-centering the
    // map every single time this view appears
    fileprivate var shouldCenterOnAppear: Bool = true
    
    // if a map pin is tapped by the user, a reference will be stored here 
    var selectedAnnotation: PositionAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // don't let user open devices view until the devices have been loaded
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // update the map when we're told that a Position has been updated 
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(MapViewController.refreshPositions),
                                                         name: NSNotification.Name(rawValue: Definitions.PositionUpdateNotificationName),
                                                         object: nil)
        
        // reload Devices and Positions when the user logs in, show login screen when user logs out
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(MapViewController.loginStatusChanged),
                                                         name: NSNotification.Name(rawValue: Definitions.LoginStatusChangedNotificationName),
                                                         object: nil)

        // we need to fire this manually when the view appears
        loginStatusChanged()
    }
    
    @IBAction func logoutButtonPressed() {
        User.sharedInstance.logout()
        mapView?.removeAnnotations((mapView?.annotations)!)
        shouldCenterOnAppear = true
        
        performSegue(withIdentifier: "ShowLogin", sender: self)
        self.dismiss(animated: true){}
    }

    @IBAction func devicesButtonPressed() {
        performSegue(withIdentifier: "ShowDevices", sender: self)
    }
    
    @IBAction func zoomToAllButtonPressed() {
        mapView?.showAnnotations((mapView?.annotations)!, animated: true)
    }
    
    func loginStatusChanged() {
        
        if User.sharedInstance.isAuthenticated {
            
            if shouldCenterOnAppear {
                let centerCoordinates = User.sharedInstance.mapCenter
                assert(CLLocationCoordinate2DIsValid(centerCoordinates), "Map center coordinates aren't valid")
                self.mapView?.setCenter(centerCoordinates, animated: true)
                
                shouldCenterOnAppear = false
            }
            
            WebService.sharedInstance.fetchDevices(onSuccess: { (newDevices) in
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.devices = newDevices
                
                // if devices are added/removed from the server while user is logged-in, the
                // positions will be added/removed from the map here
                self.refreshPositions()
            })
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            pinView!.canShowCallout = true
            
            let btn = UIButton(type: .detailDisclosure)
            btn.addTarget(self, action: #selector(MapViewController.didTapMapPinDisclosureButton), for: UIControlEvents.touchUpInside)
            pinView?.rightCalloutAccessoryView = btn
        }
        
        pinView!.annotation = annotation
        
        return pinView
    }
    
    // MARK: handle the tap of a map pin info button
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let a = view.annotation as? PositionAnnotation {
            selectedAnnotation = a
        }
    }
    
    func didTapMapPinDisclosureButton(_ sender: UIButton) {
        if selectedAnnotation != nil {
            performSegue(withIdentifier: "ShowDeviceInfo", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // running on iPhone
        if let dvc = segue.destination as? DeviceInfoViewController {
            
            // set device on the info view
            if let deviceId = selectedAnnotation?.deviceId {
                if let device = WebService.sharedInstance.deviceById(deviceId) {
                    dvc.device = device
                }
            }
            
        } else if let nc = segue.destination as? UINavigationController {
            
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
