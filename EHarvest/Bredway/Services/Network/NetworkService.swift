//
//  NetworkService.swift
//  Bredway
//
//  Created by Xudong Chen on 1/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import RxSwift
import RxCocoa
import Alamofire

enum NetworkMethod {
    case get, post, put, delete
}

fileprivate extension NetworkMethod {
    func httpMethod() -> HTTPMethod {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .delete:
            return .delete
        }
    }
}

protocol NetworkServicing {
    func requestForStringResponse(method: NetworkMethod, url: String, parameters: [String : Any]?) -> Observable<Any>
}

final class Networkservice: NetworkServicing{
    func requestForStringResponse(method: NetworkMethod, url: String, parameters: [String : Any]?) -> Observable<Any> {
        return Observable.create { observer in
            let method = method.httpMethod()
            
            let request = Alamofire.request(url, method: method, parameters: parameters)
                .validate()
                .responseString { response in
                    switch response.result {
                    case .success(let value):
                        observer.onNext(value)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(NetworkError(error: error))
                    }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
