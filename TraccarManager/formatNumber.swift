//
//  fomatNumber.swift
//  fstart
//
//  Created by Sergey Kruzhkov on 02.06.17.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//

import Foundation

class formatNumber: NumberFormatter {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        self.locale = NSLocale.current
        self.maximumFractionDigits = 10
        self.notANumberSymbol = "Error"
        self.groupingSeparator = " "
        self.groupingSize = 3
        self.usesGroupingSeparator = true
        self.numberStyle = .decimal
    }
    static let sharedInstance = formatNumber()
}

extension Double {
    
    func stringFormat(round: Int) -> String {
    
        // format speed to 1 dp
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = round
        let formatted = formatter.string(from: self as NSNumber)
        
        if let fs = formatted {
            return fs
        } else {
            return ""
        }
    }
}

