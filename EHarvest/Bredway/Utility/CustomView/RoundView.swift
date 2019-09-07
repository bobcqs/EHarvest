//
//  RoundView.swift
//  Bredway
//
//  Created by Xudong Chen on 16/3/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class RoundedView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setRoundCorners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setRoundCorners()
    }
    
    func setRoundCorners() {
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
    }
}
