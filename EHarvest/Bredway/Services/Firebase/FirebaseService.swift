//
//  FirebaseStorageService.swift
//  Bredway
//
//  Created by Xudong Chen on 30/4/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import RxSwift
import Firebase
import Kingfisher

protocol FirebaseServicing {
    func uploadProfileImage(image: UIImage) -> Observable<(FirebaseQueryResult, String)>
    func updateImageFromImages(index: Int, imagesCount: Int, uploadCount: Int, images: [UIImage], imageUrls: [String], completion: @escaping (FirebaseQueryResult, [String]) -> ()) -> Void
    func uploadImages(images: [UIImage], completion: @escaping (FirebaseQueryResult, [String]) -> ()) -> Void
    func downloadImage(urlString: String) -> UIImage
    func downloadImagesForItem(itemId: String) -> [UIImage]
    func downloadImagesFromUrl(imagesUrl: [String]) -> Observable<UIImage>
    func editItem(itemId: String, item: SellingItem) -> Observable<SubmissionResult>
    func editItemInfo(itemId: String, item: SellingItem, imageUrls: [String], completion: @escaping (FirebaseQueryResult) -> ())
    func uploadItem(item: SellingItem) -> Observable<SubmissionResult>
    func uploadItemInfo(item: SellingItem, imageUrls: [String], completion: @escaping (FirebaseQueryResult) -> ())
    func deleteItem(itemId: String) -> Observable<SubmissionResult>
    func getItems(paginationLimit limit: Int) -> Observable<[Item]>
    func getNextItems(paginationLimit limit: Int) -> Observable<[Item]>
    func addItemToFavouriteList(itemId: String, submitData: [String: Bool]) -> Observable<(FirebaseQueryResult, [String: Bool])>
    func removeItemFromFavouriteList(itemId: String, submitData: [String: Bool]) -> Observable<(FirebaseQueryResult, [String: Bool])>
    func getSellerInfo(sellerId: String) -> Observable<(FirebaseQueryResult, [String: Any])>
    func getMyListingItems(userId: String) -> Observable<[Item]>
    func getMySoldItems(userId: String) -> Observable<[SoldItem]>
    func getMyPurchasedItems(userId: String) -> Observable<[SoldItem]>
    func getItemsFromList(list: [String]) -> Observable<(FirebaseQueryResult,Item)>
    func updateShipment(soldItemId: String, buyerId: String, courierCompany: String, trackingNumber: String) -> Observable<SubmissionResult>
    //Method when payment is successful
    func savePaidItem(item: Item, buyerName: String, buyerAddress: String)-> Observable<FirebaseQueryResult>
    
    //Main Slider methos
    func getSliders() -> Observable<MainSlider>
    func getAllRetailSliders() -> Observable<[RetailSlider]>
    func getAllGiveAwaySliders() -> Observable<[RetailSlider]>
}

class FirebaseService: FirebaseServicing {
    
    private let storageRef = Storage.storage().reference()
    private let firestoreDb = Firestore.firestore()
    private var lastSnapshot: QueryDocumentSnapshot?
    
    func uploadProfileImage(image: UIImage) -> Observable<(FirebaseQueryResult, String)>{
        return Observable.create { observer in
            if let imageData = UIImageJPEGRepresentation(image, 0.5){
                let filename = UUID().uuidString
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                let firRef = self.storageRef.child("\(UserManager.shared.currentUserId)/\(FilePath.FIREBASE_STORAGE_PROFILE)/\(FilePath.FIREBASE_STORAGE_PROFILE_IMAGE)/\(filename)")
                firRef.putData(imageData, metadata: metadata, completion: { (metaData, error) in
                    if let err = error {
                        logger.debug("Cannot upload individual file and error is \(err)")
                        observer.onNext((FirebaseQueryResult.error, ""))
                    } else {
                        if let url = metaData?.downloadURL()?.absoluteString{
                            observer.onNext((FirebaseQueryResult.success, url))
                        }
                    }
                })
            }
            return Disposables.create()
        }
    }
    
