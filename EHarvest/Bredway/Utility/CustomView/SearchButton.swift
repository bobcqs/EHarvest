//
//  SearchButton.swift
//  Bredway
//
//  Created by Xudong Chen on 15/3/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class SearchButton : UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
}

