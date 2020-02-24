//
//  FirebaseLoginService.swift
//  Bredway
//
//  Created by Xudong Chen on 26/3/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit
import GoogleSignIn

enum LoginResult{
    case success
    case failure
}

class FirebaseLoginService{
    
    static let shared = FirebaseLoginService()
    
    func signInFirebaseWithFB(completion: @escaping (_ result: LoginResult, _ userValues: Dictionary<String, Any>) -> ()){
        
        let fbAccessToken = FBSDKAccessToken.current()
        guard let fbAccessTokenString = fbAccessToken?.tokenString else {
            completion(LoginResult.failure, [String: AnyObject]())
            return
        }
        
        let fbCredentials = FacebookAuthProvider.credential(withAccessToken: fbAccessTokenString)
        firebaseSignInWithCredential(credential: fbCredentials, completion: completion)
    }
    
    func signInFirebaseWithGoogle(user: GIDGoogleUser,completion: @escaping (_ result: LoginResult, _ userValues: Dictionary<String, Any>) -> ()){
        
        guard let authentication = user.authentication else {
            completion(LoginResult.failure, [String: AnyObject]())
            return
        }
        let googleCredential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        firebaseSignInWithCredential(credential: googleCredential, completion: completion)
        
    }
    
    func firebaseSignInWithCredential(credential: AuthCredential,completion: @escaping (_ result: LoginResult, _ userValues: Dictionary<String, Any>) -> ()){
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with our FB user: ", error ?? "")
                completion(LoginResult.failure, [String: AnyObject]())
            }else{
                
                print("Successfully logged in with our user: ", user ?? "")
                
                guard let uid = user?.uid else {
                    return
                }
                
                guard let profileImageUrl = user?.photoURL?.absoluteString, let email = user?.email, let name = user?.displayName else{
                    return
                }
                
                print (profileImageUrl)

                var userValues = ["uid":uid as AnyObject, "name": name as AnyObject, "email": email as AnyObject] as [String: AnyObject]
                
                self.getUserList(userId: uid, completion: { (result, userList) in
                    if result == FirebaseQueryResult.noDocument{
                        Firestore.firestore().collection("users")
                            .document(uid)
                            .setData(["name": name as AnyObject,
                                      "email": email as AnyObject],
                                     completion: { (error) in
                                        if let err = error {
                                            print("Error writing document: \(err)")
                                            completion(LoginResult.failure, [String: AnyObject]())
                                        } else {
                                            print("Document successfully written!")
                                            completion(LoginResult.success, userValues)
                                        }
                            })
                    } else if result == FirebaseQueryResult.error{
                        completion(LoginResult.failure, [String: AnyObject]())
                    } else {
                        if let favouriteList = userList[FilePath.FIREBASE_FAVOURITE_LIST]{
                            let list = favouriteList as! [String: Any]
                            userValues[FilePath.FIREBASE_FAVOURITE_LIST] = list as AnyObject
                        }
                        if let userName = userList[FilePath.FIREBASE_NAME]{
                            let name = userName as! String
                            userValues[FilePath.FIREBASE_NAME] = name as AnyObject
                        }
                        if let userImageUrl = userList[FilePath.FIREBASE_PROFILE_IMAGE_URL]{
                            let url = userImageUrl as! String
                            userValues[FilePath.FIREBASE_PROFILE_IMAGE_URL] = url as AnyObject
                        }
                        completion(LoginResult.success, userValues)
                    }
                })
                
//                Firestore.firestore().collection("users")
//                    .document(uid)
//                    .setData(["name": name as AnyObject,
//                              "email": email as AnyObject],
//                 completion: { (error) in
//                    if let err = error {
//                        print("Error writing document: \(err)")
//                        completion(LoginResult.failure, [String: AnyObject]())
//                    } else {
//                        print("Document successfully written!")
//                        self.getUserList(userId: uid, completion: { (result, userList) in
//                            if result == FirebaseQueryResult.error{
//                                completion(LoginResult.failure, [String: AnyObject]())
//                            } else {
//                                if let favouriteList = userList[FilePath.FIREBASE_FAVOURITE_LIST]{
//                                    let list = favouriteList as! [String: Any]
//                                    userValues[FilePath.FIREBASE_FAVOURITE_LIST] = list as AnyObject
//                                }
//                                if let userName = userList[FilePath.FIREBASE_NAME]{
//                                    let name = userName as! String
//                                    userValues[FilePath.FIREBASE_NAME] = name as AnyObject
//                                }
//                                if let userImageUrl = userList[FilePath.FIREBASE_PROFILE_IMAGE_URL]{
//                                    let url = userImageUrl as! String
//                                    userValues[FilePath.FIREBASE_PROFILE_IMAGE_URL] = url as AnyObject
//                                }
//                                completion(LoginResult.success, userValues)
//                            }
//                        })
//                    }
//                })
            }
        })
    }
    
    func registerFirebaseByEmail(name: String, email: String, password: String, completion: @escaping (_ result: LoginResult, _ userValues: Dictionary<String, Any>) -> ()){
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user: User?, error) in
            
            if error != nil{
                print(error?.localizedDescription as Any)
                completion(LoginResult.failure, [String: AnyObject]())
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let userValues = ["uid":uid as AnyObject,
                              "name": name as AnyObject,
                              "email": email as AnyObject,
                              "profileImageUrl": "https://firebasestorage.googleapis.com/v0/b/bredway-13f11.appspot.com/o/Misc%2FprofilePhoto.png?alt=media&token=ce29102d-35cd-4737-945a-7603ab664bad" as AnyObject]
                as [String: AnyObject]
            
            Firestore.firestore().collection("users")
                .document(uid)
                .setData(["name": name as AnyObject,
                          "email": email as AnyObject],
            completion: { (error) in
                if let err = error {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    completion(LoginResult.success, userValues)
                }
            })
        })
    }
    
    func signInFirebaseWithEmail(email: String, password: String, completion: @escaping (_ result: LoginResult, _ userValues: Dictionary<String, Any>) -> ()){
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                logger.debug(error?.localizedDescription as Any)
                completion(LoginResult.failure, [String: AnyObject]())
            }else{
                var userValues = ["uid":user?.uid as AnyObject, "name": user?.displayName as AnyObject, "email": user?.email as AnyObject] as [String: AnyObject]
                
                if let uid = user?.uid{
                    self.getUserList(userId: uid, completion: { (result, userList) in
                        if result == FirebaseQueryResult.error{
                            completion(LoginResult.failure, [String: AnyObject]())
                        } else {
                            if let favouriteList = userList[FilePath.FIREBASE_FAVOURITE_LIST]{
                                let list = favouriteList as! [String: Any]
                                userValues[FilePath.FIREBASE_FAVOURITE_LIST] = list as AnyObject
                            }
                            if let userName = userList[FilePath.FIREBASE_NAME]{
                                let name = userName as! String
                                userValues[FilePath.FIREBASE_NAME] = name as AnyObject
                            }
                            if let userImageUrl = userList[FilePath.FIREBASE_PROFILE_IMAGE_URL]{
                                let url = userImageUrl as! String
                                userValues[FilePath.FIREBASE_PROFILE_IMAGE_URL] = url as AnyObject
                            }
                            completion(LoginResult.success, userValues)
                        }
                    })
                }
            }
        })
    }
    
    func forgetPasswordWithEmail(email: String, completion: @escaping (_ result: LoginResult) -> ()){
        Auth.auth().sendPasswordReset(withEmail: email) { error in            
            if let error = error {
                print(error.localizedDescription)
            } else {
                completion(LoginResult.success)
            }
        }
    }
    
    func getFavouriteList(userId: String, completion: ((_ loginResult: FirebaseQueryResult, _ favouriteList: [String: Any])->())? ){
        let db = Firestore.firestore()
        let listRef = db.collection(FilePath.FIREBASE_USERS).document(userId)
        listRef.getDocument { (document, error) in
            if let err = error{
                logger.debug("Failed to get favourite list and error is \(err)")
                completion?(FirebaseQueryResult.error, [String: Any]())
            } else {
                if let document = document, document.exists {
                    if let userDict = document.data(){
                        if let favouriteList = userDict[FilePath.FIREBASE_FAVOURITE_LIST]{
                            let list = favouriteList as! [String: Any]
                            logger.debug("Successfully retrieved favourite lists")
                            completion?(FirebaseQueryResult.success, list)
                        } else {
                            completion?(FirebaseQueryResult.success, [String: Any]())
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }

    func getUserList(userId: String, completion: ((_ loginResult: FirebaseQueryResult, _ userList: [String: Any])->())? ){
        let db = Firestore.firestore()
        let listRef = db.collection(FilePath.FIREBASE_USERS).document(userId)
        listRef.getDocument { (document, error) in
            if let doc = document, !doc.exists{
                logger.debug("Document doesn't exist")
                completion?(FirebaseQueryResult.noDocument, [String: Any]())
            } else if let err = error{
                logger.debug("Failed to get favourite list and error is \(err)")
                completion?(FirebaseQueryResult.error, [String: Any]())
            } else {
                if let document = document, document.exists {
                    if let userDict = document.data(){
                            completion?(FirebaseQueryResult.success, userDict)
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func getUserValues(userId: String, completion: @escaping (_ result: FirebaseQueryResult, _ userValues: Dictionary<String, Any>) -> ()){
        self.getUserList(userId: userId) { (result, userList) in
            if result == FirebaseQueryResult.error{
                completion(FirebaseQueryResult.error, [String: AnyObject]())
            } else {
                var userValues = [String: AnyObject]()
                if let favouriteList = userList[FilePath.FIREBASE_FAVOURITE_LIST]{
                    let list = favouriteList as! [String: Any]
                    userValues[FilePath.FIREBASE_FAVOURITE_LIST] = list as AnyObject
                }
                if let userName = userList[FilePath.FIREBASE_NAME]{
                    let name = userName as! String
                    userValues[FilePath.FIREBASE_NAME] = name as AnyObject
                }
                if let userEmail = userList[FilePath.FIREBASE_EMAIL]{
                    let email = userEmail as! String
                    userValues[FilePath.FIREBASE_EMAIL] = email as AnyObject
                }
                if let userImageUrl = userList[FilePath.FIREBASE_PROFILE_IMAGE_URL]{
                    let url = userImageUrl as! String
                    userValues[FilePath.FIREBASE_PROFILE_IMAGE_URL] = url as AnyObject
                }
                if let userHasUnreadMessage = userList[FilePath.FIREBASE_HAS_UNREAD_MESSAGE]{
                    let hasUnreadMessage = userHasUnreadMessage as! Bool
                    userValues[FilePath.FIREBASE_HAS_UNREAD_MESSAGE] = hasUnreadMessage as AnyObject
                }
                completion(FirebaseQueryResult.success, userValues)
            }
        }
    }
    
    func getSearchList(completion: ((_ result: FirebaseQueryResult, _ searchList: [String])->())?){
        let db = Firestore.firestore()
        let listRef = db.collection(FilePath.FIREBASE_MISC_LIST).document(FilePath.FIREBASE_SEARCH_LIST)
        listRef.getDocument { (document, error) in
            if let err = error{
                logger.debug("Failed to get favourite list and error is \(err)")
                completion?(FirebaseQueryResult.error, [String]())
            } else {
                if let document = document, document.exists {
                    if let data = document.data(){
                        if let list = data[FilePath.FIREBASE_SEARCH_ARRAY]{
                            completion?(FirebaseQueryResult.success, list as! [String] )
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func getFilterList(completion: ((_ result: FirebaseQueryResult, _ filter: Filter)->())?){
        let db = Firestore.firestore()
        let listRef = db.collection(FilePath.FIREBASE_MISC_LIST).document(FilePath.FIREBASE_FILTER_LIST)
        listRef.getDocument { (document, error) in
            if let err = error{
                logger.debug("Failed to get favourite list and error is \(err)")
                completion?(FirebaseQueryResult.error, Filter())
            } else {
                if let document = document, document.exists {
                    if let data = document.data(){
                        if let filter = Filter(JSON: data){
                           completion?(FirebaseQueryResult.success, filter)
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func getSellCategoryList(completion: ((_ result: FirebaseQueryResult, _ data: [String: Any])->())?){
        let db = Firestore.firestore()
        let listRef = db.collection(FilePath.FIREBASE_MISC_LIST).document(FilePath.FIREBASE_SELL_CATEGORY_LIST)
        listRef.getDocument { (document, error) in
            if let err = error{
                logger.debug("Failed to get favourite list and error is \(err)")
                completion?(FirebaseQueryResult.error, [String: Any]())
            } else {
                if let document = document, document.exists {
                    if let data = document.data(){
                        completion?(FirebaseQueryResult.success, data)
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }

    
    func uploadUserInfo(userId: String, userValues: [String: AnyObject], completion: ((FirebaseQueryResult)-> ())?) {
        Firestore.firestore().collection(FilePath.FIREBASE_USERS)
            .document(userId)
            .updateData(userValues) { (error) in
                if let err = error {
                    logger.debug("Failed to upload user info because \(err)")
                    if let completeHandler = completion{
                        completeHandler(FirebaseQueryResult.error)
                    }
                } else {
                    logger.debug("Successfully uploaded user info to server")
                    if let completeHandler = completion{
                        completeHandler(FirebaseQueryResult.success)
                    }
                }
        }
    }
    
    func uploadFcmToken(userId: String, fcmToken: [String: Any], completion: ((FirebaseQueryResult)-> ())?) {
        Firestore.firestore().collection(FilePath.FIREBASE_USERS)
            .document(userId)
            .updateData(fcmToken) { (error) in
                if let err = error {
                    logger.debug("Failed to upload user token info because \(err)")
                    if let completeHandler = completion{
                        completeHandler(FirebaseQueryResult.error)
                    }
                } else {
                    logger.debug("Successfully uploaded user info to server")
                    if let completeHandler = completion{
                        completeHandler(FirebaseQueryResult.success)
                    }
                }
        }
    }
}
