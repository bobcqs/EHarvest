//
//  InboxTableViewCell.swift
//  Bredway
//
//  Created by Xudong Chen on 17/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

class InboxTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var unreadMessageImageView: RedDotView!
    

    let firebaseChatroomService = FirebaseChatroomService()
    private var disposeBag: DisposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(chatroom: Chatroom){
        
        // 1. display old data, 2. get new data from buddy 3. update buddy new data to replace old data
        let profileImageUrl = chatroom.buddyProfileImageUrl ?? ""
        let buddyDisplayName = chatroom.buddyDisplayName ?? ""
        if let url = URL(string: profileImageUrl){
            profileImageView.kf.setImage(with: url)
        }
        nameLabel.text = buddyDisplayName
        
        let buddyId = chatroom.buddyId ?? ""
        let chatroomId = chatroom.chatroomId ?? ""
        if let buddyInfoTimeStamp = chatroom.buddyInfoTimeStamp{
            let minuteDiff = TimeStampHelper.shared.getMinuteDifference(timeStamp: Int(buddyInfoTimeStamp)!)
            if minuteDiff > 1 {
                getAndUpdateBuddyInfo(buddyId: buddyId, chatroomId: chatroomId)
            }
        } else if (profileImageUrl.isEmpty && buddyDisplayName.isEmpty){
            getAndUpdateBuddyInfo(buddyId: buddyId, chatroomId: chatroomId)
        }
        
        if let timeStamp = chatroom.timeStamp {
            timeLabel.text = TimeStampHelper.shared.getTime(timeStamp: Int(timeStamp)!)
        } else {
            timeLabel.text = ""
        }
        lastMessageLabel.text = chatroom.lastMessage
        if let itemImageUrl = URL(string: chatroom.itemImageUrl ?? ""){
            itemImageView.kf.setImage(with: itemImageUrl)
        }
        if let hasUnreadMessage = chatroom.hasUnreadMessage{
            unreadMessageImageView.isHidden = !hasUnreadMessage
        } else {
            unreadMessageImageView.isHidden = true
        }
    }
    
    func getAndUpdateBuddyInfo(buddyId: String, chatroomId: String){
        firebaseChatroomService.getPersonInfo(personId: buddyId)
            .flatMapFirst { [weak self] (result, userInfo) -> Observable<FirebaseQueryResult> in
                if result == FirebaseQueryResult.error{
                    logger.debug("Failed to obtain user information")
                    return Observable.just(FirebaseQueryResult.error)
                } else {
                    var buddySubmitData = [String: Any]()
                    if let imageUrl = userInfo[MasterConstants.PROFILE_IMAGE_URL]  {
                        buddySubmitData["buddyProfileImageUrl"] = imageUrl
                        if let url = URL(string: imageUrl as! String){
                            self?.profileImageView.kf.setImage(with: url)
                        }
                    }
                    if let name = userInfo[MasterConstants.PROFILE_NAME] {
                        buddySubmitData["buddyDisplayName"] = name
                        self?.nameLabel.text = name as? String
                    }
                    buddySubmitData["buddyInfoTimeStamp"] = "\(Int(Date().timeIntervalSince1970))"
                    return (self?.firebaseChatroomService.updateBuddyInfo(chatroomId: chatroomId, buddyInfo: buddySubmitData))!
                }
            }
            .subscribe(onNext: { (result) in
                if result == FirebaseQueryResult.error {
                    logger.debug("Failed to update buddy info")
                } else {
                    logger.debug("Successfully updated buddy info")
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        profileImageView.image = nil
        itemImageView.image = nil
        
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }

}
