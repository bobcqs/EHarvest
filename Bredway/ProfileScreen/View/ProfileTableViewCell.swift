//
//  ProfileTableViewCell.swift
//  Bredway
//
//  Created by Xudong Chen on 18/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var optionImage: UIImageView!
    @IBOutlet weak var optionName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(item: ProfileOption){
        optionName.text = item.rawValue
        switch item{
        case .favourites:
            if let image = UIImage(named: "likeBlack"){
                optionImage.image = image
            }
        case .myListing:
            if let image = UIImage(named: "myListingBlack"){
                optionImage.image = image
            }
        case .purchases:
            if let image = UIImage(named: "purchaseBlack"){
                optionImage.image = image
            }
        case .soldItems:
            if let image = UIImage(named: "soldBlack"){
                optionImage.image = image
            }
        case .settings:
            if let image = UIImage(named: "settingBlack"){
                optionImage.image = image
            }
        case .contactUs:
            if let image = UIImage(named: "emailBlack"){
                optionImage.image = image
            }
        }
        
    }

}
