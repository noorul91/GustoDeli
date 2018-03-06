//
//  CustomButton.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

@IBDesignable class CustomButton: UIButton {
    @IBInspectable var fillColor: UIColor = .green
    @IBInspectable var strokeColor: UIColor = .white
    @IBInspectable var isAddButton: Bool = true
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: rect)
        fillColor.setFill()
        path.fill()
        
        let plusHeight: CGFloat = 3.0
        let plusWidth: CGFloat = min(bounds.width, bounds.height) * 0.6
        
        let plusPath = UIBezierPath()
        plusPath.lineWidth = plusHeight
        
        plusPath.move(to: CGPoint(x: bounds.width / 2 - plusWidth / 2,
                                  y: bounds.height / 2))
        plusPath.addLine(to: CGPoint(x: bounds.width / 2 + plusWidth / 2,
                                     y: bounds.height / 2))
        
        if isAddButton {
            plusPath.move(to: CGPoint(x: bounds.width / 2,
                                      y: bounds.height / 2 - plusWidth / 2))
            plusPath.addLine(to: CGPoint(x: bounds.width / 2,
                                         y: bounds.height / 2 + plusWidth / 2))
        }
        strokeColor.setStroke()
        plusPath.stroke()
    }
}