    func updateImageFromImages(index: Int, imagesCount: Int, uploadCount: Int, images: [UIImage], imageUrls: [String], completion: @escaping (FirebaseQueryResult, [String]) -> ()){
        if index < imagesCount{
            let uploadImage = images[index]
            var imageUrls = imageUrls
           // uploadImage.resizeWithPercentage(percentage: 0.5)
            if let imageData = UIImageJPEGRepresentation(uploadImage, 0.4){
                let filename = UUID().uuidString
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                let firRef = storageRef.child("\(UserManager.shared.currentUserId)/\(FilePath.FIREBASE_STORAGE_LISTING)/\(filename)")
                firRef.putData(imageData, metadata: metadata, completion: { (metaData, error) in
                    if let err = error {
                        logger.debug("Cannot upload individual file and error is \(err)")
                        completion(FirebaseQueryResult.error, [String]())
                    } else {
                        if let url = metaData?.downloadURL()?.absoluteString{
                            imageUrls.append(url)
                            self.updateImageFromImages(index: index + 1, imagesCount: imagesCount, uploadCount: uploadCount, images: images, imageUrls:imageUrls, completion: completion)
                        }
                    }
                })
            }
            return
        }
        
        completion(FirebaseQueryResult.success, imageUrls)

    }
    
    func uploadImages(images: [UIImage], completion: @escaping (FirebaseQueryResult,[String]) -> ()) {
        let imageUrls = [String]()
        let uploadCount = 0
        let imagesCount = images.count > 8 ? 8 : (images.count > 1 ? images.count - 1 : images.count)
        
        updateImageFromImages(index: 0, imagesCount: imagesCount, uploadCount: uploadCount, images: images, imageUrls: imageUrls) { (result, urlArray) in
            completion(result, urlArray)
        }
        
        
    }
    
    func downloadImage(urlString: String) -> UIImage {
        return UIImage()
    }
    
    func downloadImagesForItem(itemId: String) -> [UIImage] {
        return [UIImage]()
    }
    
    func downloadImagesFromUrl(imagesUrl: [String]) -> Observable<UIImage> {
        return Observable.create { observer in
            
            for imageUrl in imagesUrl{
                if let url = URL(string: imageUrl){
                    ImageDownloader.default.downloadImage(with: url, retrieveImageTask: nil, options: [], progressBlock:nil, completionHandler: { (downloadedImage, error, url, data) in
                        if let err = error {
                            logger.debug("Failed to download image because \(err)")
                        } else {
                            ImageCache.default.store(downloadedImage!, forKey: imageUrl)
                            observer.onNext(downloadedImage!)
                        }
                    })
                }
            }
            
            return Disposables.create()
        }
    }
    
    func editItem(itemId: String, item: SellingItem) -> Observable<SubmissionResult> {
        return Observable.create { observer in
            
            let images = item.images ?? [UIImage]()
            self.uploadImages(images: images, completion: { (result, imageUrls) in
                switch result{
                case .success:
                    logger.debug("Successfully uploaded item images for item")
                    self.editItemInfo(itemId: itemId, item: item, imageUrls: imageUrls, completion: { (result) in
                        switch result{
                        case .success:
                            logger.debug("Successfully uploaded item information to Firebase")
                            observer.onNext(SubmissionResult.submissionSuccess)
                            break
                        case .error:
                            logger.debug("Failed to upload item information to Firebase")
                            observer.onNext(SubmissionResult.submissionError)
                            break
                        default:
                            break
                        }
                    })
                    break
                case .error:
                    logger.debug("Failed to upload item images to Firebase")
                    observer.onNext(SubmissionResult.submissionError)
                default:
                    break
                }
            })
            
            return Disposables.create()
        }
    }
    
    func editItemInfo(itemId: String, item: SellingItem, imageUrls: [String], completion: @escaping (FirebaseQueryResult) -> ()) {
        let userId = UserManager.shared.currentUserId
        var submitData = item.firebaseDictionary
        submitData["sellerId"] = userId
        submitData["lastUpdated"] = FieldValue.serverTimestamp()
        submitData["timeStamp"] = "\(Int(Date().timeIntervalSince1970))"
        submitData["imageUrls"] = imageUrls
        submitData["sellerImageUrl"] = UserManager.shared.currentUserImageUrl
        submitData["itemId"] = itemId
        
        let batch = firestoreDb.batch()
        let itemRef = firestoreDb.collection(FilePath.FIREBASE_ITEMS).document(itemId)
        batch.setData(submitData, forDocument: itemRef)
        
        let userRef = firestoreDb.collection(FilePath.FIREBASE_USERS).document(userId).collection(FilePath.FIREBASE_LISTING).document(itemRef.documentID)
        batch.setData(submitData, forDocument: userRef)
        
        batch.commit { (error) in
            if let err = error {
                logger.debug("Failed to perform batched writes and error is \(err)")
                completion(FirebaseQueryResult.error)
            } else {
                logger.debug("Successully performed batched writes")
                completion(FirebaseQueryResult.success)
            }
        }
    }
    
