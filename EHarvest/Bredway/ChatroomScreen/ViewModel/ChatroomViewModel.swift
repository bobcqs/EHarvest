//
//  ChatroomViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 9/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import RxSwift
import MessageKit

protocol ChatroomDelegate: class{
    func messageListDidUpdate()
    func didLoadMoreMessages()
}

protocol ChatroomViewModeling {
    var initiationResult: PublishSubject<FirebaseQueryResult> {get}
    
    var buddyImageUrl: String {get}
    var buddyDisplayName: String {get}
    var buddyEmail: String {get}
    var messageList: BehaviorSubject<[Message]> {get}
    var messages: [Message] {get}
    var uploadMessage: PublishSubject<Message> {get}
    var uploadMessageResult: PublishSubject<FirebaseQueryResult> {get}
    var loadMoreMessageTrigger: PublishSubject<Void> {get}
    var shouldUpdateHasReadMessage: PublishSubject<Void>{get}
    var delegate: ChatroomDelegate? {get set}

}

class ChatroomViewModel: ChatroomViewModeling{
    
    let initiationResult: PublishSubject<FirebaseQueryResult> = PublishSubject<FirebaseQueryResult>()

    var buddyImageUrl: String = ""
    var buddyDisplayName: String = ""
    var buddyEmail: String = ""
    var messageList: BehaviorSubject<[Message]> = BehaviorSubject<[Message]>(value: [])
    var messages: [Message] = [Message]()
    var uploadMessage: PublishSubject<Message> = PublishSubject<Message>()
    var uploadMessageResult: PublishSubject<FirebaseQueryResult> = PublishSubject<FirebaseQueryResult>()
    let loadMoreMessageTrigger: PublishSubject<Void> = PublishSubject<Void>()
    let shouldUpdateHasReadMessage: PublishSubject<Void> = PublishSubject<Void>()
    
    var delegate: ChatroomDelegate?
    
    private let disposeBag = DisposeBag()
    
    init(firebaseChatroomService: FirebaseChatroomServicing, buddyId: String, itemImageUrl: String, isBuyer: Bool) {
        let result = firebaseChatroomService.initiateChatroom(buddyId: buddyId, itemImageUrl: itemImageUrl, isBuyer: isBuyer)
            .share(replay: 1)
        
        //obtain buddy info
        let buddyInfoResult = result
            .flatMapLatest { (result) -> Observable<(FirebaseQueryResult, [String: Any])> in
                if result == FirebaseQueryResult.error{
                    return Observable.just((FirebaseQueryResult.error, Dictionary<String, Any>()))
                } else {
                    return firebaseChatroomService.getPersonInfo(personId: buddyId)
                }
            }
            .map { [weak self] (result, userInfo) -> FirebaseQueryResult in
                if result == FirebaseQueryResult.error{
                    logger.debug("Failed to obtain user information")
                    return FirebaseQueryResult.error
                } else {
                    if let imageUrl = userInfo[MasterConstants.PROFILE_IMAGE_URL]  {
                        self?.buddyImageUrl = imageUrl as! String
                    }
                    if let name = userInfo[MasterConstants.PROFILE_NAME] {
                        self?.buddyDisplayName = name as! String
                    }
                    if let email = userInfo[MasterConstants.PROFILE_EMAIL]{
                        self?.buddyEmail = email as! String
                    }
                    return FirebaseQueryResult.success
                }
            }
        
        //obtain messages
        //let chatroomId = isBuyer ? UserManager.shared.currentUserId + buddyId : buddyId + UserManager.shared.currentUserId
        let chatroomId: String
        if UserManager.shared.currentUserId < buddyId{
            chatroomId = UserManager.shared.currentUserId + buddyId
        } else {
            chatroomId = buddyId + UserManager.shared.currentUserId
        }
        
        buddyInfoResult
            .flatMapLatest({ (result) -> Observable<(FirebaseQueryResult, [Message])> in
                if result == FirebaseQueryResult.success{
                    return firebaseChatroomService.getInitialMessagesFromChatroom(chatroomId: chatroomId, pagination: 20)
                } else {
                    return Observable.just((FirebaseQueryResult.error, [Message]()))
                }
            })
            .withLatestFrom(messageList) { (data, messageArray) in
                return (data, messageArray)
            }
            .subscribe(onNext: { [weak self] (data, messageArray) in
                let (result, newMessageList) = data
                var messageList = messageArray
                if result == FirebaseQueryResult.error{
                    logger.debug("Failed to retrieve message item, the message may not exist")
                } else {
                    let sortedMessages = newMessageList.sorted(by: { $0.timeStamp < $1.timeStamp })
                    messageList.insert(contentsOf: sortedMessages, at: 0)
                    self?.messageList.onNext(messageList)
                    self?.messages = messageList
                    print ("why : \(messageList.count)")
                    self?.delegate?.messageListDidUpdate()
                }
            })
            .disposed(by: disposeBag)
        
        loadMoreMessageTrigger
            .flatMap { _ -> Observable<(FirebaseQueryResult, [Message])> in
                return firebaseChatroomService.getMessagesWithPaginaton(chatroomId: chatroomId, pagination: 20)
            }
            .withLatestFrom(messageList) { (data, messageArray) in
                return (data, messageArray)
            }
            .subscribe(onNext: { [weak self] (data, messageArray) in
                let (result, newMessageList) = data
                var messageList = messageArray
                if result == FirebaseQueryResult.error{
                    logger.debug("Failed to retrieve message item, the message may not exist")
                } else {
                    let sortedMessages = newMessageList.sorted(by: { $0.timeStamp < $1.timeStamp })
                    messageList.insert(contentsOf: sortedMessages, at: 0)
                    self?.messageList.onNext(messageList)
                    self?.messages = messageList
                    self?.delegate?.didLoadMoreMessages()
                }
            })
            .disposed(by: disposeBag)
        
        firebaseChatroomService.observeNewMessageFromChatroom(chatroomId: chatroomId)
            .withLatestFrom(messageList) { (data, messageArray) in
                return (data, messageArray)
            }
            .subscribe(onNext: { [weak self] (data, messageArray) in
                let (result, newMessage) = data
                var messageList = messageArray
                if result == FirebaseQueryResult.error{
                    logger.debug("Failed to retrieve message item, the message may not exist")
                } else {
                    messageList.append(newMessage)
                    self?.messageList.onNext(messageList)
                    self?.messages = messageList
                    self?.shouldUpdateHasReadMessage.onNext(())
                    self?.delegate?.messageListDidUpdate()
                }
            })
            .disposed(by: disposeBag)
        
        shouldUpdateHasReadMessage
            .flatMapLatest { _ -> Observable<FirebaseQueryResult> in
                return firebaseChatroomService.updateHasReadMessage(userId: UserManager.shared.currentUserId, chatroomId: chatroomId)
            }
            .subscribe(onNext: { (result) in
                if result == FirebaseQueryResult.error {
                    logger.debug("Successfully updated has read message data")
                }
            })
            .disposed(by: disposeBag)
        
        uploadMessage
            .flatMap { (message) -> Observable<FirebaseQueryResult> in
                return firebaseChatroomService.addMessage(chatroomId: chatroomId, myId: UserManager.shared.currentUserId, buddyId: buddyId, message: message, isBuyer: isBuyer)
            }
            .subscribe(onNext: { [weak self] (result) in
                self?.uploadMessageResult.onNext(result)
            })
            .disposed(by: disposeBag)

    }
    
    func updateHasReadMessage(userId: String){
        
    }

}
