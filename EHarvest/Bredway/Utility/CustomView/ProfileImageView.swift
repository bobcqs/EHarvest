//
//  ProfileImageView.swift
//  Bredway
//
//  Created by Xudong Chen on 23/5/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class ProfileImageView: UIImageView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setRoundCorners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setRoundCorners()
    }
    
    func setRoundCorners() {
        layer.cornerRadius = 5.0
        clipsToBounds = true
    }
}
