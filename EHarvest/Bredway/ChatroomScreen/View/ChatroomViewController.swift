//
//  ChatroomViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 9/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import MessageKit
import MapKit
import RxSwift
import RxCocoa
import Kingfisher


class ChatroomViewController: MessagesViewController {
    
    let refreshControl = UIRefreshControl()
    
    var viewModel: ChatroomViewModeling!
    
    private let disposeBag = DisposeBag()
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        messageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        scrollsToBottomOnKeybordBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        setupBinding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //LoadingManager.shared.showIndicator()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel = nil
    }

    func setupBinding(){
        viewModel.delegate = self
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(ChatroomViewController.loadMoreMessages), for: .valueChanged)
        
        viewModel.uploadMessageResult
            .subscribe(onNext: { (result) in
                if result == FirebaseQueryResult.error {
                    LoadingManager.shared.showNetworkErrorAlert(viewController: self)
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc func loadMoreMessages(){
        viewModel.loadMoreMessageTrigger.onNext(())
    }
}

extension ChatroomViewController: ChatroomDelegate{
    func messageListDidUpdate() {
        DispatchQueue.main.async {
            //LoadingManager.shared.hideIndicator()
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
           // self.messagesCollectionView.reloadDataAndKeepOffset()
            self.refreshControl.endRefreshing()
        }
    }
    
    func didLoadMoreMessages() {
        self.messagesCollectionView.reloadData()
        //self.messagesCollectionView.scrollToBottom()
        self.messagesCollectionView.reloadDataAndKeepOffset()
        self.refreshControl.endRefreshing()
    }
}

// MARK: - MessagesDataSource

extension ChatroomViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        let sender = Sender(id: UserManager.shared.currentUserId, displayName: UserManager.shared.currentUserName)
        return sender
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        let count = viewModel.messages.count
        return viewModel.messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return viewModel.messages[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
}

// MARK: - MessagesDisplayDelegate

extension ChatroomViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedStringKey: Any] {
        return MessageLabel.defaultAttributes
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
        //        let configurationClosure = { (view: MessageContainerView) in}
        //        return .custom(configurationClosure)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let thisMessage = viewModel.messages[indexPath.section]
        let senderId = thisMessage.sender.id
        let imageUrl: String?
        if senderId == UserManager.shared.currentUserId{
            imageUrl = UserManager.shared.currentUserImageUrl
        } else {
            imageUrl = viewModel.buddyImageUrl
        }
        
        if let urlString = imageUrl{
            ImageCache.default.retrieveImage(forKey: urlString, options: nil) {
                image, cacheType in
                if let image = image {
                    avatarView.image = image
                } else {
                    if let imageUrl = URL(string: urlString){
                        ImageDownloader.default.downloadImage(with: imageUrl, retrieveImageTask: nil, options: [], progressBlock:nil, completionHandler: { (downloadedImage, error, url, data) in
                            if let err = error {
                                logger.debug("Failed to download image because \(err)")
                            } else {
                                avatarView.image = downloadedImage
                                ImageCache.default.store(downloadedImage!, forKey: urlString)
                            }
                        })
                    }
                }
            }

        }
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "pin")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(0, 0, 0)
            view.alpha = 0.0
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
                view.alpha = 1.0
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions()
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatroomViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            return 10
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}

// MARK: - MessageCellDelegate

extension ChatroomViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
}

// MARK: - MessageLabelDelegate

extension ChatroomViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
    
}

// MARK: - MessageInputBarDelegate

extension ChatroomViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        // Each NSTextAttachment that contains an image will count as one empty character in the text: String
        
        for component in inputBar.inputTextView.components {
            
            if let image = component as? UIImage {
                
                let imageMessage = Message(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date(), timeStamp: Int(Date().timeIntervalSince1970))
                //messageList.append(imageMessage)
                //messagesCollectionView.insertSections([messageList.count - 1])
                
            } else if let text = component as? String {
                
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.blue])
                
//                let message = Message(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                let message = Message(text: text, sender: currentSender(), messageId: UUID().uuidString, date: Date(), timeStamp: Int(Date().timeIntervalSince1970))
                viewModel.uploadMessage.onNext(message)
                //viewModel.uploadNewMessage()
                //messageList.append(message)
                //messagesCollectionView.insertSections([messageList.count - 1])
            }
            
        }
        
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
    
}
