//
//  RedDotView.swift
//  Bredway
//
//  Created by Xudong Chen on 21/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class RedDotView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setRoundCorners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setRoundCorners()
    }
    
    func setRoundCorners() {
        self.backgroundColor = ColorDesign.flatRed
        self.layer.cornerRadius = layer.frame.width / 2
        self.clipsToBounds = true
    }
}
