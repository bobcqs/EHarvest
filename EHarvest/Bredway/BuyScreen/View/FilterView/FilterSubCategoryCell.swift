//
//  FilterSubCategoryCell.swift
//  Bredway
//
//  Created by Xudong Chen on 3/8/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class FilterSubCategoryCell: UITableViewCell {
    
    @IBOutlet weak var subCategoryLabel: UILabel!
    @IBOutlet weak var redTickView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(subCategory: FilterSubCategory){
        subCategoryLabel.text = subCategory.name
        if let isSelected = subCategory.isSelected, isSelected == true{
            redTickView.isHidden = false
        } else {
            redTickView.isHidden = true
        }
    }

}
