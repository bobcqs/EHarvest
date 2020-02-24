//
//  RetailSaleTableViewCell.swift
//  Bredway
//
//  Created by Xudong Chen on 19/9/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import Kingfisher

class RetailSaleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemNewPriceLabel: UILabel!
    @IBOutlet weak var itemOriginalPriceLabel: UILabel!
    
    var releaseDate: Date?
    var countdownTimer: Timer? = Timer()
    var retailSlider: RetailSlider? {
        didSet{
            
            if let imageUrl = retailSlider?.imageUrl{
                if let url = URL(string: imageUrl){
                    itemImage?.kf.setImage(with: url, options: [.transition(.fade(0.2))])
                }
            }
            itemName.text = retailSlider?.name
            itemNewPriceLabel.text = retailSlider?.newPrice
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: retailSlider?.originalPrice ?? "")
            attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            itemOriginalPriceLabel.attributedText = attributeString
            
            if let inProgress = retailSlider?.isInProgress{
                if inProgress{
                    titleLabel.text = retailSlider?.title
                    if let timeStamp = retailSlider?.endTimeStamp{
                        startTimer(timeStamp: timeStamp)
                    }
                } else {
                    timeLabel.isHidden = true
                    titleLabel.text = "Raffle Ended"
                }
            }
            
            let hover = CABasicAnimation(keyPath: "position")
            
            hover.isAdditive = true
            hover.fromValue = NSValue(cgPoint: CGPoint.zero)
            hover.toValue = NSValue(cgPoint: CGPoint(x: 0.0, y: 8.0))
            hover.autoreverses = true
            hover.duration = 2
            hover.repeatCount = Float.infinity
            
            itemImage.layer.add(hover, forKey: "myHoverAnimation")
        }
    }
    
    func startTimer(timeStamp: Double) {
        releaseDate = Date.init(timeIntervalSince1970: timeStamp)
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        
        let currentDate = Date()
        let calendar = Calendar.current
        
//        let diffDateComponents = calendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: releaseDate!)
//
//        let count = "Days \(diffDateComponents.day ?? 0), Hours \(diffDateComponents.hour ?? 0), Minutes \(diffDateComponents.minute ?? 0), Seconds \(diffDateComponents.second ?? 0)"
//
//        let countdown = "\(diffDateComponents.day ?? 0):\(diffDateComponents.hour ?? 0):\(diffDateComponents.minute ?? 0):\(diffDateComponents.second ?? 0)"
        
        let difference = calendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: releaseDate!)
        let countdown = String(format: "%02ld:%02ld:%02ld:%02ld", difference.day ?? 0 , difference.hour ?? 0, difference.minute ?? 0, difference.second!)
        
        timeLabel.text = countdown

    }
    
    @objc func stopRaffleTimer(){
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    override func prepareForReuse() {
        itemImage.image = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopRaffleTimer), name: .stopRaffleTimer, object: nil)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
