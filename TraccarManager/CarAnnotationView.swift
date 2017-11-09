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

class CarAnnotationView: MKAnnotationView {
    
    var imgView: UIImageView!
    var shapeLayerCircle = CAShapeLayer()
    var shapeLayerArrow = CAShapeLayer()
    var label: UILabel?
    var radiusCircle = 10.0
    var pa: CarAnnotation?
    let frameWidth = 70.0
    let frameHeight = 30.0
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {

        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        addObserver()
        renderAnnotation(annotation: annotation, xx: 0.0, yy: 0.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        removeObserver()
    }
    
    func renderAnnotation(annotation: MKAnnotation?, xx: Double, yy: Double) {
        
        pa = annotation as? CarAnnotation
    
        if pa?.selected != nil && (pa?.selected)! {
            radiusCircle = 15.0
        }

        let imageName = "point_" + ((pa?.category != nil) ? (pa?.category)! : "default")
        self.imgView = UIImageView(image: UIImage(named: imageName))
        
        self.backgroundColor = UIColor.clear
        self.canShowCallout = true
        self.frame = CGRect.init(x: xx, y:yy, width: frameWidth, height: frameHeight)
        
        drawCircle(xx: xx, yy: yy)
        
        self.imgView.tintColor = UIColor.black
        self.imgView.contentMode = .scaleAspectFit
        self.imgView.frame = self.bounds
        self.addSubview(self.imgView)
        
        let xl = frameWidth / 2  + (radiusCircle + 5) * cos(0)
        let yl = frameHeight / 2 + (radiusCircle + 5) * sin(0) + 5
        label = UILabel(frame: CGRect(x: xl, y: yl, width: 150, height: 14))
        label?.textAlignment = .left
        label?.textColor = UIColor.darkGray
        label?.font = label?.font.withSize(12)
        label?.text = pa?.title
        self.addSubview(label!)
        
        let tapAnnotation = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.addGestureRecognizer(tapAnnotation)
    }
    
    func drawCircle(xx: Double, yy: Double) {
        
        shapeLayerArrow = CAShapeLayer()
        
        let frameWidth = 70.0
        let frameHeight = 30.0
        
        var circleColor = UIColor.green.cgColor
        if pa?.status == "unknown" {
            circleColor = UIColor.init(red: 251 / 255, green: 231 / 255, blue: 185 / 255, alpha: 1).cgColor
        } else if pa?.status == "offline" {
            circleColor = UIColor.red.cgColor
        }
        
        if pa?.selected != nil && (pa?.selected)! {
            radiusCircle = 15.0
        }
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frameWidth / 2, y: frameHeight / 2), radius: CGFloat(radiusCircle), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        shapeLayerCircle = CAShapeLayer()
        
        shapeLayerCircle.path = circlePath.cgPath
        shapeLayerCircle.fillColor = circleColor
        shapeLayerCircle.strokeColor = UIColor.darkGray.cgColor
        shapeLayerCircle.lineWidth = 1.5
        
        self.layer.addSublayer(shapeLayerCircle)
        
        // add arrow layer cource
        drawArrow()
        
    }
    
    func drawArrow() {
        
        if pa?.status != "offline" {
            
            let angle = Double(truncating: (pa?.course)!) - 90.0
            
            let arrowPath = UIBezierPath()
            
            let triangleHeight = radiusCircle + 5.0
            
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
            
            shapeLayerArrow.path = arrowPath.cgPath
            shapeLayerArrow.lineWidth = 0.5
            shapeLayerArrow.fillColor = UIColor.darkGray.cgColor
            shapeLayerArrow.strokeColor = UIColor.darkGray.cgColor
            self.layer.addSublayer(shapeLayerArrow)
        }
    }
    
    @objc func tap(recognaizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: 1.0) {
            self.imgView.tintColor = UIColor.gray
            self.imgView.tintColor = UIColor.black
        }
    }
    
    func addObserver() {
        if let annotation = annotation as? CarAnnotation {
            annotation.addObserver(self, forKeyPath: #keyPath(CarAnnotation.course), options: [.new, .old], context: nil)
            annotation.addObserver(self, forKeyPath: #keyPath(CarAnnotation.status), options: [.new, .old], context: nil)
            annotation.addObserver(self, forKeyPath: #keyPath(CarAnnotation.category), options: [.new, .old], context: nil)
            annotation.addObserver(self, forKeyPath: #keyPath(CarAnnotation.title), options: [.new, .old], context: nil)
        }
    }
    private func removeObserver() {
        if let annotation = annotation as? CarAnnotation {
            annotation.removeObserver(self, forKeyPath: #keyPath(CarAnnotation.course))
            annotation.removeObserver(self, forKeyPath: #keyPath(CarAnnotation.status))
            annotation.removeObserver(self, forKeyPath: #keyPath(CarAnnotation.category))
            annotation.removeObserver(self, forKeyPath: #keyPath(CarAnnotation.title))
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "course" {
            drawArrow()
        } else if keyPath == "status" {
            var circleColor = UIColor.green.cgColor
            if pa?.status == "unknown" {
                circleColor = UIColor.init(red: 251 / 255, green: 231 / 255, blue: 185 / 255, alpha: 1).cgColor
            } else if pa?.status == "offline" {
                circleColor = UIColor.red.cgColor
            }
            shapeLayerCircle.fillColor = circleColor
        } else if keyPath == "category" {
            let imageName = "point_" + ((pa?.category != nil) ? (pa?.category)! : "default")
            imgView.image = UIImage(named: imageName)
        } else if keyPath == "title" {
            label?.text = pa?.title
        }
        
    }
}


