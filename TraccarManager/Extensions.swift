//
//  Extensions.swift
//  TraccarManager
//
//  Created by William Pearse on 8/05/16.
//  Copyright © 2016 Anton Tananaev. All rights reserved.
//

import Foundation

extension String {
    
    // authored by https://gist.github.com/cemolcay and taken from https://gist.github.com/stevenschobert/540dd33e828461916c11 on 8 May 2016
    var camelCasedString: String {
        let source = self
        if source.characters.contains(" ") {
            let first = source.substringToIndex(source.startIndex.advancedBy(1))
            let cammel = NSString(format: "%@", (source as NSString).capitalizedString.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil)) as String
            let rest = String(cammel.characters.dropFirst())
            return "\(first)\(rest)"
        } else {
            let first = (source as NSString).lowercaseString.substringToIndex(source.startIndex.advancedBy(1))
            let rest = String(source.characters.dropFirst())
            return "\(first)\(rest)"
        }
    }
    
}