//
//  InboxViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 17/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import RxSwift

protocol InboxViewModeling {
    var chatrooms: PublishSubject<[Chatroom]> {get}
    var firebaseChatroomService: FirebaseChatroomService {get}
    var selectedChatroom: PublishSubject<Chatroom> {get}
    var presentChatroom: Observable<ChatroomViewModeling> {get}
    func getChatroomList()
}

class InboxViewModel: InboxViewModeling{
    let chatrooms: PublishSubject<[Chatroom]> = PublishSubject<[Chatroom]>()
    let firebaseChatroomService: FirebaseChatroomService
    let selectedChatroom: PublishSubject<Chatroom> = PublishSubject<Chatroom>()
    let presentChatroom: Observable<ChatroomViewModeling>
    private let disposeBag = DisposeBag()
    
    init(firebaseChatroomService: FirebaseChatroomService) {
        
    presentChatroom = selectedChatroom
        .map({ chatroom in
            let buddyId = chatroom.buddyId ?? ""
            let buyerId = chatroom.buyerId ?? ""
            let imageUrl = chatroom.itemImageUrl ?? ""
            let isBuyer = buddyId == buyerId ? false : true
            let chatroomViewModel = ChatroomViewModel(firebaseChatroomService: firebaseChatroomService, buddyId: buddyId, itemImageUrl: imageUrl, isBuyer: isBuyer)
            return chatroomViewModel
        })
        
        self.firebaseChatroomService = firebaseChatroomService
        if UserManager.shared.isLoggedIn{
            getChatroomList()
        }
    }
    
    func getChatroomList() {
        firebaseChatroomService.getChatroomList(userId: UserManager.shared.currentUserId)
            .share(replay: 1)
            .subscribe(onNext: { [weak self] (retrievedItems) in
                self?.chatrooms.onNext(retrievedItems)
            })
            .disposed(by: disposeBag)
    }
    
}
