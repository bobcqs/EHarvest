//
//  UserManager.swift
//  Bredway
//
//  Created by Xudong Chen on 18/3/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import RxSwift

class UserManager{
    
    // MARK: - Varaibles
    
    private init() { }
    
    static let shared = UserManager()
    
    var currentUserId: String {
        get {
            if let userId = UserDefaults.standard.value(forKey: USER_ID) as? String{
                if !userId.isEmpty{
                    return userId
                }
            }
            return ""
        }
        set{
         //   DispatchQueue.main.async {
                UserDefaults.standard.set(newValue, forKey: USER_ID)
          //  }
        }
    }
    
    var currentUserName: String {
        get {
            if let userName = UserDefaults.standard.value(forKey: USER_NAME) as? String{
                if !userName.isEmpty{
                    return userName
                }
            }
            return ""
        }
        set{
            UserDefaults.standard.set(newValue, forKey: USER_NAME)
        }
    }
    
    var currentUserEmail: String {
        get {
            if let userEmail = UserDefaults.standard.value(forKey: USER_EMAIL) as? String{
                if !userEmail.isEmpty{
                    return userEmail
                }
            }
            return ""
        }
        set{
            UserDefaults.standard.set(newValue, forKey: USER_EMAIL)
        }
    }
    
    var currentUserImageUrl: String {
        get {
            if let userImageUrl = UserDefaults.standard.value(forKey: USER_IMAGE_URL) as? String{
                if !userImageUrl.isEmpty{
                    return userImageUrl
                }
            }
            return ""
        }
        set{
            UserDefaults.standard.set(newValue, forKey: USER_IMAGE_URL)
        }
    }
    
    var currentUserFavouriteList: [String: Bool] {
        get {
            if let userFavouriteList = UserDefaults.standard.value(forKey: USER_FAVOURITE_LIST) as? [String: Bool]{
                if !userFavouriteList.isEmpty{
                    return userFavouriteList
                }
            }
            return [String: Bool]()
        }
        set{
            UserDefaults.standard.set(newValue, forKey: USER_FAVOURITE_LIST)
        }
    }
    
    var currentUserSoldItems: [String: Bool] {
        get {
            if let userSoldItems = UserDefaults.standard.value(forKey: USER_SOLD_ITEMS) as? [String: Bool]{
                if !userSoldItems.isEmpty{
                    return userSoldItems
                }
            }
            return [String: Bool]()
        }
        set{
            UserDefaults.standard.set(newValue, forKey: USER_SOLD_ITEMS)
        }
    }
    
    var currentUserFcmToken: String {
        get {
            if let fcmToken = UserDefaults.standard.value(forKey: USER_FCM_TOKEN) as? String{
                if !fcmToken.isEmpty{
                    return fcmToken
                }
            }
            return ""
        }
        set{
            UserDefaults.standard.set(newValue, forKey: USER_FCM_TOKEN)
        }
    }
    
    var hasUnreadMessage: Bool {
        get {
            if let hasUnreadMessage = UserDefaults.standard.value(forKey: USER_HAS_UNREAD_MESSAGE) as? Bool{
                return hasUnreadMessage
            }
            return false
        }
        set{
            UserDefaults.standard.set(newValue, forKey: USER_HAS_UNREAD_MESSAGE)
        }
    }
    
    var currentUserSearchHistory: [String] {
        get {
            if let searchHistory = UserDefaults.standard.value(forKey: USER_SEARCH_HISTORY) as? [String]{
                return searchHistory
            }
            return [String]()
        }
        set{
            UserDefaults.standard.set(newValue, forKey: USER_SEARCH_HISTORY)
        }
    }
    
    var isLoggedIn: Bool {
        get{
            if let userId = UserDefaults.standard.value(forKey: USER_ID) as? String{
                if !userId.isEmpty{
                    return true
                }
            }
            return false
        }
    }

    //MARK: - Login Functions
    
    func signInWithGoogle(user: GIDGoogleUser, completion: @escaping (_ result: LoginResult) -> ()){
        LoadingManager.shared.showIndicator()
        FirebaseLoginService.shared.signInFirebaseWithGoogle(user: user, completion: {
            (result, userValues) in
            
            if result == LoginResult.success{
                logger.info("Logged in using Google successful")
                self.updateUserInfo(userValues: userValues)
                LoadingManager.shared.hideIndicator()
                completion(LoginResult.success)
            } else if result == LoginResult.failure{
                LoadingManager.shared.hideIndicatorWithLoginError()
                completion(LoginResult.failure)
            }
            
        })
    }
    
