//
//  DetailMapViewController.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 11.11.2017.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class DetailMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    var SelectedEvents = [Event]()
    var SelectedPositions = [Positions]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRequestStart()
    }
    
    func showEvents() {
        
        for p in SelectedPositions {
            
            let device = WebService.sharedInstance.deviceById(p.deviceId!)
            let point = CarAnnotation(coordinate: p.coordinate)
            let event = SelectedEvents[SelectedEvents.index(where: { $0.positionId! == (p.id!)})!]
            
            point.positionId = p.id! as NSNumber
            point.title = device!.name! + "\n" + event.valueString(forKey: "type")
            point.course = p.course! as NSNumber
            point.speed = p.speed! as NSNumber
            point.subtitle = p.address
            point.status = device?.status
            point.category = device?.category
            
            self.mapView?.addAnnotation(point)
            
            //zoom all devices
            mapView?.showAnnotations((mapView?.annotations)!, animated: true)
        }
        
    }
    
    @objc func getRequestStart() {
        
        var strReq = "?"
        for e in SelectedEvents {
            if let p = e.positionId {
                if p != 0 {
                    strReq += "id=" + String(p) + "&"
                }
            }
        }
        
        let urlPoint = "positions"
        
        WebService.sharedInstance.getDataServer(filter: strReq, urlPoint: urlPoint, onFailure: { errorString in
            
            DispatchQueue.main.async(execute: {
                
                let ac = UIAlertController(title: "Error request", message: errorString, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                ac.addAction(okAction)
                self.present(ac, animated: true, completion: nil)
                
            })
            
        }, onSuccess: { (data) in
            
            DispatchQueue.main.async(execute: {
                
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                if let p = try? decoder.decode([Positions].self, from: data) {
                    self.SelectedPositions = p
                } else {
                    self.showToast(message: "Сoordinates not found", withDuration: 7.0, width: 220.0)
                    self.dismiss(animated: true, completion: nil)
                }
                
                self.showEvents()
                
            })
        })
        
    }
    
}
