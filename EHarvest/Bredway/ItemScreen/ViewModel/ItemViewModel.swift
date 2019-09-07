//
//  ItemViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 12/5/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import RxSwift

protocol ItemViewModeling {
    var itemId: String {get}
    var imageUrls: [String] {get}
    var timeStamp: String {get}
    var isFavourite: Bool {get}
    var brand: String {get}
    var itemName: String {get}
    var itemSize: String {get}
    var price: Int {get}
    var itemDescription: String {get}
    var shippingLabel:String {get}
    var sellerId: String {get}
    var sellerRating: String {get}
    var isSold: Bool {get}
    var sellerPayPalEmail: BehaviorSubject<String> {get}
    var sellerEmail: PublishSubject<String> {get}
    var sellerName: PublishSubject<String> {get}
    var sellerImageUrl: PublishSubject<String> {get}
    var heartButtonPressed: PublishSubject<Void> {get}
    var purchaseButtonPressed: PublishSubject<Void> {get}
    var askButtonPressed: PublishSubject<Void> {get}
    var editButtonPressed: PublishSubject<Void> {get}
    var presentPayment: Observable<PaymentViewModeling> {get}
    var presentChatroom: Observable<ChatroomViewModeling> {get}
    var presentEditItem: Observable<EditItemViewModeling> {get}
}

class ItemViewModel: ItemViewModeling{
    let itemId: String
    let imageUrls: [String]
    let timeStamp: String
    let isFavourite: Bool
    let brand: String
    let itemName: String
    let itemSize: String
    let price: Int
    let itemDescription: String
    let shippingLabel: String
    let sellerId: String
    let sellerRating: String
    let isSold: Bool
    let sellerPayPalEmail: BehaviorSubject<String>
    let sellerEmail: PublishSubject<String> = PublishSubject<String>()
    let sellerName: PublishSubject<String> = PublishSubject<String>()
    let sellerImageUrl: PublishSubject<String> = PublishSubject<String>()
    let heartButtonPressed: PublishSubject<Void> = PublishSubject<Void>()
    let purchaseButtonPressed: PublishSubject<Void> = PublishSubject<Void>()
    let askButtonPressed: PublishSubject<Void> = PublishSubject<Void>()
    let editButtonPressed: PublishSubject<Void> = PublishSubject<Void>()
    let presentPayment: Observable<PaymentViewModeling>
    let presentChatroom: Observable<ChatroomViewModeling>
    let presentEditItem: Observable<EditItemViewModeling>
    
    private let disposeBag = DisposeBag()
    
    init(item: Item, firebaseService: FirebaseServicing) {
        itemId = item.itemId ?? ""
        imageUrls = item.imageUrls ?? [String]()
        timeStamp = item.timeStamp ?? ""
        isFavourite = UserManager.shared.isFavouriteItem(itemId: item.itemId ?? "")
        brand = item.brand ?? ""
        itemName = item.name ?? ""
        itemSize = item.size ?? ""
        price = item.price ?? 0
        itemDescription = item.itemDescription ?? ""
        shippingLabel = item.shippingEnabled ?? ""
        sellerRating = item.sellerRating ?? ""
        sellerId = item.sellerId ?? ""
        isSold = item.isSold ?? false
        sellerPayPalEmail = BehaviorSubject<String>(value: item.email ?? "")
        
        heartButtonPressed
            .flatMap { () -> Observable<(FirebaseQueryResult, [String: Bool])> in
                let favouriteList = UserManager.shared.currentUserFavouriteList
                if let itemId = item.itemId{
                    if UserManager.shared.isFavouriteItem(itemId: itemId){
                        return firebaseService.removeItemFromFavouriteList(itemId: itemId, submitData: favouriteList)
                    } else {
                        return firebaseService.addItemToFavouriteList(itemId: itemId, submitData: favouriteList)
                    }
                }
                return Observable.just((FirebaseQueryResult.error, favouriteList))
            }
            .subscribe(onNext: { (result, list) in
                UserManager.shared.currentUserFavouriteList = list
            })
            .disposed(by: disposeBag)
        
        presentPayment = purchaseButtonPressed
            .withLatestFrom(sellerPayPalEmail){ (_, email) in
                (email)
            }
            .map({ email in
                let payPalService = PayPalService(network: Networkservice())
                    let paymentViewModel = PaymentViewModel(sellerEmail: email, item: item, payPalService: payPalService)
                    return paymentViewModel
            })
        
        presentChatroom = askButtonPressed
            .map({ _ in
                let firebaseChatroomService = FirebaseChatroomService()
                let buddyId = item.sellerId ?? ""
                let imageUrls = item.imageUrls ?? [String]()
                let chatroomViewModel = ChatroomViewModel(firebaseChatroomService: firebaseChatroomService, buddyId: buddyId, itemImageUrl: imageUrls.count > 0 ? imageUrls[0] : "", isBuyer: true)
                return chatroomViewModel
            })
        
        presentEditItem = editButtonPressed
            .map({ _ in
                let editItemViewModel = EditItemViewModel(itemToBeEdited: item, firebaseService: firebaseService)
                return editItemViewModel
            })
        
        firebaseService.getSellerInfo(sellerId: item.sellerId ?? "")
            .subscribe(onNext: { [weak self] (result, data) in
                switch result{
                case .success:
                    if let imageUrl = data[MasterConstants.PROFILE_IMAGE_URL]  {
                        self?.sellerImageUrl.onNext(imageUrl as! String)
                    }
                    if let name = data[MasterConstants.PROFILE_NAME] {
                        self?.sellerName.onNext(name as! String)
                    }
                    if let email = data[MasterConstants.PROFILE_EMAIL]{
                        self?.sellerEmail.onNext(email as! String)
                    }
                    break
                case .error:
                    logger.debug("Firebase query failed for get seller information")
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
    }
}