    func signInWithFacebook(viewController: UIViewController, completion: @escaping (_ result: LoginResult) -> ()){
        
        let fbReadPermission = ["public_profile", "email", "user_friends"]
        FBSDKLoginManager().logIn(withReadPermissions:fbReadPermission, from: viewController) { (result, error) in
            
            if error != nil{
                print(error!)
                return
            }else{
                LoadingManager.shared.showIndicator()
                //After logged into Facebook successfully, now login Firebase with token
                FirebaseLoginService.shared.signInFirebaseWithFB(completion: {
                    (result, userValues) in
                    
                    if result == LoginResult.success{
                        logger.info("Logged into Facebook succcessfully")
                        self.updateUserInfo(userValues: userValues)
                        LoadingManager.shared.hideIndicator()
                        completion(LoginResult.success)
                    } else if result == LoginResult.failure{
                        LoadingManager.shared.hideIndicatorWithLoginError()
                        completion(LoginResult.failure)
                    }
                })
            }
        }
    }
    
    func registerByEmail(username: String, email: String, password: String, completion: @escaping (_ result: LoginResult) -> () ){
        LoadingManager.shared.showIndicator()
        FirebaseLoginService.shared.registerFirebaseByEmail(name: username, email: email, password: password) { (result, userValues) in
            if result == LoginResult.success{
                self.updateUserInfo(userValues: userValues)
                LoadingManager.shared.hideIndicator()
                completion(LoginResult.success)
            } else if result == LoginResult.failure{
                LoadingManager.shared.hideIndicatorWithRegisterError()
                completion(LoginResult.failure)
            }
        }
    }
    
    func signInWithEmail(email: String, password: String, completion: @escaping (_ result: LoginResult) -> ()){
        LoadingManager.shared.showIndicator()
        FirebaseLoginService.shared.signInFirebaseWithEmail(email: email, password: password) { (result, userValues) in
            
            if result == LoginResult.success{
                self.updateUserInfo(userValues: userValues)
                LoadingManager.shared.hideIndicator()
                completion(LoginResult.success)
            } else if result == LoginResult.failure{
                LoadingManager.shared.hideIndicatorWithLoginError()
                completion(LoginResult.failure)
            }
        }
    }
    
    func forgotPasswordWithEmail(email: String, completion: @escaping (_ result: LoginResult) -> ()){
        FirebaseLoginService.shared.forgetPasswordWithEmail(email: email, completion: completion)
    }
    
    func logOut(){
        
        logger.info("User is logging out")
        logger.info("User ID is \(currentUserId)")
        logger.info("Username is \(currentUserName)")
        logger.info("User email is \(currentUserEmail)")
        logger.info("User image url is \(currentUserImageUrl)")
        logger.info("User favourite list is \(currentUserFavouriteList)")
        logger.info("User favourite list is \(currentUserSoldItems)")
        logger.info("User has unread message status is \(hasUnreadMessage)")
        logger.info("User has search hisotry is \(currentUserSearchHistory)")

        //remove userdefault information about user
        UserDefaults.standard.removeObject(forKey: USER_ID)
        UserDefaults.standard.removeObject(forKey: USER_NAME)
        UserDefaults.standard.removeObject(forKey: USER_EMAIL)
        UserDefaults.standard.removeObject(forKey: USER_IMAGE_URL)
        UserDefaults.standard.removeObject(forKey: USER_FAVOURITE_LIST)
        UserDefaults.standard.removeObject(forKey: USER_SOLD_ITEMS)
        UserDefaults.standard.removeObject(forKey: USER_HAS_UNREAD_MESSAGE)
        UserDefaults.standard.removeObject(forKey: USER_SEARCH_HISTORY)
        UserDefaults.standard.synchronize()
        
        
        //logout from Facebook, Google and Firebase
        FBSDKLoginManager().logOut()
        GIDSignIn.sharedInstance().signOut()
        
        do{
            try Auth.auth().signOut()
        }catch let logOutError {
            print(logOutError)
        }
        
        logger.info("User logged out successfully")
    }
    
