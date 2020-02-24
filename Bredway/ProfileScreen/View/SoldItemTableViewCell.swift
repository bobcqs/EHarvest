//
//  SoldItemTableViewCell.swift
//  Bredway
//
//  Created by Xudong Chen on 30/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxSwift

class SoldItemTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var askBuyerButton: MainStyleButton!
    @IBOutlet weak var shipmentButton: MainStyleButton!
    
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
        categoryName.text = item.category
        itemName.text = item.name
        itemPrice.text = "$" + String(item.price ?? 0 )
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
                shipmentButton.isHidden = true
            } else if status == "successful"{
                let image = UIImage(named: "tickGrey")
                statusImageView.image = image
                statusLabel.text = "SOLD"
                shipmentButton.isHidden = true
            } else if status == "refunded"{
                let image = UIImage(named: "tickGrey")
                statusImageView.image = image
                statusLabel.text = "REFUNDED"
                shipmentButton.isHidden = true
            }
        }

    }

}
