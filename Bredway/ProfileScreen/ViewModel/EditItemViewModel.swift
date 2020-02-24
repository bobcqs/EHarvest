//
//  EditItemViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 20/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import RxSwift
import Kingfisher

protocol EditItemViewModeling {
    var item: Item { get }
    
    // MARK: - Input
    var submitDidTap: PublishSubject<Void> { get }
    var editDidTap: PublishSubject<Void> { get }
    var deleteDidTap: PublishSubject<Void> { get }
    
    //Output
    var images: Array<UIImage> {get set}
    var photos: BehaviorSubject<[UIImage]> { get }
    var downloadedImage: Observable<UIImage> {get}
    var isPhotoNumberMaxed: Bool {get}
    
    //Category Pickerview datasource
    var category: Array<String> {get}
    var shoes: Array<String> { get }
    var clothing: Array<String> { get }
    var accessories: Array<String> { get }
    var categoryData: Array<[String]> { get }
    var selectedCategory: PublishSubject<String>{ get }
    
    //Brand Pickerview datasource
    var brand: Array<String> {get}
    var selectedBrand: PublishSubject<String>{ get }
    
    //Item Name
    var itemName: PublishSubject<String>{ get }
    
    //Size Pickerview datasource
    var sizeDict: Dictionary<String, [String]> {get}
    var size: Array<String>{ get set}
    var selectedSize: PublishSubject<String>{ get }
    var sizeCategory: Dictionary<String, String> {get}
    
    //Condition Pickerview datasource
    var conditions: Array<String>{get}
    var selectedCondition: PublishSubject<String>{ get }
    
    //Shipping
    var shippingEnabled: BehaviorSubject<Bool> { get }
    
    //Description
    var itemDescription: PublishSubject<String> { get }
    
    //Price
    var itemPrice: PublishSubject<Int> { get }
    
    //Seller paypal email
    var payPalEmail: PublishSubject<String> { get }
    
    var submissionResult: PublishSubject<SubmissionResult> {get}
    
    var delegate: SellViewImageDelegate? {get set}
    func addImage(image: UIImage)
    func deleteImage(index: Int)
}

class EditItemViewModel: EditItemViewModeling{
    
    let item: Item
    
    // MARK: - Input
    var submitDidTap: PublishSubject<Void> = PublishSubject<Void>()
    var editDidTap: PublishSubject<Void> = PublishSubject<Void>()
    var deleteDidTap: PublishSubject<Void> = PublishSubject<Void>()
    
    var images: Array<UIImage>
    var photos: BehaviorSubject<[UIImage]>
    var downloadedImage: Observable<UIImage>
    
    //check whether user selected 8 photos
    var isPhotoNumberMaxed: Bool
    
    //Category Pickerview datasource
    var category: Array<String>
    var shoes: Array<String>
    var clothing: Array<String>
    var accessories: Array<String>
    var categoryData: Array<[String]>
    var selectedCategory: PublishSubject<String> = PublishSubject<String>()
    
    //Brand Pickerview datasource
    var brand: Array<String>
    let selectedBrand: PublishSubject<String> = PublishSubject<String>()
    
    //item name
    let itemName: PublishSubject<String> = PublishSubject<String>()
    
    //Size Pickerview datasource
    var sizeDict: Dictionary<String, [String]>
    var size: Array<String> = [String]()
    let selectedSize: PublishSubject<String> = PublishSubject<String>()
    var sizeCategory: Dictionary<String, String>
    
    //Condition Pickerview datasource
    var conditions: Array<String>
    let selectedCondition: PublishSubject<String> = PublishSubject<String>()
    
