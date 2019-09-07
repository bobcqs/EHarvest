//
//  WebViewViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 18/9/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import WebKit

protocol GenericReturnAction: class {
    func didEnterGiveAwayContest()
}

extension GenericReturnAction{
    func didEnterGiveAwayContest(){}
}

class WebViewViewController: UIViewController, WKUIDelegate {

    var webView: WKWebView!
    var webUrl: String?
    var returnUrl: String?
    var actionType: String?
    weak var delegate: GenericReturnAction?
    
    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let urlString = webUrl{
            if let url = URL(string: urlString){
                let myRequest = URLRequest(url: url)
                webView.load(myRequest)
            }
            
        }
    }
    
    func returnAction(){
        if let actionType = self.actionType{
            switch actionType{
            case SliderType.giveAway.rawValue:
                navigationController?.popViewController(animated: true)
                delegate?.didEnterGiveAwayContest()
                break
            case SliderType.retailSale.rawValue:
                navigationController?.popViewController(animated: true)
                delegate?.didEnterGiveAwayContest()
                break
            case SliderType.raffle.rawValue:
                break
            default:
                break
            }
        }
    }

}

extension WebViewViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url?.absoluteString{
            if let returnUrl = self.returnUrl{
                if url.contains(returnUrl) {
                    returnAction()
                }
            }
        }
        decisionHandler(.allow)
    }
}
