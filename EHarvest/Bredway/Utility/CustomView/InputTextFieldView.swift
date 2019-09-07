//
//  InputTextFieldView.swift
//  Bredway
//
//  Created by Xudong Chen on 17/4/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class InputTextFieldView: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width - 10, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width - 10, height: bounds.height)
    }
    
    func setupView() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
      //  layer.borderColor = ColorDesign.separatorGray.cgColor
        layer.cornerRadius = 5
        layer.masksToBounds = true
       // backgroundColor = UIColor.clear
    }
}
