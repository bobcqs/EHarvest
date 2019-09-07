//
//  SearchItemTableViewCell.swift
//  Bredway
//
//  Created by Xudong Chen on 29/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class SearchItemTableViewCell: UITableViewCell {

    @IBOutlet weak var searchLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(text: String){
        searchLabel.text = text
    }

}