    //Shipping
    let shippingEnabled: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: false)
    
    let itemDescription: PublishSubject<String> = PublishSubject<String>()
    let itemPrice: PublishSubject<Int> = PublishSubject<Int>()
    let payPalEmail: PublishSubject<String> = PublishSubject<String>()
    
    var submissionResult: PublishSubject<SubmissionResult> = PublishSubject<SubmissionResult>()
    
    weak var delegate: SellViewImageDelegate?
    
    private let disposeBag = DisposeBag()
    
    init(itemToBeEdited: Item, firebaseService: FirebaseServicing) {
        item = itemToBeEdited
        
        images = [UIImage]()
        if let image = UIImage(named: "plus"){
            images.append(image)
        }
        photos = BehaviorSubject<[UIImage]>(value: images)
        downloadedImage = firebaseService.downloadImagesFromUrl(imagesUrl: itemToBeEdited.imageUrls ?? [""])
        isPhotoNumberMaxed = false
        
        //Initialise category data
        category = ["Vegetables", "Fruits", "Others"]
        shoes = ["Broccoli", "Carrot", "Potato", "Onion", "Spinach", "Others"]
        clothing = ["Apple", "Banana", "Cherry", "Coconut", "Orange", "Others"]
        accessories = ["Cheese", "Honey", "Other"]
        categoryData = [shoes, clothing, accessories]
        
        //Initialise brand data
        brand = ["Berried", "Porta", "Tasman", "TopFlite", "Home Brand"]

        //Initialise size data
        sizeDict = [
            "Shoes" : [],
            // "Pants" : ["OS", "XXS", "XS", "S", "M", "L", "XL", "XXL"],
            "Clothing": ["OS", "XXS", "XS", "S", "M", "L", "XL", "XXL"],
            "Accessories": ["OS"]
        ]
        
        sizeCategory = [
            "Sneakers" : "Shoes",
            "T-shirt" : "Clothing",
            "Sweaters/Knitwear": "Clothing",
            "Hoodies" : "Clothing",
            "Jackets" : "Clothing",
            "Shirts" : "Clothing",
            "Pants" : "Clothing",
            "Hats" : "Accessories",
            "Bags" : "Accessories",
            "Other" : "Accessories"
        ]
        
        conditions = ["Frozen", "Fresh", "Sealed"]
        
        UserManager.shared.getLatestSellCategoryList { [weak self] (result, data) in
            if result == FirebaseQueryResult.error{
                logger.debug("Failed to get latest sell category data, using local storage one")
            } else {
                //Populate the data
                if let category = data["category"] as? [String] {
                    self?.category = category
                }
                if let shoes = data["shoes"] as? [String] {
                    self?.shoes = shoes
                }
                if let clothing = data["clothing"] as? [String] {
                    self?.clothing = clothing
                }
                if let accessories = data["accessories"] as? [String] {
                    self?.accessories = accessories
                }
                self?.categoryData = [self?.shoes, self?.clothing, self?.accessories] as! Array<[String]>
                
                if let brand = data["brand"] as? [String] {
                    self?.brand = brand
                }
                if let conditions = data["conditions"] as? [String] {
                    self?.conditions = conditions
                }
                if let sizeDict = data["sizeDict"] as? [String: [String]] {
                    self?.sizeDict = sizeDict
                }
                if let sizeCategory = data["sizeCategory"] as? [String: String] {
                    self?.sizeCategory = sizeCategory
                }
            }
        }
        
        let shippingText = item.shippingEnabled ?? ""
        shippingEnabled.onNext(shippingText == "Aus Nationwide")
        
        selectedCategory
            .map({ [weak self] itemType -> Array<String> in
                logger.debug("The selected type is \(itemType)")
                if let itemCategory = self?.sizeCategory[itemType]{
                    if let sizeArray = self?.sizeDict[itemCategory]{
                        return sizeArray
                    } else {
                        return [String]()
                    }
                } else {
                    return [String]()
                }
            })
            .subscribe(onNext: { [weak self] array in
                if array.isEmpty{
                    self?.size = ["Please select a category first"]
                } else {
                    self?.size = array
                }
                logger.debug("Size array is \(String(describing: self?.size))")
            })
            .disposed(by: disposeBag)
        
        let textfieldInfo = Observable.combineLatest(selectedCategory, selectedBrand, itemName, selectedSize, selectedCondition, itemDescription, itemPrice, payPalEmail){(
            category: String, brand: String, name: String, size: String, condition: String, itemDescription: String, price: Int, email: String) in
            
            SellingItem.init(category: category, brand: brand, name: name, size: size, condition: condition, itemDescription: itemDescription, price: price, email: email, shippingEnabled: nil, images: nil)
        }
        
        let itemInfo = Observable.combineLatest(textfieldInfo, shippingEnabled, photos){
            (sellingItem: SellingItem, shipping: Bool, images: [UIImage]) -> SellingItem in
            
            var item = sellingItem
            item.shippingEnabled = shipping
            item.images = images
            return item
        }
        
        submitDidTap
            .throttle(2, scheduler: MainScheduler.instance)
            .withLatestFrom(itemInfo)
            .flatMapLatest({ itemInfo -> Observable<SubmissionResult> in
                if itemInfo.isInputValid{
                    return firebaseService.uploadItem(item: itemInfo)
                } else {
                    return Observable.just(SubmissionResult.invalidInput)
                }
            })
            .bind(to: submissionResult)
            .disposed(by: disposeBag)
        
        editDidTap
            .throttle(2, scheduler: MainScheduler.instance)
            .withLatestFrom(itemInfo)
            .flatMapLatest({ itemInfo -> Observable<SubmissionResult> in
                if itemInfo.isInputValid{
                    return firebaseService.editItem(itemId: itemToBeEdited.itemId ?? "", item: itemInfo)
                } else {
                    return Observable.just(SubmissionResult.invalidInput)
                }
            })
            .bind(to: submissionResult)
            .disposed(by: disposeBag)
        
        deleteDidTap
            .throttle(2, scheduler: MainScheduler.instance)
            .flatMapLatest({ _ -> Observable<SubmissionResult> in
                return firebaseService.deleteItem(itemId: itemToBeEdited.itemId ?? "")
            })
            .bind(to: submissionResult)
            .disposed(by: disposeBag)
        
        downloadedImage
            .subscribe(onNext: { [weak self] (image) in
                self?.addImage(image: image)
            })
            .disposed(by: disposeBag)
    }
    
    func addImage(image: UIImage){
        print ("Received image")
        if images.count >= 1 {
            images.insert(image, at: images.count - 1)
            if images.count >= 9 {
                images.removeLast()
                isPhotoNumberMaxed = true
            }
            photos.onNext(images)
            delegate?.addImageFinished()
        }
        
    }
    
    func deleteImage(index: Int) {
        if images.count >= 1 {
            images.remove(at: index)
        }
        if isPhotoNumberMaxed {
            if let image = UIImage(named: "addImage"){
                images.append(image)
                isPhotoNumberMaxed = false
            }
        }
        photos.onNext(images)
        delegate?.deleteImageFinished()
    }

}
