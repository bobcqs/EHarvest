//
//  PurchasesTableViewCell.swift
//  Bredway
//
//  Created by Xudong Chen on 2/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxSwift

class PurchasesTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var askBuyerButton: MainStyleButton!
    @IBOutlet weak var trackingButton: MainStyleButton!
    
    private(set) var disposeBag: DisposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func configureCell(item: SoldItem){
        if let itemImages = item.imageUrls{
            if let url = URL(string: itemImages[0]){
                let image = UIImage(named: "defaultImage")
                itemImage.kf.setImage(with: url, placeholder: image)
            }
        }
        categoryNameLabel.text = item.category
        itemNameLabel.text = item.name
        itemPriceLabel.text = "$" + String(item.price ?? 0)
        statusLabel.text = "TO BE SHIPPED"
        if let status = item.tradeStatus{
            if status == "paid"{
                let image = UIImage(named: "clockGrey")
                statusImageView.image = image
                statusLabel.text = "TO BE SHIPPED"
            }else if status == "shipped"{
                let image = UIImage(named: "clockGrey")
                statusImageView.image = image
                statusLabel.text = "SHIPPED"
            } else if status == "successful"{
                let image = UIImage(named: "tickGrey")
                statusImageView.image = image
                statusLabel.text = "SOLD"
                trackingButton.isHidden = true
            } else if status == "refunded"{
                let image = UIImage(named: "tickGrey")
                statusImageView.image = image
                statusLabel.text = "REFUNDED"
                trackingButton.isHidden = true
            }
        }
        
    }

}
