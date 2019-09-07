//
//  PayPalWebViewViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 3/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import WebKit

protocol PayPalPaymentProtocol: class {
    func didFinishPayment(request: PayPalRequest)
    func didFailPayment(request: PayPalRequest)
}

class PayPalWebViewViewController: UIViewController, WKUIDelegate {

    var webView: WKWebView!
    var viewModel: PayPalWebViewModeling!
    var isPaymentSuccessful = false
    weak var delegate: PayPalPaymentProtocol?
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string:viewModel.webUrl)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isPaymentSuccessful == false{
            delegate?.didFailPayment(request: viewModel.request)
        }
    }
}

extension PayPalWebViewViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url?.absoluteString{
            if let returnUrl = viewModel.request.returnUrl{
                if url.contains(returnUrl) {
                    isPaymentSuccessful = true
                    navigationController?.popViewController(animated: true)
                    delegate?.didFinishPayment(request: viewModel.request)
                }
            }
        }
        decisionHandler(.allow)
    }
}
