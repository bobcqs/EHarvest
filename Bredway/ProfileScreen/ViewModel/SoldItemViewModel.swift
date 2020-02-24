//
//  SoldItemViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 30/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import RxSwift

protocol SoldItemViewModeling {
    var items: PublishSubject<[SoldItem]> {get}
    var firebaseService: FirebaseServicing {get}
    var selectedItem: PublishSubject<SoldItem> {get}
    var presentChatroom: Observable<ChatroomViewModeling> {get}
    
    func getListingItems()
}

class SoldItemViewModel: SoldItemViewModeling{
    let items: PublishSubject<[SoldItem]> = PublishSubject<[SoldItem]>()
    let firebaseService: FirebaseServicing
    let selectedItem: PublishSubject<SoldItem> = PublishSubject<SoldItem>()
    let presentChatroom: Observable<ChatroomViewModeling>
    private let disposeBag = DisposeBag()
    init(firebaseService: FirebaseServicing) {
        
        presentChatroom = selectedItem
            .map({ item in
                let firebaseChatroomService = FirebaseChatroomService()
                let buddyId = item.buyerId ?? ""
                let imageUrls = item.imageUrls ?? [String]()
                let chatroomViewModel = ChatroomViewModel(firebaseChatroomService: firebaseChatroomService, buddyId: buddyId, itemImageUrl: imageUrls.count > 0 ? imageUrls[0] : "", isBuyer: false)
                return chatroomViewModel
            })
        
        self.firebaseService = firebaseService
        getListingItems()
    }
    
    func getListingItems(){
        firebaseService.getMySoldItems(userId: UserManager.shared.currentUserId)
            .share(replay: 1)
            .subscribe(onNext: { [weak self] (retrievedItems) in
                self?.items.onNext(retrievedItems)
            })
            .disposed(by: disposeBag)
    }
    
}
