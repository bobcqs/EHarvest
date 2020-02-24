//
//  ImageViewBorder.swift
//  Bredway
//
//  Created by Xudong Chen on 17/4/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class SellImageBorder: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setBorder()
    }
    
    func setBorder() {
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 5
    }
}
