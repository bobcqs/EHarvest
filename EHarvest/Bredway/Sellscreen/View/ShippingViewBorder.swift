//
//  ShippingViewBorder.swift
//  Bredway
//
//  Created by Xudong Chen on 18/4/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class SellShippingBorder: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setBorder()
    }
    
    func setBorder() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
}
