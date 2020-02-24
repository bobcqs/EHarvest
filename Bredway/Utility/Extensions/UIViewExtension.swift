//
//  UIViewExtension.swift
//  Bredway
//
//  Created by Xudong Chen on 16/3/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

extension UIView {
    
    // Example use: myView.addBorder(toSide: .Left, withColor: UIColor.redColor().CGColor, andThickness: 1.0)
    
    enum ViewSide {
        case Left, Right, Top, Bottom
    }
    
    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {
        
        let border = CALayer()
        border.backgroundColor = color
        
        switch side {
        case .Left: border.frame = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height); break
        case .Right: border.frame = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height); break
        case .Top: border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: thickness); break
        case .Bottom: border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness); break
        }
        
        layer.addSublayer(border)
    }
    
    func addBorderWithView(toSide side: ViewSide, withColor color: UIColor, andThickness thickness: CGFloat) {
        
        let borderView = UIView()
        borderView.backgroundColor = color
        
        switch side {
        case .Left: borderView.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height); break
        case .Right: borderView.frame = CGRect(x: frame.size.width - thickness, y: 0, width: thickness, height: frame.height);
            break
        case .Top:
            borderView.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness); break
        case .Bottom: borderView.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness); break
        }
        
        addSubview(borderView)
    }
}