    func uploadItem(item: SellingItem) -> Observable<SubmissionResult> {
        return Observable.create { observer in
            
            let images = item.images ?? [UIImage]()
            self.uploadImages(images: images, completion: { (result, imageUrls) in
                switch result{
                case .success:
                    logger.debug("Successfully uploaded item images for item")
                    self.uploadItemInfo(item: item, imageUrls: imageUrls, completion: { (result) in
                        switch result{
                        case .success:
                            logger.debug("Successfully uploaded item information to Firebase")
                            observer.onNext(SubmissionResult.submissionSuccess)
                            break
                        case .error:
                            logger.debug("Failed to upload item information to Firebase")
                            observer.onNext(SubmissionResult.submissionError)
                            break
                        default:
                            break
                        }
                    })
                    break
                case .error:
                    logger.debug("Failed to upload item images to Firebase")
                    observer.onNext(SubmissionResult.submissionError)
                default:
                    break
                }
            })
            
            return Disposables.create()
            }
    }
    
    func uploadItemInfo(item: SellingItem, imageUrls: [String], completion: @escaping (FirebaseQueryResult) -> ()) {
        
        let userId = UserManager.shared.currentUserId
        var submitData = item.firebaseDictionary
        submitData["sellerId"] = userId
        submitData["lastUpdated"] = FieldValue.serverTimestamp()
        submitData["timeStamp"] = "\(Int(Date().timeIntervalSince1970))"
        submitData["imageUrls"] = imageUrls
        submitData["sellerImageUrl"] = UserManager.shared.currentUserImageUrl
        
        let batch = firestoreDb.batch()
        let itemRef = firestoreDb.collection(FilePath.FIREBASE_ITEMS).document()
        
        submitData["itemId"] = itemRef.documentID
        
        batch.setData(submitData, forDocument: itemRef)
        
        let userRef = firestoreDb.collection(FilePath.FIREBASE_USERS).document(userId).collection(FilePath.FIREBASE_LISTING).document(itemRef.documentID)
        batch.setData(submitData, forDocument: userRef)
        
        batch.commit { (error) in
            if let err = error {
                logger.debug("Failed to perform batched writes and error is \(err)")
                completion(FirebaseQueryResult.error)
            } else {
                logger.debug("Successully performed batched writes")
                completion(FirebaseQueryResult.success)
            }
        }
    }
    
    func deleteItem(itemId: String) -> Observable<SubmissionResult> {
        return Observable.create { observer in
            let userId = UserManager.shared.currentUserId
            
            let batch = self.firestoreDb.batch()
            let itemRef = self.firestoreDb.collection(FilePath.FIREBASE_ITEMS).document(itemId)
            batch.deleteDocument(itemRef)
            
            let listingItemRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(userId).collection(FilePath.FIREBASE_LISTING).document(itemRef.documentID)
            batch.deleteDocument(listingItemRef)
            
            batch.commit { (error) in
                if let err = error {
                    logger.debug("Failed to perform batched writes and error is \(err)")
                    observer.onNext(SubmissionResult.submissionError)
                } else {
                    logger.debug("Successully performed batched writes")
                    observer.onNext(SubmissionResult.submissionSuccess)
                }
                observer.onCompleted()
            }
            
            return Disposables.create {
            }
        }
    }
    
    func getItems(paginationLimit limit: Int) -> Observable<[Item]> {
        return Observable.create { observer in
            let itemsRef = self.firestoreDb.collection(FilePath.FIREBASE_ITEMS).limit(to: limit)
            itemsRef.getDocuments(completion: { (snapshot, error) in
                if let err = error {
                    observer.onError(err)
                } else {
                    var itemArray = [Item]()
                    for element in (snapshot?.documents)!{
                        var jsonDict = element.data()
                        jsonDict["itemId"] = element.documentID
                        if let item = Item(JSON: jsonDict)
                        {
                            itemArray.append(item)
                        }
                    }
                    observer.onNext(itemArray)
                    if let lastDocument = snapshot?.documents.last{
                        self.lastSnapshot = lastDocument
                    }
                    observer.onCompleted()
                }
            })
            
            
            return Disposables.create {
            }
        }
    }
    
