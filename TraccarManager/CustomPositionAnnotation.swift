//
//  CustomPositionAnnotation.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 28.07.17.
//  Copyright © 2017 Sergey Kruzhkov (s.kruzhkov@gmail.com). All rights reserved.
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

import Foundation
import UIKit
import MapKit

class CustomPositionAnnotation: MKAnnotationView {
    
    var imgView:UIImageView!

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        let pa: PositionAnnotation = annotation as! PositionAnnotation
        
        let frameWidth = 70.0
        let frameHeight = 30.0
        let radiusCircle = 10.0
        let angle = Double(pa.course!) - 90.0
        let imageName = "point_" + ((pa.category != nil) ? pa.category! : "default")
        
        var circleColor = UIColor.green.cgColor
        if pa.status == "unknown" {
            circleColor = UIColor.init(red: 251 / 255, green: 231 / 255, blue: 185 / 255, alpha: 1).cgColor
        } else if pa.status == "offline" {
            circleColor = UIColor.red.cgColor
        }
        
        self.backgroundColor = UIColor.clear
        self.canShowCallout = true
        self.frame = CGRect.init(x: 0, y: 0, width: frameWidth, height: frameHeight)
        if ((UIImage(named: imageName)) != nil) {
        //if let imageCar = UIImage(named: ) {
            self.imgView = UIImageView(image: UIImage(named: imageName))
        } else {
            self.imgView = UIImageView(image: UIImage(named: "point_" + "default") )
        }
        self.imgView.contentMode = .scaleAspectFit
        self.imgView.frame = self.bounds
        
        //let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: frameWidth, height: 10))
        //lbl.text = pa.
        //lbl.backgroundColor = UIColor.clear
        //self.addSubview(lbl)
        
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frameWidth / 2, y: frameHeight / 2), radius: CGFloat(radiusCircle), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayerCircle = CAShapeLayer()
        
        shapeLayerCircle.path = circlePath.cgPath
        shapeLayerCircle.fillColor = circleColor
        shapeLayerCircle.strokeColor = UIColor.darkGray.cgColor
        shapeLayerCircle.lineWidth = 1.5
        
        self.layer.addSublayer(shapeLayerCircle)
        
        // add arrow layer cource
        if pa.status != "offline" {
            
            let triangleHeight = radiusCircle + 5.0
            
            let arrowPath = UIBezierPath()
            
            let x1 = radiusCircle * cos((angle - 7) * (Double.pi / 180))
            let y1 = radiusCircle * sin((angle - 7) * (Double.pi / 180))
            
            let x2 = triangleHeight * cos(angle * (Double.pi / 180))
            let y2 = triangleHeight * sin(angle * (Double.pi / 180))
            
            let x3 = radiusCircle * cos((angle + 7) * (Double.pi / 180))
            let y3 = radiusCircle * sin((angle + 7) * (Double.pi / 180))
            
            arrowPath.move(to: CGPoint(x: x1 + frameWidth / 2, y: y1 + frameHeight / 2))
            arrowPath.addLine(to: CGPoint(x: x2 + frameWidth / 2, y: y2 + frameHeight / 2))
            arrowPath.addLine(to: CGPoint(x: x3 + frameWidth / 2, y: y3 + frameHeight / 2))
            arrowPath.close()
            
            let shapeLayerArrow = CAShapeLayer()
            shapeLayerArrow.path = arrowPath.cgPath
            shapeLayerArrow.lineWidth = 0.5
            shapeLayerArrow.fillColor = UIColor.darkGray.cgColor
            shapeLayerArrow.strokeColor = UIColor.darkGray.cgColor
            self.layer.addSublayer(shapeLayerArrow)
            
        }
        
        self.addSubview(self.imgView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
