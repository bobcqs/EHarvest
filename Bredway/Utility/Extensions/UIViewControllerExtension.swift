//
//  UIViewControllerExtension.swift
//  Bredway
//
//  Created by Xudong Chen on 14/4/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

extension UIViewController
{
    func setupKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    func addRedDotAtTabBarItemIndex(index: Int) {
        for subview in tabBarController!.tabBar.subviews {
            if let subview = subview as? UIView {
                if subview.tag == 1234 {
                    subview.removeFromSuperview()
                    break
                }
            }
        }
        
        let RedDotRadius: CGFloat = 5
        let RedDotDiameter = RedDotRadius * 2
        
        let TopMargin:CGFloat = 5
        
        let TabBarItemCount = CGFloat(self.tabBarController!.tabBar.items!.count)
        
        let screenSize = UIScreen.main.bounds
        let HalfItemWidth = (screenSize.width) / (TabBarItemCount * 2)
        
        let  xOffset = HalfItemWidth * CGFloat(index * 2 + 1)
        
        let imageHalfWidth: CGFloat = (self.tabBarController!.tabBar.items![index]).selectedImage!.size.width / 2
        
        let redDot = UIView(frame: CGRect(x: xOffset + imageHalfWidth - 7, y: TopMargin, width: RedDotDiameter, height: RedDotDiameter))
        
        redDot.tag = 1234
        redDot.backgroundColor = UIColor.red
        redDot.layer.cornerRadius = RedDotRadius
        
        self.tabBarController?.tabBar.addSubview(redDot)
        
    }
    
    func removeRedDotForTabBar(){
        for subview in tabBarController!.tabBar.subviews {
            if let subview = subview as? UIView {
                if subview.tag == 1234 {
                    subview.removeFromSuperview()
                    break
                }
            }
        }
    }
    
    func setupUnreadMessageDot(isInboxViewController: Bool){
        if isInboxViewController{
            if UserManager.shared.hasUnreadMessage{
                removeRedDotForTabBar()
                UserManager.shared.hasUnreadMessage = false
                UserManager.shared.uploadUserInfo(completion: nil)
            }
        } else {
            if UserManager.shared.hasUnreadMessage{
                addRedDotAtTabBarItemIndex(index: 2)
            }
        }
    }
}
