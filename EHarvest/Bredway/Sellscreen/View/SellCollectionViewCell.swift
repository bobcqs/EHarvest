//
//  SellCollectionViewCell.swift
//  Bredway
//
//  Created by Xudong Chen on 10/4/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    
    private(set) var disposeBag: DisposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    func bind(){
    }
    
}