    func getNextItems(paginationLimit limit: Int) -> Observable<[Item]> {
        return Observable.create { observer in
            
            if let lastSnapshot = self.lastSnapshot{
                let itemsRef = self.firestoreDb.collection(FilePath.FIREBASE_ITEMS).limit(to: limit).start(afterDocument: lastSnapshot)
                itemsRef.getDocuments(completion: { (snapshot, error) in
                    if let err = error {
                        observer.onError(err)
                    } else {
                        var itemArray = [Item]()
                        for element in (snapshot?.documents)!{
                            var jsonDict = element.data()
                            jsonDict["itemId"] = element.documentID
                            if let item = Item(JSON: jsonDict)
                            {
                                itemArray.append(item)
                            }
                        }
                        observer.onNext(itemArray)
                        if let lastDocument = snapshot?.documents.last{
                            self.lastSnapshot = lastDocument
                        }
                        observer.onCompleted()
                    }
                })
            } else {
                observer.onError(NetworkError.Unknown)
            }
            
            return Disposables.create {
            }
        }
    }
    
    func getItemsFromList(list: [String]) -> Observable<(FirebaseQueryResult, Item)> {
        return Observable.create { observer in
            
            for itemId in list{
                let itemRef = self.firestoreDb.collection(FilePath.FIREBASE_ITEMS).document(itemId)
                itemRef.getDocument(completion: { (snapshot, error) in
                    if let _ = error {
                        observer.onNext((FirebaseQueryResult.error, Item()))
                    } else {
                        if let data = snapshot?.data(){
                            var jsonDict = data
                            jsonDict["itemId"] = snapshot?.documentID
                            if let item = Item(JSON: jsonDict)
                            {
                                observer.onNext((FirebaseQueryResult.success, item))
                            }
                        }
                    }
                })
            }
            //observer.onNext((FirebaseQueryResult.error, Item()))
            return Disposables.create {
            }
        }
    }
    
    func getMyListingItems(userId: String) -> Observable<[Item]> {
        return Observable.create { observer in
            let itemsRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(userId).collection(FilePath.FIREBASE_LISTING)
            itemsRef.getDocuments(completion: { (snapshot, error) in
                if let err = error {
                    observer.onError(err)
                } else {
                    var itemArray = [Item]()
                    for element in (snapshot?.documents)!{
                        var jsonDict = element.data()
                        jsonDict["itemId"] = element.documentID
                        if let item = Item(JSON: jsonDict)
                        {
                            itemArray.append(item)
                        }
                    }
                    observer.onNext(itemArray)
                    observer.onCompleted()
                }
            })
            
            
            return Disposables.create {
            }
        }
    }
    
    func getMySoldItems(userId: String) -> Observable<[SoldItem]> {
        return Observable.create { observer in
            let itemsRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(userId).collection(FilePath.FIREBASE_SOLD_ITIMES)
            itemsRef.getDocuments(completion: { (snapshot, error) in
                if let err = error {
                    observer.onError(err)
                } else {
                    var itemArray = [SoldItem]()
                    for element in (snapshot?.documents)!{
                        var jsonDict = element.data()
                        jsonDict["itemId"] = element.documentID
                        if let item = SoldItem(JSON: jsonDict)
                        {
                            itemArray.append(item)
                        }
                    }
                    observer.onNext(itemArray)
                    observer.onCompleted()
                }
            })
            
            
            return Disposables.create {
            }
        }
    }
    
    func getMyPurchasedItems(userId: String) -> Observable<[SoldItem]> {
        return Observable.create { observer in
            let itemsRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(userId).collection(FilePath.FIREBASE_PURCHASES)
            itemsRef.getDocuments(completion: { (snapshot, error) in
                if let err = error {
                    observer.onError(err)
                } else {
                    var itemArray = [SoldItem]()
                    for element in (snapshot?.documents)!{
                        var jsonDict = element.data()
                        jsonDict["itemId"] = element.documentID
                        if let item = SoldItem(JSON: jsonDict)
                        {
                            itemArray.append(item)
                        }
                    }
                    observer.onNext(itemArray)
                    observer.onCompleted()
                }
            })
            
            
            return Disposables.create {
            }
        }
    }
    
    func addItemToFavouriteList(itemId: String, submitData: [String: Bool]) -> Observable<(FirebaseQueryResult, [String: Bool])> {
        return Observable.create { observer in
            var submitData = submitData
            submitData[itemId] = true
            let listToSubmit = [FilePath.FIREBASE_FAVOURITE_LIST: submitData]
            let listRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(UserManager.shared.currentUserId)
            listRef.updateData(listToSubmit, completion: { (error) in
                if let err = error {
                    logger.debug("Failed to add item to favourite list for item: \(itemId) and error is: \(err)")
                    submitData.removeValue(forKey: itemId)
                    observer.onNext((FirebaseQueryResult.error, submitData))
                } else {
                    logger.debug("Successfully added item to favourite list for item: \(itemId)")
                    observer.onNext((FirebaseQueryResult.success, submitData))
                }
                observer.onCompleted()
            })
            return Disposables.create {
            }
        }
    }

