//
//  Geofence.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 05.11.2017.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//

import Foundation

struct Geofence: Codable {
    let id: Int?
    let name: String?
    let description: String?
    let area: String?
    let calendarId: Int?
}
