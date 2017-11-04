//
//  Attribute.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 04.11.2017.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//

import Foundation

struct Attribute: Codable {
    let id: Int?
    let description: String?
    let attribute: String?
    let expression: String?
    let type: String?
}