    func removeItemFromFavouriteList(itemId: String, submitData: [String: Bool]) -> Observable<(FirebaseQueryResult, [String: Bool])> {
        return Observable.create { observer in
            var submitData = submitData
            submitData.removeValue(forKey: itemId)
            let listToSubmit = [FilePath.FIREBASE_FAVOURITE_LIST: submitData]
            let listRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(UserManager.shared.currentUserId)
            listRef.updateData(listToSubmit, completion: { (error) in
                if let err = error {
                    logger.debug("Failed to remove item from favourite list for item: \(itemId) and error is: \(err)")
                    submitData[itemId] = true
                    observer.onNext((FirebaseQueryResult.error, submitData))
                } else {
                    logger.debug("Successfully removed item from favourite list for item: \(itemId)")
                    observer.onNext((FirebaseQueryResult.success, submitData))
                }
                observer.onCompleted()
            })

            return Disposables.create {
            }
        }
    }
    
    func getSellerInfo(sellerId: String) -> Observable<(FirebaseQueryResult, [String : Any])> {
        return Observable.create { observer in
            let sellerRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(sellerId)
            sellerRef.getDocument(completion: { (snapshot, error) in
                if let err = error {
                    logger.debug("Failed to retrieve seller information and error is \(err)")
                    observer.onNext((FirebaseQueryResult.error, [String : Any]()))
                } else {
                    logger.debug("Successfully retrieved seller information")
                    if let data = snapshot?.data(){
                        observer.onNext((FirebaseQueryResult.success, data))
                    } else {
                        observer.onNext((FirebaseQueryResult.error, [String : Any]()))
                    }
                }
                observer.onCompleted()
            })
            
            return Disposables.create {
            }
        }
    }
    
    func updateShipment(soldItemId: String, buyerId: String, courierCompany: String, trackingNumber: String) -> Observable<SubmissionResult> {
        return Observable.create { observer in
            
            let batch = self.firestoreDb.batch()
            var submitData = [String: Any]()
            submitData["status"] = "shipped"
            submitData["isShippingUpdated"] = true
            submitData["courierCompany"] = courierCompany
            submitData["courierTrackingNumber"] = trackingNumber
            
            let itemRef = self.firestoreDb.collection(FilePath.FIREBASE_SOLD_ITIMES).document(soldItemId)
            batch.updateData(submitData, forDocument: itemRef)
            
            let sellerItemRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(UserManager.shared.currentUserId).collection(FilePath.FIREBASE_SOLD_ITIMES).document(soldItemId)
            batch.updateData(submitData, forDocument: sellerItemRef)
            
            let purchaseRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(buyerId).collection(FilePath.FIREBASE_PURCHASES).document(itemRef.documentID)
            batch.updateData(submitData, forDocument: purchaseRef)
            
            batch.commit { (error) in
                if let err = error {
                    logger.debug("Failed to perform batched writes and error is \(err)")
                    observer.onNext(SubmissionResult.submissionError)
                } else {
                    logger.debug("Successully performed batched writes")
                    observer.onNext(SubmissionResult.submissionSuccess)
                }
                observer.onCompleted()
            }
            
            return Disposables.create {
            }
        }
    }
    
