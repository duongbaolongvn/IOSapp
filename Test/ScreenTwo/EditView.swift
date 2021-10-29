//
//  EditView.swift
//  Test
//
//  Created by Duong Bao Long on 10/21/21.
//

import UIKit

class EditView: UIView {
    
    let line = CAShapeLayer()
    let dot = CAShapeLayer()
    
    let r: CGFloat = 5
    let lineWidth: CGFloat = 1.5
    func show(_ view: UIView){
        let p0 = view.convert(CGPoint.zero, to: self)
        let p1 = view.convert(CGPoint(x: view.bounds.maxX, y: 0), to: self)
        let p2 = view.convert(CGPoint(x: view.bounds.maxX, y: view.bounds.maxY), to: self)
        let p3 = view.convert(CGPoint(x: 0, y: view.bounds.maxY), to: self)
        
        let pathLine = UIBezierPath()
        pathLine.move(to: p0)
        for p in [p1,p2,p3] {
            pathLine.addLine(to: p)
        }
        pathLine.close()
        line.path = pathLine.cgPath
        
        
        let pathDots = UIBezierPath()
        for d in [p0,p1,p2,p3] {
            pathDots.append(UIBezierPath(arcCenter: d, radius: r, startAngle: 0, endAngle: .pi*2, clockwise: true))
        }
        dot.path = pathDots.cgPath
        
        line.fillColor = UIColor.clear.cgColor
        line.strokeColor = UIColor.blue.cgColor
        line.lineWidth = lineWidth
        
        dot.fillColor = UIColor.blue.cgColor
        
        layer.addSublayer(line)
        layer.addSublayer(dot)
        
        dot.isHidden = false
        line.isHidden = false
    }

    func hide(){
        dot.isHidden = true
        line.isHidden = true
    }
}
