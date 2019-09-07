//
//  HapticGenerator.swift
//  Bredway
//
//  Created by Xudong Chen on 29/8/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import UIKit

class HapticGenerator{
    static let shared = HapticGenerator()
    let notificationGenerator = UINotificationFeedbackGenerator()
    var impactGenerator = UIImpactFeedbackGenerator()
    let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() { }
    
    func generateLightTapFeedback(){
        impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
    }
    
    func generateMediumTapFeedback(){
        impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.impactOccurred()
    }
    
    func generateHeavyTapFeedback(){
        impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactGenerator.impactOccurred()
    }
    
    func generateNotificationErrorFeedback(){
        notificationGenerator.notificationOccurred(.error)
    }
    
    func generateNotificationSuccessFeedback(){
        notificationGenerator.notificationOccurred(.success)
    }
    
    func generateNotificationWarningFeedback(){
        notificationGenerator.notificationOccurred(.warning)
    }
    
    func generateSelectionFeedback(){
        selectionGenerator.selectionChanged()
    }
    
}
