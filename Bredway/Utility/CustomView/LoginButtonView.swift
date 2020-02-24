//
//  GoogleLoginView.swift
//  Bredway
//
//  Created by Xudong Chen on 21/3/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class LoginButtonView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setRoundCorners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setRoundCorners()
    }
    
    func setRoundCorners() {
        layer.cornerRadius = 2.0
        clipsToBounds = true
        layer.masksToBounds = false
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 2, height: 2)
    }
}
