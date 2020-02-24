//
//  TrackingViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 3/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import RxSwift

protocol EditProfileViewModeling {
    var profileImage: PublishSubject<UIImage> {get}
    var displayName: PublishSubject<String> {get}
    var submitDidTap: PublishSubject<Void> {get}
    var submissionResult: PublishSubject<SubmissionResult>{get}
}

class EditProfileViewModel: EditProfileViewModeling{
    
    let profileImage: PublishSubject<UIImage> = PublishSubject<UIImage>()
    let displayName: PublishSubject<String> = PublishSubject<String>()
    let submitDidTap: PublishSubject<Void> = PublishSubject<Void>()
    let submissionResult: PublishSubject<SubmissionResult> = PublishSubject<SubmissionResult>()
    
    let disposeBag = DisposeBag()
    
    init(firebaseService: FirebaseService){
        
        submitDidTap
            .throttle(2, scheduler: MainScheduler.instance)
            .withLatestFrom(profileImage)
            .flatMapLatest({ profileImage -> Observable<(FirebaseQueryResult,String)> in
                firebaseService.uploadProfileImage(image: profileImage)
            })
            .withLatestFrom(displayName){ returnValue, name in
                (returnValue, name)
            }
            .subscribe(onNext: { [weak self] (returnValue, name) in
                let (result, url) = returnValue
                if result == FirebaseQueryResult.error{
                    self?.submissionResult.onNext(SubmissionResult.submissionError)
                } else {
                    UserManager.shared.currentUserImageUrl = url
                    UserManager.shared.currentUserName = name
                    UserManager.shared.uploadUserInfo(completion: { (result) in
                        if result == FirebaseQueryResult.error{
                            self?.submissionResult.onNext(SubmissionResult.submissionError)
                        } else {
                            self?.submissionResult.onNext(SubmissionResult.submissionSuccess)
                        }
                    })
                }
            })
            .disposed(by: disposeBag)
    }
    
}

