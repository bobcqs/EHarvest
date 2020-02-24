//
//  DescriptionViewBorder.swift
//  Bredway
//
//  Created by Xudong Chen on 18/4/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class SellDescriptionBorder: UITextView {

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.setBorder()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setBorder()
    }

    func setBorder() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    
}

