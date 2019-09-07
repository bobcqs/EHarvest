//
//  FirebaseChatroomService.swift
//  Bredway
//
//  Created by Xudong Chen on 8/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import RxSwift
import Firebase
import Kingfisher
import MessageKit

protocol FirebaseChatroomServicing {
    func initiateChatroom(buddyId: String, itemImageUrl: String, isBuyer: Bool) -> Observable<FirebaseQueryResult>
    func getPersonInfo(personId: String) -> Observable<(FirebaseQueryResult, [String: Any])>
    func getMessagesFromChatroom(chatroomId: String) -> Observable<(FirebaseQueryResult, Message)>
    func getInitialMessagesFromChatroom(chatroomId: String, pagination limit: Int) -> Observable<(FirebaseQueryResult, [Message])>
    func getMessagesWithPaginaton(chatroomId: String, pagination limit: Int) -> Observable<(FirebaseQueryResult, [Message])>
    func observeNewMessageFromChatroom(chatroomId: String) -> Observable<(FirebaseQueryResult, Message)>
    func addMessage(chatroomId: String, myId: String, buddyId: String, message: Message, isBuyer: Bool) -> Observable<FirebaseQueryResult>
    func getChatroomList(userId: String) -> Observable<[Chatroom]>
    func updateBuddyInfo(chatroomId: String, buddyInfo: [String: Any]) -> Observable<FirebaseQueryResult>
    func updateHasReadMessage(userId: String, chatroomId: String) -> Observable<FirebaseQueryResult>
}

class FirebaseChatroomService: FirebaseChatroomServicing {
    
    private let storageRef = Storage.storage().reference()
    private let firestoreDb = Firestore.firestore()
    private var lastSnapshot: QueryDocumentSnapshot?
    private let disposeBag = DisposeBag()
    
    func initiateChatroom(buddyId: String, itemImageUrl: String, isBuyer: Bool) -> Observable<FirebaseQueryResult> {
        return Observable.create { observer in
            
            if !UserManager.shared.isLoggedIn {
                logger.debug("User is not logged in")
                observer.onNext(FirebaseQueryResult.error)
                observer.onCompleted()
            } else {
                
                let batch = self.firestoreDb.batch()
                
                let buyerId = isBuyer ? UserManager.shared.currentUserId : buddyId
                let sellerId = isBuyer ? buddyId : UserManager.shared.currentUserId
                
                let chatroomId: String
                if buyerId < sellerId{
                    chatroomId = buyerId + sellerId
                } else {
                    chatroomId = sellerId + buyerId
                }
                
                var buyerSubmitData = [String: Any]()
                buyerSubmitData["buddyId"] = sellerId
                buyerSubmitData["buyerId"] = buyerId
                buyerSubmitData["itemImageUrl"] = itemImageUrl
                buyerSubmitData["sellerId"] = sellerId
                buyerSubmitData["lastUpdated"] = FieldValue.serverTimestamp()
                //buyerSubmitData["timeStamp"] = "\(Int(Date().timeIntervalSince1970))"
                
                var sellerSubmitData = [String: Any]()
                sellerSubmitData["buddyId"] = buyerId
                sellerSubmitData["buyerId"] = buyerId
                sellerSubmitData["itemImageUrl"] = itemImageUrl
                sellerSubmitData["sellerId"] = sellerId
                sellerSubmitData["lastUpdated"] = FieldValue.serverTimestamp()
                //sellerSubmitData["timeStamp"] = "\(Int(Date().timeIntervalSince1970))"
                
                var chatroomSubmitData = [String: Any]()
                chatroomSubmitData["buyerId"] = buyerId
                chatroomSubmitData["itemImageUrl"] = itemImageUrl
                chatroomSubmitData["sellerId"] = sellerId
                chatroomSubmitData["lastUpdated"] = FieldValue.serverTimestamp()
                chatroomSubmitData["timeStamp"] = "\(Int(Date().timeIntervalSince1970))"
                
                if isBuyer{
                    sellerSubmitData["buddyDisplayName"] = UserManager.shared.currentUserName
                    sellerSubmitData["buddyProfileImageUrl"] = UserManager.shared.currentUserImageUrl
                    sellerSubmitData["buddyInfoTimeStamp"] = "\(Int(Date().timeIntervalSince1970))"
                    buyerSubmitData[FilePath.FIREBASE_HAS_UNREAD_MESSAGE] = false
                    
                } else {
                    buyerSubmitData["buddyDisplayName"] = UserManager.shared.currentUserName
                    buyerSubmitData["buddyProfileImageUrl"] = UserManager.shared.currentUserImageUrl
                    buyerSubmitData["buddyInfoTimeStamp"] = "\(Int(Date().timeIntervalSince1970))"
                    sellerSubmitData[FilePath.FIREBASE_HAS_UNREAD_MESSAGE] = false
                }
                
                let buyerChatroomRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(buyerId).collection(FilePath.FIREBASE_CHATROOM_LIST).document(chatroomId)
                
                let sellerChatroomRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(sellerId).collection(FilePath.FIREBASE_CHATROOM_LIST).document(chatroomId)
                
                let chatroomRef = self.firestoreDb.collection(FilePath.FIREBASE_CHATROOMS).document(chatroomId)
                
                
                chatroomRef.getDocument(completion: { (querySnapshot, error) in
                    if let err = error {
                        logger.debug("Failed to determine whether the chatroom exists because \(err)")
                        observer.onNext(FirebaseQueryResult.error)
                    } else{
                        if let snapshot = querySnapshot{
                            if snapshot.exists{
                                //update
                                batch.updateData(buyerSubmitData, forDocument: buyerChatroomRef)
                                batch.updateData(sellerSubmitData, forDocument: sellerChatroomRef)
                                batch.updateData(chatroomSubmitData, forDocument: chatroomRef)
                            } else {
                                //create
                                batch.setData(buyerSubmitData, forDocument: buyerChatroomRef)
                                batch.setData(sellerSubmitData, forDocument: sellerChatroomRef)
                                batch.setData(chatroomSubmitData, forDocument: chatroomRef)
                            }
                            
                            batch.commit(completion: { (error) in
                                if let err = error {
                                    logger.debug(err)
                                    observer.onNext(FirebaseQueryResult.error)
                                } else {
                                    logger.debug("Successfully initiated chatroom")
                                    observer.onNext(FirebaseQueryResult.success)
                                }
                            })
                        } else {
                            logger.debug("Failed to determine whether the chatroom exists because")
                            observer.onNext(FirebaseQueryResult.error)
                        }
                    }
                })
            }
            
            return Disposables.create()
        }
    }
    
