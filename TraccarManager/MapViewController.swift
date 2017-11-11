//
// Copyright 2016 William Pearse (w.pearse@gmail.com)
// Copyright 2017 Sergey Kruzhkov (s.kruzhkov@gmail.com)
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

//flag switching my position
enum statusPosition: Int {
    case goPosition = 1
    case offPosition = 2
    case onPosition = 3
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView: MKMapView?
    @IBOutlet var buttonReport: UIBarButtonItem!
    @IBOutlet var buttonMyLocation: UIImageView!
    @IBOutlet var viewMyLocation: UIView!
    
    fileprivate var devices: [Device] = []
    
    fileprivate var positions: [Position] = []
    
    
    // controls whether the map view should center on user's default location
    // when the view appears. we use this variable to prevent re-centering the
    // map every single time this view appears
    fileprivate var shouldCenterOnAppear: Bool = true
    
    var isLogin = true
    
    // if a map pin is tapped by the user, a reference will be stored here
    var selectedDevice: Device?
    var followDevice = false
    var statusMyPosition = statusPosition.onPosition
    let locationManager = CLLocationManager()
    
    let blueColor = UIColor(red: 85 / 255, green: 155 / 255, blue: 248 / 255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        let tapbuttonMyLocation = UITapGestureRecognizer(target: self, action: #selector(self.pressButtonMyLocation))
        viewMyLocation.addGestureRecognizer(tapbuttonMyLocation)
        buttonMyLocation.tintColor = blueColor
        viewMyLocation.layer.cornerRadius = 7
        viewMyLocation.layer.shadowRadius = 1
        viewMyLocation.layer.shadowOpacity = 0.5
        viewMyLocation.layer.shadowOffset = CGSize.zero
        themeColor()
    
        // don't let user open devices view until the devices have been loaded
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        mapView?.showsScale = true
        mapView?.isRotateEnabled = false
        mapView?.delegate = self
        mapView?.setUserTrackingMode(.follow, animated: true)
        let stopFollow = UITapGestureRecognizer(target: self, action: #selector(self.stopFollowDevice))
        mapView?.addGestureRecognizer(stopFollow)
        
        setStatusMyLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // update the map when we're told that a Position has been updated 
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(MapViewController.refreshDevices),
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

    @IBAction func reportButtonPressed(_ sender: Any) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ReportListViewStoryboard")  as! ReportListViewController
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func devicesButtonPressed() {
        performSegue(withIdentifier: "ShowDevices", sender: self)
    }
    
    @IBAction func zoomToAllButtonPressed() {
        mapView?.showAnnotations((mapView?.annotations)!, animated: true)
    }
    
    @objc func pressButtonMyLocation(recognaizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3) {
            self.viewMyLocation.backgroundColor = self.blueColor.withAlphaComponent(0.4)
            self.buttonMyLocation.tintColor = UIColor.white
            self.themeColor()
        }
        
        switch statusMyPosition {
        case .goPosition:
            statusMyPosition = statusPosition.offPosition
            mapView?.setUserTrackingMode(.none, animated: true)
            mapView?.showsUserLocation = false
        case .offPosition:
            statusMyPosition = statusPosition.onPosition
            mapView?.setUserTrackingMode(.none, animated: true)
            mapView?.showsUserLocation = true
        case .onPosition:
            statusMyPosition = statusPosition.goPosition
            mapView?.setUserTrackingMode(.follow, animated: true)
            mapView?.showsUserLocation = true
            //zoom my location
            let myLocation = mapView?.userLocation.coordinate
            let viewRegion = MKCoordinateRegionMakeWithDistance(myLocation!, 700, 100)
            mapView?.setRegion(viewRegion, animated: true)
        }
        
        setStatusMyLocation()
    }
    
    @IBAction func switchLayers(_ sender: Any) {
        
        switch mapView!.mapType {
        case .standard:
            mapView?.mapType = MKMapType.satellite
            showToast(message: "Satellite layer", withDuration: 1.5, width: 150.0)
        case .satellite:
            mapView?.mapType = MKMapType.hybrid
            showToast(message: "Hybrid layer", withDuration: 1.5, width: 150.0)
        default:
            mapView?.mapType = MKMapType.standard
            showToast(message: "Standard layer", withDuration: 1.5, width: 150.0)
        }
        themeColor()
    }
    
    @objc func loginStatusChanged() {
        
        if User.sharedInstance.isAuthenticated {
            
            refreshDevices()
        }
    }
    
    func setStatusMyLocation() {
        
        switch statusMyPosition {
        case .goPosition:
            buttonMyLocation?.image = #imageLiteral(resourceName: "Image_mylocation_go")
        case .offPosition:
            buttonMyLocation?.image = #imageLiteral(resourceName: "Image_mylocation_off")
        case .onPosition:
            buttonMyLocation?.image = #imageLiteral(resourceName: "Image_mylocation_on")
        }
    }
    
    @objc func refreshDevices() {
        
        WebService.sharedInstance.fetchDevices(onSuccess: { (newDevices) in
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.buttonReport.isEnabled = true
            self.devices = newDevices
            
            // if devices are added/removed from the server while user is logged-in, the
            // positions will be added/removed from the map here
            self.refreshPositions()
        })
        
    }
    
    func themeColor() {
        if mapView?.mapType == MKMapType.standard {
            viewMyLocation.backgroundColor = UIColor.white.withAlphaComponent(0.9)
            buttonMyLocation.tintColor = blueColor
        } else {
            viewMyLocation.backgroundColor = UIColor(red: 58 / 255, green: 45 / 255,  blue: 19 / 255, alpha: 0.9)
            buttonMyLocation.tintColor = UIColor.white
        }
    }
    
    func refreshPositions() {
        
        // positions of devices
        self.positions = WebService.sharedInstance.positions
        
        //remove annotations
        for ea in (self.mapView?.annotations)! {
            if let a = ea as? CarAnnotation {
                if WebService.sharedInstance.deviceById(a.deviceId!) == nil {
                    self.mapView?.removeAnnotation(a)
                }
            }
        }
        
        for device in self.devices {
            
            var annotationForDevice: CarAnnotation?
            for existingAnnotation in (self.mapView?.annotations)! {
                if let a = existingAnnotation as? CarAnnotation {
                    if a.deviceId == device.id {
                        annotationForDevice = a
                        break
                    }
                }
            }
        
            if let p = WebService.sharedInstance.positionByDeviceId(device.id!) {
                
                var isPositionChanged = false
             
                var point: CarAnnotation?
                if annotationForDevice == nil {
                    point = CarAnnotation(coordinate: p.coordinate)
                    point?.deviceId = device.id
                } else {
                    point = annotationForDevice
                }
                
                if point?.positionId != p.id {
                    //position changed
                    isPositionChanged = true
                    point?.positionId = p.id
                    point?.course = p.course
                    point?.speed = p.speed
                    point?.subtitle = p.address
                }
                let isDeviceSelected = selectedDevice?.id == device.id
                if point?.selected != isDeviceSelected {
                    point?.selected = isDeviceSelected
                }
                if point?.title != device.name {
                    point?.title = device.name
                }
                if point?.status != device.status {
                    point?.status = device.status
                }
                if point?.category != device.category {
                    point?.category = device.category
                }
                
                if annotationForDevice == nil {
                    self.mapView?.addAnnotation(point!)
                } else if isPositionChanged {
                    point?.update(coordinate: p.coordinate)
                }
                if point!.selected! && followDevice {
                    zoomDevice()
                }
            }
        }
        if isLogin {
            //set region all devices
            self.mapView?.showAnnotations((self.mapView?.annotations)!, animated: true)
            isLogin = false
        }
    }
    
    @objc func stopFollowDevice(gesture: UIGestureRecognizer) {
        followDevice = false
        mapView?.selectedAnnotations = []
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }

        let a = annotation as! CarAnnotation
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin" + String(a.deviceId!))
        if annotationView == nil {
            annotationView = CarAnnotationView(annotation: annotation, reuseIdentifier: "Pin" + String(a.deviceId!))
            annotationView?.canShowCallout = true
        }else{
            annotationView?.annotation = annotation
        }
        
        let btn = UIButton(type: .detailDisclosure)
        btn.addTarget(self, action: #selector(MapViewController.didTapMapPinDisclosureButton), for: UIControlEvents.touchUpInside)
        annotationView?.rightCalloutAccessoryView = btn
        
        return annotationView
        
    }
    
    // MARK: handle the tap of a map pin info button
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let a: CarAnnotation = view.annotation as? CarAnnotation {
            selectedDevice = WebService.sharedInstance.deviceById(a.deviceId!)
            a.selected = true
            followDevice = true
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if mapView.showsUserLocation {
            
            let cLocation = mapView.centerCoordinate
            let myLocation = mapView.userLocation.coordinate
            let delta = 0.001
            
            if cLocation.latitude > myLocation.latitude - delta && cLocation.latitude < myLocation.latitude + delta
                && cLocation.longitude > myLocation.longitude  - delta && cLocation.longitude < myLocation.longitude  + delta{
                statusMyPosition = statusPosition.goPosition
            } else {
                statusMyPosition = statusPosition.onPosition
            }
            setStatusMyLocation()
        
        }
    }
    
    @objc func didTapMapPinDisclosureButton(_ sender: UIButton) {
        if selectedDevice != nil {
            performSegue(withIdentifier: "ShowDeviceInfo", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // running on iPhone
        if let dvc = segue.destination as? DeviceInfoViewController {
            // set device on the info view
            dvc.device = selectedDevice
           
        } else if let nc = segue.destination as? UINavigationController {
            
            if let dvc = nc.topViewController as? DeviceInfoViewController {
                // set device on the info view
                dvc.device = selectedDevice
                
                // show a close button if we're running on an iPad
                dvc.shouldShowCloseButton = true
            } else if let dvc = nc.topViewController as? DevicesViewController {
                dvc.delegate = self
            }
            
        } else if let dvc = segue.destination as? DevicesViewController {
            dvc.delegate = self
        }
    }
    
    func zoomDevice() {
        
        // no devices
        if selectedDevice == nil {
            return
        }
        
        followDevice = true
        
        if let p = WebService.sharedInstance.positionByDeviceId((selectedDevice?.id)!) {
            let userCoordinate = p.coordinate
            let longitudeDeltaDegrees : CLLocationDegrees = 0.014
            let latitudeDeltaDegrees : CLLocationDegrees = 0.014
            let userSpan = MKCoordinateSpanMake(latitudeDeltaDegrees, longitudeDeltaDegrees)
            let userRegion = MKCoordinateRegionMake(userCoordinate, userSpan)
            
            UIView.animate(withDuration: 2.0, animations: {
                self.mapView?.setRegion(userRegion, animated: true)
            })
            
            for a in (mapView?.annotations)! {
                if let a = a as? CarAnnotation {
                    if a.deviceId == selectedDevice?.id {
                        mapView?.selectedAnnotations = [a as MKAnnotation]
                        break
                    }
                }
            }
        }
    }
    
}
