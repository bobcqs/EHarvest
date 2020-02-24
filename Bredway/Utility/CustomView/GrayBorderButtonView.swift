//
//  GrayBorderButtonView.swift
//  Bredway
//
//  Created by Xudong Chen on 14/5/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class GrayBorderButtonView: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    func setupView() {
        addBorder(toSide: .Top, withColor: ColorDesign.flatBlackDark.cgColor, andThickness: 1)
        addBorder(toSide: .Bottom, withColor: ColorDesign.flatBlackDark.cgColor, andThickness: 1)
        addBorder(toSide: .Right, withColor: ColorDesign.flatBlackDark.cgColor, andThickness: 1)
    }
}