    private func updateUserInfo(userValues: Dictionary<String, Any>){
        if let userId = userValues["uid"] as? String {
            self.currentUserId = userId
        }
        if let userName = userValues["name"] as? String {
            self.currentUserName = userName
        }
        if let userEmail = userValues["email"] as? String {
            self.currentUserEmail = userEmail
        }
        if let userImageUrl = userValues["profileImageUrl"] as? String {
            self.currentUserImageUrl = userImageUrl
        }
        if let userFavouriteList = userValues[FilePath.FIREBASE_FAVOURITE_LIST] as? [String: Bool] {
            self.currentUserFavouriteList = userFavouriteList
        }
        if let userSoldItems = userValues[FilePath.FIREBASE_SOLD_ITIMES] as? [String: Bool] {
            self.currentUserSoldItems = userSoldItems
        }
        if let userHasUnreadMessage = userValues[FilePath.FIREBASE_HAS_UNREAD_MESSAGE] as? Bool {
            self.hasUnreadMessage = userHasUnreadMessage
        }
        logger.info("User ID is \(currentUserId)")
        logger.info("Username is \(currentUserName)")
        logger.info("User email is \(currentUserEmail)")
        logger.info("User image url is \(currentUserImageUrl)")
        logger.info("User favourite list is \(currentUserFavouriteList)")
        logger.info("User sold item list is \(currentUserSoldItems)")
        logger.info("User has unread message status is \(hasUnreadMessage)")
    }
    
    // MARK: - Get and Update User Info
    func getUserFavouriteList(){
        FirebaseLoginService.shared.getFavouriteList(userId: currentUserId) { result, favouriteList in
            print (favouriteList)
        }
    }
    
    func updateUserInfoFromServer(){
        FirebaseLoginService.shared.getUserValues(userId: currentUserId) { (result, userValues) in
            if result == FirebaseQueryResult.success{
                self.updateUserInfo(userValues: userValues)
            } else if result == FirebaseQueryResult.error{
                logger.debug("Failed to retrieve and update user information")
            }
        }
    }
    
    func uploadUserInfo(completion: ((FirebaseQueryResult)-> ())?){
        var userInfo = [String: AnyObject]()
        userInfo[FilePath.FIREBASE_NAME] = currentUserName as AnyObject
        userInfo[FilePath.FIREBASE_EMAIL] = currentUserEmail as AnyObject
        userInfo[FilePath.FIREBASE_PROFILE_IMAGE_URL] = currentUserImageUrl as AnyObject
        userInfo[FilePath.FIREBASE_FAVOURITE_LIST] = currentUserFavouriteList as AnyObject
        userInfo[FilePath.FIREBASE_HAS_UNREAD_MESSAGE] = hasUnreadMessage as AnyObject
        FirebaseLoginService.shared.uploadUserInfo(userId: currentUserId, userValues: userInfo, completion: completion)
    }
    
    func uploadUserFcmToken(completion: ((FirebaseQueryResult)-> ())?){
        var fcmTokenInfo = [String: AnyObject]()
        fcmTokenInfo[FilePath.FIREBASE_FCM_TOKEN] = currentUserFcmToken as AnyObject
        FirebaseLoginService.shared.uploadFcmToken(userId: currentUserId, fcmToken: fcmTokenInfo, completion: completion)
    }
    
    func getLatestSearchList(completion: ((_ result: FirebaseQueryResult, _ searchList: [String])->())?){
        FirebaseLoginService.shared.getSearchList(completion: completion)
    }
    
    func getLatestFilterList(completion: ((_ result: FirebaseQueryResult, _ filterList: Filter)->())?){
        FirebaseLoginService.shared.getFilterList(completion: completion)
    }
    
    func getLatestSellCategoryList(completion: ((_ result: FirebaseQueryResult, _ data: [String: Any])->())?){
        FirebaseLoginService.shared.getSellCategoryList(completion: completion)
    }
    
    // MARK: - Misc methods
    func isFavouriteItem(itemId: String) -> Bool{
        for key in currentUserFavouriteList.keys{
            if key == itemId{
                return true
            }
        }
        return false
    }
}
