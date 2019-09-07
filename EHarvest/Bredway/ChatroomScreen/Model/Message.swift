//
//  Message.swift
//  Bredway
//
//  Created by Xudong Chen on 10/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import CoreLocation
import MessageKit

private struct MessageLocationItem: LocationItem {
    
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
    
}

private struct MessageMediaItem: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    
}

internal struct Message: MessageType {
    
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var kind: MessageKind
    var timeStamp: Int
    
    private init(kind: MessageKind, sender: Sender, messageId: String, date: Date, timeStamp: Int) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
        self.timeStamp = timeStamp
    }
    
    init(text: String, sender: Sender, messageId: String, date: Date, timeStamp: Int) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date, timeStamp: timeStamp)
    }
    
    init(attributedText: NSAttributedString, sender: Sender, messageId: String, date: Date, timeStamp: Int) {
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date, timeStamp: timeStamp)
    }
    
    init(image: UIImage, sender: Sender, messageId: String, date: Date, timeStamp: Int) {
        let mediaItem = MessageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date, timeStamp: timeStamp)
    }
    
    init(thumbnail: UIImage, sender: Sender, messageId: String, date: Date, timeStamp: Int) {
        let mediaItem = MessageMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), sender: sender, messageId: messageId, date: date, timeStamp: timeStamp)
    }
    
    init(location: CLLocation, sender: Sender, messageId: String, date: Date, timeStamp: Int) {
        let locationItem = MessageLocationItem(location: location)
        self.init(kind: .location(locationItem), sender: sender, messageId: messageId, date: date, timeStamp: timeStamp)
    }
    
    init(emoji: String, sender: Sender, messageId: String, date: Date, timeStamp: Int) {
        self.init(kind: .emoji(emoji), sender: sender, messageId: messageId, date: date, timeStamp: timeStamp)
    }
    
}
