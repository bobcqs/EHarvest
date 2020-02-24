//
//  MainStyleButton.swift
//  Bredway
//
//  Created by Xudong Chen on 17/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation

//
//  SearchButton.swift
//  Bredway
//
//  Created by Xudong Chen on 15/3/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class MainStyleButton : UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.borderWidth = 1
        layer.borderColor = ColorDesign.blackTextColor.cgColor
    }
}

