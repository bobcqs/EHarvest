//
//  FlatRoundButtonView.swift
//  Bredway
//
//  Created by Xudong Chen on 21/3/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class FlatRoundButtonView: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupButton()
    }
    
    func setupButton() {
        self.layer.cornerRadius = 2
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.2
    }
}
