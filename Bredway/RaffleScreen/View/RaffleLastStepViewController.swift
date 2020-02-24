//
//  RaffleLastStepViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 12/10/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import Kingfisher
import FacebookShare

class RaffleLastStepViewController: UIViewController {

    var selectedImageUrl: String?
    var instagramCaption: String?
    var facebookCaption: String?
    var instagramWebUrl: String?
    var facebookWebUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func instagramTutorialButtonDidTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "WebViewScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"WebViewViewControllerId") as! WebViewViewController
        viewController.webUrl = "https://www.bredway.com.au/shareoninstagram/"
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func facebookTutorialButtonDidTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "WebViewScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"WebViewViewControllerId") as! WebViewViewController
        viewController.webUrl = "https://www.bredway.com.au/shareonfacebook/"
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func shareOnInstagramDidTap(_ sender: Any) {
        UIPasteboard.general.string = instagramCaption ?? ""
        ImageCache.default.retrieveImage(forKey: selectedImageUrl ?? "", options: nil) { (image, type) in
            InstagramManager.sharedManager.postImageToInstagramWithCaption(imageInstagram: image!,
                                                                           instagramCaption: "caption",
                                                                           view: self.view, viewController: self)
        }
    }
    
    @IBAction func shareOnFacebookDidTap(_ sender: Any) {
        UIPasteboard.general.string = facebookCaption ?? ""
        ImageCache.default.retrieveImage(forKey: selectedImageUrl ?? "", options: nil) { (image, type) in
            let photo = Photo(image: image!, userGenerated: true)
            let content = PhotoShareContent(photos: [photo])
            //try ShareDialog.show(from: myViewController, content: content)
            do {
                try ShareDialog.show(from: self, content: content)
                
            }
            catch {
            
            }
            
        }
    }
    
    
    @IBAction func doneSharingDidTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
