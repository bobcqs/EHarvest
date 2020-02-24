//
//  FilterMainCategoryCell.swift
//  Bredway
//
//  Created by Xudong Chen on 3/8/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class FilterMainCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var mainCategoryLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    
    func configureCell(mainCategory: FilterMainCategory, isCurrent: Bool){
        mainCategoryLabel.text = mainCategory.name
        underlineView.isHidden = !isCurrent
        
        if isCurrent{
            mainCategoryLabel.textColor = ColorDesign.blackTextColor
        } else {
            mainCategoryLabel.textColor = ColorDesign.grayTextColor
        }
        
    }
    
}
