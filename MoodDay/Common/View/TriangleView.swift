//
//  TriangleView.swift
//  PlantIdentification
//
//  Created by Linh Nguyen Duc on 30/03/2021.
//

import UIKit

class TriangleView: UIView {
    
    override func draw(_ rect: CGRect) {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: self.frame.maxY))
        bezierPath.addLine(to: CGPoint(x: self.frame.width/2, y: 0))
        bezierPath.addLine(to: CGPoint(x: self.frame.width, y: self.frame.maxY))
        bezierPath.addLine(to: CGPoint(x: 0, y: self.frame.maxY))
        
        UIColor.white.setFill()
        bezierPath.fill()
    }
}
