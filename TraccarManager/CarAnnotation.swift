//
//  CarAnnotation.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 07.11.2017.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//

import Foundation
import MapKit

class CarAnnotation: NSObject, MKAnnotation {
    
    dynamic var coordinate: CLLocationCoordinate2D
    @objc dynamic var status: String?
    @objc dynamic var course: NSNumber?
    @objc dynamic var category: String?
    @objc dynamic var title: String?
    var positionId: NSNumber?
    var deviceId: Int?
    var speed: NSNumber?
    var selected: Bool?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
    
    func update(coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 2.0) {
            self.coordinate = coordinate
        }
    }
    
}
