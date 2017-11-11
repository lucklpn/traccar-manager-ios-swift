//
//  Positions.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 11.11.2017.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//

import Foundation
import MapKit

struct Positions: Decodable {
    let id: Int?
    let deviceId: Int?
    let `protocol`: String?
    let serverTime: Date?
    let deviceTime: Date?
    let fixTime: Date?
    let outdated: Bool?
    let valid: Bool?
    let latitude: Double?
    let longitude: Double?
    let altitude: Double?
    let speed: Double?
    let course: Double?
    let address: String?
    let accuracy: Int?
    //let network: String
    let attributes: AttributeObject?
}

extension Positions {
    
    var coordinate: CLLocationCoordinate2D {
        guard let lat = latitude else {
            return kCLLocationCoordinate2DInvalid
        }
        guard let lon = longitude else {
            return kCLLocationCoordinate2DInvalid
        }
        return CLLocationCoordinate2DMake(lat, lon)
    }
    
}
