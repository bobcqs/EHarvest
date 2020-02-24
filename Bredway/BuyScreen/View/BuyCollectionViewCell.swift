//
//  BuyCollectionViewCell.swift
//  Bredway
//
//  Created by Xudong Chen on 17/3/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift
import Lottie

class BuyCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageShadowView: UIView!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var heartImage: UIButton!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var soldOutImage: UIImageView!
    
    
    var disposeBag = DisposeBag()
    var animationView = AnimationView()
    var item: Item? {
        didSet {
            guard let item = item else {
                logger.debug("No item found for cell")
                return
            }
            
            if let imageUrl = item.imageUrls?.first{
                if let url = URL(string: imageUrl){
                    itemImage?.kf.setImage(with: url, options: [.transition(.fade(0.2))])
                }
            }
            
            if let itemId = item.itemId{
                if UserManager.shared.isFavouriteItem(itemId: itemId){
                    configureHeartImage(isFavourite: true)
                } else {
                    configureHeartImage(isFavourite: false)
                }
            }
            
            if let timeStamp = item.timeStamp {
                timeLabel.text = TimeStampHelper.shared.getTime(timeStamp: Int(timeStamp)!)
            } else {
                timeLabel.text = ""
            }
            brandLabel.text = (item.brand ?? "").uppercased()
            nameLabel.text = (item.name ?? "").uppercased()
            priceLabel.text = "$" + String(item.price ?? 0)
            if let isSold = item.isSold, isSold == true{
                soldOutImage.isHidden = false
            } else {
                soldOutImage.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

//        imageShadowView.layer.cornerRadius = 4
//        
//        animationView = LOTAnimationView(name: "LikeAnimation")
//        animationView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        animationView.contentMode = .scaleAspectFill
//        animationView.frame = heartImage.bounds
//        animationView.transform = CGAffineTransform(scaleX: 4.0, y: 3.9)
//        animationView.animationSpeed = 4
//        heartImage.addSubview(animationView)
//        animationView.isHidden = true
        
        backgroundColor = UIColor.clear
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 2
       // self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 4).cgPath
        
        soldOutImage.isHidden = true
        
    }
    
    func configureCell(){
        
    }
    
    func configureHeartImage(isFavourite: Bool){
        if isFavourite{
            if let image = UIImage(named: MasterConstants.ICON_HEART_FILLED){
                heartImage.setImage(image, for: .normal)
            }
        } else {
            if let image = UIImage(named: MasterConstants.ICON_HEART){
                heartImage.setImage(image, for: .normal)
            }
        }
    }
    
    func switchHeartImage(isFavourite: Bool){
        HapticGenerator.shared.generateMediumTapFeedback()
        if isFavourite{
            if let image = UIImage(named: MasterConstants.ICON_HEART){
                heartImage.setImage(image, for: .normal)
            }
        } else {
            animationView.isHidden = false
            self.animationView.alpha = 1

            heartImage.setImage(UIImage(), for: .normal)
            animationView.play(fromProgress: 0.4, toProgress: 0.8) { (finished) in
                UIView.animate(withDuration: 1, animations: {
                    self.animationView.alpha = 0
                }, completion: { (finished) in
                    self.animationView.isHidden = true
                })
                self.heartImage.isHidden = false
                if let image = UIImage(named: MasterConstants.ICON_HEART_FILLED){
                    self.heartImage.setImage(image, for: .normal)
                }
            }
        }
    }
    
    override func prepareForReuse() {
        itemImage.image = nil
        soldOutImage.isHidden = true
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    
}
