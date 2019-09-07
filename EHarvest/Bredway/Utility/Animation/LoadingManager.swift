//
//  LoadingManager.swift
//  Bredway
//
//  Created by Xudong Chen on 5/4/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoadingManager {
    
    static let shared = LoadingManager()
    
    var activityData = ActivityData(size: nil, message: nil, messageFont: nil, messageSpacing: nil, type: NVActivityIndicatorType.ballRotateChase, color: ColorDesign.flatRed, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: UIColor.clear, textColor: nil)
    
    let activityIndicatorView = NVActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 400, height: 400),
                                                        type: NVActivityIndicatorType.ballRotateChase)
    
    func showIndicator(){
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }
    
    func hideIndicator(){
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    func hideIndicatorWithMessage(message: String, timeInterval: Int){
        setMessage(message: message)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeInterval)) {
            self.hideIndicator()
        }
    }
    
    func hideIndicatorWithLoginError(){
        setMessage(message: "Failed to login, please try again later")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.hideIndicator()
        }
    }
    
    func hideIndicatorWithRegisterError(){
        setMessage(message: "Failed to register, please try again later")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.hideIndicator()
        }
    }
    
    func setMessage(message: String){
        NVActivityIndicatorPresenter.sharedInstance.setMessage(message)
    }
    
    func showIndicatorView(viewController: UIViewController){
        setMessage(message: "Failed to register, please try again later")
        viewController.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
    
    func showNetworkErrorAlert(viewController: UIViewController){
        // the alert view
        let alert = UIAlertController(title: "Network Error", message: "Unable to send message, please try again", preferredStyle: .alert)
        viewController.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds 
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
        }
    }
}
