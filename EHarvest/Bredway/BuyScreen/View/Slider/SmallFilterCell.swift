//
//  SmallFilterCell.swift
//  Bredway
//
//  Created by Xudong Chen on 11/9/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

class SmallFilterCell: UICollectionViewCell {
    
    @IBOutlet weak var smallFilterImageView: UIImageView!
    @IBOutlet weak var smallFilterLabel: UILabel!
    
    var smallFilter: Slider? {
        didSet{
            smallFilterLabel.text = smallFilter?.name
            if let imageUrl = smallFilter?.imageUrl{
                if let url = URL.init(string: imageUrl){
                    smallFilterImageView.kf.setImage(with: url)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        smallFilterImageView.image = nil
        super.prepareForReuse()
    }
}
