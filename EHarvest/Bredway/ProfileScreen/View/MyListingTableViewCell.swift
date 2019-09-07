//
//  MyListingTableViewCell.swift
//  Bredway
//
//  Created by Xudong Chen on 18/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MyListingTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var editButton: MainStyleButton!
    
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
    
    func configureCell(item: Item){
        if let itemImages = item.imageUrls{
            if let url = URL(string: itemImages[0]){
                let image = UIImage(named: "defaultImage")
                itemImage.kf.setImage(with: url, placeholder: image)
            }
        }
        categoryName.text = item.category
        itemName.text = item.name
        itemPrice.text = "$" + String(item.price ?? 0)
    }

}
