//
//  UITextFieldExtesion.swift
//  Bredway
//
//  Created by Xudong Chen on 8/8/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    func hyperLink(originalText: String, hyperLink: String, urlString: String) {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let attributedOriginalText = NSMutableAttributedString(string: originalText)
        let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
        let fullRange = NSMakeRange(0, attributedOriginalText.length)
        attributedOriginalText.addAttribute(.link, value: urlString, range: linkRange)
        attributedOriginalText.addAttribute(.paragraphStyle, value: style, range: fullRange)
        attributedOriginalText.addAttribute(.font, value: UIFont.systemFont(ofSize: 10), range: fullRange)
//        self.linkTextAttributes = [
//            NSAttributedStringKey.foregroundColor: UIColor.blue,
//            NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue
//            ]
        self.attributedText = attributedOriginalText
    }
}