    func savePaidItem(item: Item, buyerName: String, buyerAddress: String) -> Observable<FirebaseQueryResult> {
        return Observable.create { observer in
            
            let buyerId = UserManager.shared.currentUserId
            let sellerId = item.sellerId ?? ""
            var submitData = item.toJSON()
            var mainItemData = item.toJSON()
            submitData["sellerId"] = sellerId
            submitData["buyerId"] = buyerId
            submitData["lastUpdated"] = FieldValue.serverTimestamp()
            submitData["timeStamp"] = "\(Int(Date().timeIntervalSince1970))"
            submitData["isShippingUpdated"] = false
            submitData["buyerName"] = buyerName
            submitData["buyerAddress"] = buyerAddress
            submitData["tradeStatus"] = "paid"
            submitData["courierCompany"] = ""
            submitData["courierTrackingNumber"] = ""
            submitData["referenceId"] = UUID().uuidString
            
            //add sold item
            let batch = self.firestoreDb.batch()
            let itemRef = self.firestoreDb.collection(FilePath.FIREBASE_SOLD_ITIMES).document()
            batch.setData(submitData, forDocument: itemRef)
            
            //remove item from item list -> Instead of removing, mark item as sold
            let mainItemRef = self.firestoreDb.collection(FilePath.FIREBASE_ITEMS).document(item.itemId ?? "")
            mainItemData["isSold"] = true
            //batch.deleteDocument(mainItemRef)
            batch.updateData(mainItemData, forDocument: mainItemRef)
            
            //remove listing item
            let listingRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(sellerId).collection(FilePath.FIREBASE_LISTING).document(item.itemId ?? "")
            batch.deleteDocument(listingRef)

            //move item to seller's sold item list
            let soldItemRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(sellerId).collection(FilePath.FIREBASE_SOLD_ITIMES).document(itemRef.documentID)
            batch.setData(submitData, forDocument: soldItemRef)
            
            //move item to buyer's purchased item list
            let purchaseRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(buyerId).collection(FilePath.FIREBASE_PURCHASES).document(itemRef.documentID)
            batch.setData(submitData, forDocument: purchaseRef)

            batch.commit { (error) in
                if let err = error {
                    logger.debug("Failed to perform batched writes and error is \(err)")
                    observer.onNext(FirebaseQueryResult.error)
                } else {
                    logger.debug("Successully performed batched writes")
                    observer.onNext(FirebaseQueryResult.success)
                }
                observer.onCompleted()
            }
            
            return Disposables.create {
            }
        }
    }
    
    
    func getSliders() -> Observable<MainSlider> {
        return Observable.create { observer in
            let sliderRef = self.firestoreDb.collection(FilePath.FIREBASE_MISC_LIST).document(FilePath.FIREBASE_MAIN_SLIDER)
            sliderRef.getDocument(completion: { (snapshot, error) in
                if let err = error {
                    logger.debug("Failed to retrieve slider information and error is \(err)")
                    observer.onError(err)
                } else {
                    logger.debug("Successfully retrieved slider information")
                    if let document = snapshot, document.exists {
                        if let data = document.data(){
                            if let mainSlider = MainSlider(JSON: data){
                                observer.onNext(mainSlider)
                            }
                        }
                    } else {
                        logger.debug("Document does not exist")
                    }
                }
                observer.onCompleted()
            })
            
            return Disposables.create {
            }
        }
    }
    
    func getAllRetailSliders() -> Observable<[RetailSlider]> {
        return Observable.create { observer in
            let sliderRef = self.firestoreDb.collection(FilePath.FIREBASE_RETAIL_SLIDER).order(by: "sliderId", descending: true)
            sliderRef.getDocuments(completion: { (snapshot, error) in
                if let err = error {
                    logger.debug("Failed to retrieve retail slider information and error is \(err)")
                    observer.onError(err)
                } else {
                    logger.debug("Successfully retrieved retail slider information")
                    var sliderArray = [RetailSlider]()
                    for element in (snapshot?.documents)!{
                        //var jsonDict = element.data()
                        //jsonDict["itemId"] = element.documentID
                        if let slider = RetailSlider(JSON: element.data())
                        {
                            sliderArray.append(slider)
                        }
                    }
                    sliderArray.sort(by: {($0.sliderId ?? 0) > ($1.sliderId ?? 0)})
                    observer.onNext(sliderArray)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create {
            }
        }
    }
    
    func getAllGiveAwaySliders() -> Observable<[RetailSlider]> {
        return Observable.create { observer in
            let sliderRef = self.firestoreDb.collection(FilePath.FIREBASE_GIVE_AWAY_SLIDER).order(by: "sliderId", descending: true)
            sliderRef.getDocuments(completion: { (snapshot, error) in
                if let err = error {
                    logger.debug("Failed to retrieve retail slider information and error is \(err)")
                    observer.onError(err)
                } else {
                    logger.debug("Successfully retrieved retail slider information")
                    var sliderArray = [RetailSlider]()
                    for element in (snapshot?.documents)!{
                        if let slider = RetailSlider(JSON: element.data())
                        {
                            sliderArray.append(slider)
                        }
                    }
                    sliderArray.sort(by: {($0.sliderId ?? 0) > ($1.sliderId ?? 0)})
                    observer.onNext(sliderArray)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create {
            }
        }
    }
}
