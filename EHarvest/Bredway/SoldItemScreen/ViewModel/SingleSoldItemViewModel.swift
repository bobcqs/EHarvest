//
//  ItemViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 12/5/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import RxSwift

protocol SingleSoldItemViewModeling {
    var itemId: String {get}
    var imageUrls: [String] {get}
    var timeStamp: String {get}
    //var isFavourite: Bool {get}
    var brand: String {get}
    var itemName: String {get}
    var price: Int {get}
    var itemDescription: String {get}
    var shippingLabel:String {get}
    var sellerId: String {get}
    var sellerRating: String {get}
    var sellerEmail: PublishSubject<String> {get}
    var sellerName: PublishSubject<String> {get}
    var sellerImageUrl: PublishSubject<String> {get}
}

class SingleSoldItemViewModel: SingleSoldItemViewModeling{
    let itemId: String
    let imageUrls: [String]
    let timeStamp: String
    //let isFavourite: Bool
    let brand: String
    let itemName: String
    let price: Int
    let itemDescription: String
    let shippingLabel: String
    let sellerId: String
    let sellerRating: String
    let sellerEmail: PublishSubject<String> = PublishSubject<String>()
    let sellerName: PublishSubject<String> = PublishSubject<String>()
    let sellerImageUrl: PublishSubject<String> = PublishSubject<String>()
    
    private let disposeBag = DisposeBag()
    
    init(item: SoldItem, firebaseService: FirebaseServicing) {
        itemId = item.itemId ?? ""
        imageUrls = item.imageUrls ?? [String]()
        timeStamp = item.timeStamp ?? ""
        //isFavourite = UserManager.shared.isFavouriteItem(itemId: item.itemId ?? "")
        brand = item.brand ?? ""
        itemName = item.name ?? ""
        price = item.price ?? 0
        itemDescription = item.itemDescription ?? ""
        shippingLabel = item.shippingEnabled ?? ""
        sellerRating = item.sellerRating ?? ""
        sellerId = item.sellerId ?? ""
        
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
