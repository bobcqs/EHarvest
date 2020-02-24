//
//  BrandFilterTableViewCell.swift
//  Bredway
//
//  Created by Xudong Chen on 25/9/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

class BrandFilterCell: UICollectionViewCell {

    @IBOutlet weak var brandFilterImageView: UIImageView!
    @IBOutlet weak var brandFilterLabel: UILabel!
    
    var brandFilter: Slider? {
        didSet{
            brandFilterLabel.text = brandFilter?.name
            if let imageUrl = brandFilter?.imageUrl{
                if let url = URL.init(string: imageUrl){
                    brandFilterImageView.kf.setImage(with: url)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        brandFilterImageView.image = nil
        super.prepareForReuse()
    }
}
