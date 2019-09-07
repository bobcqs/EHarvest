//
//  FilterCategoryCell.swift
//  Bredway
//
//  Created by Xudong Chen on 3/8/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class FilterCategoryCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(category: FilterCategory, isCurrent: Bool){
        categoryLabel.text = (category.name ?? "").capitalized
        if isCurrent{
            categoryLabel.textColor = ColorDesign.flatBlack
            backgroundColor = UIColor.white
        } else {
            categoryLabel.textColor = UIColor.white
            backgroundColor = ColorDesign.flatRed
        }
        
    }

}