    func getPersonInfo(personId: String) -> Observable<(FirebaseQueryResult, [String : Any])> {
        return Observable.create { observer in
            let personRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(personId)
            personRef.getDocument(completion: { (snapshot, error) in
                if let err = error {
                    logger.debug("Failed to retrieve person information and error is \(err)")
                    observer.onNext((FirebaseQueryResult.error, [String : Any]()))
                } else {
                    logger.debug("Successfully retrieved person information")
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
    
    func getMessagesFromChatroom(chatroomId: String) -> Observable<(FirebaseQueryResult, Message)> {
        return Observable.create { observer in
            let messagesRef = self.firestoreDb.collection(FilePath.FIREBASE_CHATROOMS).document(chatroomId).collection(FilePath.FIREBASE_MESSAGES)
            
            messagesRef.order(by: "timeStamp", descending: true).addSnapshotListener({ (querySnapshot, error) in
                if let err = error{
                    logger.debug("Error fetching snapshots: \(err)")
                } else {
                    if let snapshot = querySnapshot{
                        snapshot.documentChanges.forEach({ (diff) in
                            if diff.type == .added{
                                logger.debug("Successfully found one new message")
                                let document = diff.document
                                let messageId = document.documentID
                                let data = document.data()
                                if let messageContent = data["text"],
                                    let dateInString = data["date"],
                                    let senderId = data["senderId"],
                                    let senderDisplayName = data["senderDisplayName"],
                                    let timeStamp = data["timeStamp"]{
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                                    let messageDate = dateFormatter.date(from: dateInString as! String)
                                    let attributedText = NSAttributedString(string: messageContent as! String)
                                    
                                    let sender = Sender(id: senderId as! String, displayName: senderDisplayName as! String)
                                    if let date = messageDate{
//                                        let message = Message(attributedText: attributedText, sender: sender, messageId: messageId, date: date)
                                        let message = Message(text: messageContent as! String, sender: sender, messageId: messageId, date: date, timeStamp: Int(timeStamp as! String)!)
                                        observer.onNext((FirebaseQueryResult.success, message))
                                    }
                                }
                            }
                        })
                    }
                }
            })
            
            return Disposables.create {
            }
        }
    }
    
    func getInitialMessagesFromChatroom(chatroomId: String, pagination limit: Int) -> Observable<(FirebaseQueryResult, [Message])> {
        return Observable.create { observer in
            let messagesRef = self.firestoreDb.collection(FilePath.FIREBASE_CHATROOMS).document(chatroomId).collection(FilePath.FIREBASE_MESSAGES).order(by: "timeStamp", descending: true).limit(to: 20)
            
            messagesRef.getDocuments(completion: { (snapshot, error) in
                if let err = error {
                    observer.onError(err)
                } else {
                    var messageList = [Message]()
                    if let documents = snapshot?.documents{
                        for document in documents{
                            logger.debug("Successfully found one new message")
                            let messageId = document.documentID
                            let data = document.data()
                            if let messageContent = data["text"],
                                let dateInString = data["date"],
                                let senderId = data["senderId"],
                                let senderDisplayName = data["senderDisplayName"],
                                let timeStamp = data["timeStamp"]{
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                                let messageDate = dateFormatter.date(from: dateInString as! String)
                                let sender = Sender(id: senderId as! String, displayName: senderDisplayName as! String)
                                if let date = messageDate{
                                    let message = Message(text: messageContent as! String, sender: sender, messageId: messageId, date: date, timeStamp: Int(timeStamp as! String)!)
                                    messageList.append(message)
                                }
                            }
                        }
                    }
                    observer.onNext((FirebaseQueryResult.success, messageList))
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
    
    func getMessagesWithPaginaton(chatroomId: String, pagination limit: Int) -> Observable<(FirebaseQueryResult, [Message])> {
        return Observable.create { observer in
            
            if let lastSnapshot = self.lastSnapshot{
                let messagesRef = self.firestoreDb.collection(FilePath.FIREBASE_CHATROOMS).document(chatroomId).collection(FilePath.FIREBASE_MESSAGES).order(by: "timeStamp", descending: true).limit(to: 20).start(afterDocument: lastSnapshot)
                messagesRef.getDocuments(completion: { (snapshot, error) in
                    if let err = error {
                        observer.onError(err)
                    } else {
                        var messageList = [Message]()
                        if let documents = snapshot?.documents{
                            for document in documents{
                                logger.debug("Successfully found one new message")
                                let messageId = document.documentID
                                let data = document.data()
                                if let messageContent = data["text"],
                                    let dateInString = data["date"],
                                    let senderId = data["senderId"],
                                    let senderDisplayName = data["senderDisplayName"],
                                    let timeStamp = data["timeStamp"]{
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                                    let messageDate = dateFormatter.date(from: dateInString as! String)
                                    let sender = Sender(id: senderId as! String, displayName: senderDisplayName as! String)
                                    if let date = messageDate{
                                        let message = Message(text: messageContent as! String, sender: sender, messageId: messageId, date: date, timeStamp: Int(timeStamp as! String)!)
                                        messageList.append(message)
                                    }
                                }
                            }
                        }
                        observer.onNext((FirebaseQueryResult.success, messageList))
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
    
    func observeNewMessageFromChatroom(chatroomId: String) -> Observable<(FirebaseQueryResult, Message)> {
        return Observable.create { observer in
            let messagesRef = self.firestoreDb.collection(FilePath.FIREBASE_CHATROOMS).document(chatroomId).collection(FilePath.FIREBASE_MESSAGES).order(by: "timeStamp").start(at: ["\(Int(Date().timeIntervalSince1970))"])
            
            let listener = messagesRef.addSnapshotListener({ (querySnapshot, error) in
                if let err = error{
                    logger.debug("Error fetching snapshots: \(err)")
                } else {
                    if let snapshot = querySnapshot{
                        snapshot.documentChanges.forEach({ (diff) in
                            if diff.type == .added{
                                logger.debug("Successfully found one new message")
                                let document = diff.document
                                let messageId = document.documentID
                                let data = document.data()
                                if let messageContent = data["text"],
                                    let dateInString = data["date"],
                                    let senderId = data["senderId"],
                                    let senderDisplayName = data["senderDisplayName"],
                                    let timeStamp = data["timeStamp"]{
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                                    let messageDate = dateFormatter.date(from: dateInString as! String)
                                    let sender = Sender(id: senderId as! String, displayName: senderDisplayName as! String)
                                    if let date = messageDate{
                                        let message = Message(text: messageContent as! String, sender: sender, messageId: messageId, date: date, timeStamp: Int(timeStamp as! String)!)
                                        observer.onNext((FirebaseQueryResult.success, message))
                                    }
                                }
                            }
                        })
                    }
                }
            })
            
            return Disposables.create {
                listener.remove()
            }
        }
    }
    
    func addMessage(chatroomId: String, myId: String, buddyId: String, message: Message, isBuyer: Bool) -> Observable<FirebaseQueryResult> {
        
        return Observable.create { observer in
            
            let batch = self.firestoreDb.batch()
            
            let buyerId = isBuyer ? UserManager.shared.currentUserId : buddyId
            let sellerId = isBuyer ? buddyId : UserManager.shared.currentUserId
            
            let chatroomId: String
            if buyerId < sellerId{
                chatroomId = buyerId + sellerId
            } else {
                chatroomId = sellerId + buyerId
            }
            
            var lastMessage = ""
            
            switch message.kind{
            case let .text(textString):
                lastMessage = textString
            case let .attributedText(textString):
                lastMessage = textString.string
            default:
                break
            }
            
            var buyerSubmitData = [String: Any]()
            buyerSubmitData["lastMessage"] = lastMessage
            buyerSubmitData["lastUpdated"] = FieldValue.serverTimestamp()
            buyerSubmitData["timeStamp"] = "\(Int(Date().timeIntervalSince1970))"
            
            var sellerSubmitData = buyerSubmitData
            
            if buddyId == buyerId{
                buyerSubmitData[FilePath.FIREBASE_HAS_UNREAD_MESSAGE] = true
            } else {
                sellerSubmitData[FilePath.FIREBASE_HAS_UNREAD_MESSAGE] = true
            }
            
            let buyerChatroomRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(buyerId).collection(FilePath.FIREBASE_CHATROOM_LIST).document(chatroomId)
            
            let sellerChatroomRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(sellerId).collection(FilePath.FIREBASE_CHATROOM_LIST).document(chatroomId)
            
            batch.updateData(buyerSubmitData, forDocument: buyerChatroomRef)
            batch.updateData(sellerSubmitData, forDocument: sellerChatroomRef)
            
            var messageSubmitData = [String: Any]()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            
            messageSubmitData["text"] = lastMessage
            messageSubmitData["senderDisplayName"] = message.sender.displayName
            messageSubmitData["senderId"] = message.sender.id
            messageSubmitData["date"] = dateFormatter.string(from: message.sentDate)
            messageSubmitData["timeStamp"] = "\(Int(Date().timeIntervalSince1970))"
            let chatroomRef = self.firestoreDb.collection(FilePath.FIREBASE_CHATROOMS).document(chatroomId).collection(FilePath.FIREBASE_MESSAGES).document(message.messageId)
            batch.setData(messageSubmitData, forDocument: chatroomRef)
            
            let buddyRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(buddyId)
            var buddySubmitData = [String: Any]()
            buddySubmitData[FilePath.FIREBASE_HAS_UNREAD_MESSAGE] = true
            batch.updateData(buddySubmitData, forDocument: buddyRef)
            
            batch.commit(completion: { (error) in
                if let err = error {
                    logger.debug(err)
                    observer.onNext(FirebaseQueryResult.error)
                } else {
                    logger.debug("Successfully sent a message")
                    observer.onNext(FirebaseQueryResult.success)
                }
            })

            return Disposables.create {
            }
        }
    }
    
    func getChatroomList(userId: String) -> Observable<[Chatroom]> {
        return Observable.create { observer in
            let chatroomsRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(userId).collection(FilePath.FIREBASE_CHATROOM_LIST)
            chatroomsRef.getDocuments(completion: { (snapshot, error) in
                if let err = error {
                    observer.onError(err)
                } else {
                    var chatroomArray = [Chatroom]()
                    for element in (snapshot?.documents)!{
                        var jsonDict = element.data()
                        jsonDict["chatroomId"] = element.documentID
                        if let chatroom = Chatroom(JSON: jsonDict)
                        {
                            chatroomArray.append(chatroom)
                        }
                    }
                    observer.onNext(chatroomArray)
                    observer.onCompleted()
                }
            })
            
            
            return Disposables.create {
            }
        }
    }
    
    func updateBuddyInfo(chatroomId: String, buddyInfo: [String : Any]) -> Observable<FirebaseQueryResult> {
        return Observable.create { observer in
            let chatroomsRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(UserManager.shared.currentUserId).collection(FilePath.FIREBASE_CHATROOM_LIST).document(chatroomId)
            
            chatroomsRef.updateData(buddyInfo, completion: { (error) in
                if let err = error{
                    logger.debug("Failed to update buddy info for chatroom \(chatroomId) and the error is \(err)")
                    observer.onNext(FirebaseQueryResult.error)
                } else {
                    logger.debug("Successfully updated buddy info for chatroom \(chatroomId)")
                    observer.onNext(FirebaseQueryResult.success)
                }
            })
            
            return Disposables.create {
            }
        }
    }
    
    func updateHasReadMessage(userId: String, chatroomId: String) -> Observable<FirebaseQueryResult> {
        return Observable.create { observer in
            let chatroomsRef = self.firestoreDb.collection(FilePath.FIREBASE_USERS).document(userId).collection(FilePath.FIREBASE_CHATROOM_LIST).document(chatroomId)
            
            let submitData = [FilePath.FIREBASE_HAS_UNREAD_MESSAGE: false]
            chatroomsRef.updateData(submitData, completion: { (error) in
                if let err = error{
                    logger.debug("Failed to update buddy info for chatroom \(chatroomId) and the error is \(err)")
                    observer.onNext(FirebaseQueryResult.error)
                } else {
                    logger.debug("Successfully updated buddy info for chatroom \(chatroomId)")
                    observer.onNext(FirebaseQueryResult.success)
                }
            })
            
            return Disposables.create {
            }
        }
    }
}
