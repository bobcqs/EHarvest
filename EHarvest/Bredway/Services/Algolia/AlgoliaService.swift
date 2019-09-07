//
//  AlgoliaService.swift
//  Bredway
//
//  Created by Xudong Chen on 26/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import AlgoliaSearch
import RxSwift
import Firebase


protocol AlgoliaSearchServicing {
    func getAlogiliaKey() -> Observable<FirebaseQueryResult>
    func lightSearch(searchText: String)-> Observable<[Item]>
    func filterSearch(filterText: String)-> Observable<[Item]>
}

class AlgoliaSearchService: AlgoliaSearchServicing {
    private let firestoreDb = Firestore.firestore()
    private var appId: String?
    private var apiKey: String?
    private var client: Client?
    private let disposeBag = DisposeBag()
    
    func getAlogiliaKey() -> Observable<FirebaseQueryResult> {
        return Observable.create { observer in
            let keyRef = self.firestoreDb.collection(FilePath.FIREBASE_ALGOLIA).document(FilePath.FIREBASE_ALGOLIA_SEARCH_KEY)
            keyRef.getDocument(completion: { (document, error) in
                if let err = error {
                    logger.debug("Failed to fetch Algolia API Key from database and error is \(err)")
                    observer.onNext(FirebaseQueryResult.error)
                } else {
                    if let apiData = document?.data(){
                        if let appId = apiData["appId"]{
                            self.appId = appId as? String
                        }
                        if let apiKey = apiData["apiKey"]{
                            self.apiKey = apiKey as? String
                        }
                        if let appId = self.appId, let key = self.apiKey{
                            self.client = Client.init(appID: appId, apiKey: key)
                        }
                    }
                    observer.onNext(FirebaseQueryResult.success)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    private func genericSearch(index: Index, query: AlgoliaSearch.Query)-> Observable<[String: Any]>{
        return Observable.create { observer in
            index.search(query, completionHandler: { (content, error) -> Void in
                if let err = error{
                    observer.onError(err)
                    observer.onCompleted()
                } else {
                    if let result = content{
                        observer.onNext(result)
                        observer.onCompleted()
                    }
                }
                
            })
            return Disposables.create()
        }
    }
    
    func lightSearch(searchText: String) -> Observable<[Item]> {
        return Observable.create { observer in
            self.getAlogiliaKey()
                .flatMapLatest({ (result) -> Observable<[String: Any]> in
                    if result == FirebaseQueryResult.success{
                        if let client = self.client
                        {
                            let index = client.index(withName: "items")
                            let query = Query(query: searchText)
                            return self.genericSearch(index: index, query: query)
                        } else {
                            return Observable.just([String: Any]())
                        }
                    } else {
                        return Observable.just([String: Any]())
                    }
                })
                .subscribe(onNext: { (content) in
                    if let hits = content["hits"]{
                        if let resultArray = hits as? [[String: Any]]{
                            var itemArray = [Item]()
                            for element in resultArray{
                                if let item = Item(JSON: element)
                                {
                                    itemArray.append(item)
                                }
                            }
                            observer.onNext(itemArray)
                            observer.onCompleted()
                        }

                    }
                }, onError: { (error) in
                    logger.debug("Failed to fetch search items and error is \(error)")
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)

            
            return Disposables.create()
        }
    }

    func filterSearch(filterText: String) -> Observable<[Item]> {
        return Observable.create { observer in
            self.getAlogiliaKey()
                .flatMapLatest({ (result) -> Observable<[String: Any]> in
                    if result == FirebaseQueryResult.success{
                        if let client = self.client
                        {
                            let index = client.index(withName: "items")
                            let query = Query.init()
                            query.filters = filterText
                            return self.genericSearch(index: index, query: query)
                        } else {
                            return Observable.just([String: Any]())
                        }
                    } else {
                        return Observable.just([String: Any]())
                    }
                })
                .subscribe(onNext: { (content) in
                    if let hits = content["hits"]{
                        if let resultArray = hits as? [[String: Any]]{
                            var itemArray = [Item]()
                            for element in resultArray{
                                if let item = Item(JSON: element)
                                {
                                    itemArray.append(item)
                                }
                            }
                            observer.onNext(itemArray)
                            observer.onCompleted()
                        }
                        
                    }
                }, onError: { (error) in
                    logger.debug("Failed to fetch search items and error is \(error)")
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)
            
            
            return Disposables.create()
        }
    }
}
