//
//  AddShippingViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 24/5/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PaymentViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: InputTextFieldView!
    @IBOutlet weak var addressOneLabel: InputTextFieldView!
    @IBOutlet weak var addressTwoLabel: InputTextFieldView!
    @IBOutlet weak var cityLabel: InputTextFieldView!
    @IBOutlet weak var stateLabel: InputTextFieldView!
    @IBOutlet weak var countryLabel: InputTextFieldView!
    @IBOutlet weak var postCodeLabel: InputTextFieldView!
    @IBOutlet weak var payButton: UIButton!
    
    
    private let disposeBag = DisposeBag()
    var viewModel: PaymentViewModeling!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Shipping Address"
        setupKeyboard()
        setupBinding()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.popToRootViewController(animated: true)
//    }
//    
    func setupBinding(){
        nameLabel.rx.text.orEmpty
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)
        
        addressOneLabel.rx.text.orEmpty
            .bind(to: viewModel.addressOne)
            .disposed(by: disposeBag)
        
        addressTwoLabel.rx.text.orEmpty
            .bind(to: viewModel.addressTwo)
            .disposed(by: disposeBag)
        
        cityLabel.rx.text.orEmpty
            .bind(to: viewModel.city)
            .disposed(by: disposeBag)
        
        stateLabel.rx.text.orEmpty
            .bind(to: viewModel.state)
            .disposed(by: disposeBag)
        
        countryLabel.rx.text.orEmpty
            .bind(to: viewModel.countryCode)
            .disposed(by: disposeBag)
        
        postCodeLabel.rx.text.orEmpty
            .bind(to: viewModel.postCode)
            .disposed(by: disposeBag)
        
        payButton.rx.tap
            .do(onNext: {  _ in
                LoadingManager.shared.showIndicator()
            })
            .bind(to: viewModel.payDidTap)
            .disposed(by: disposeBag)
        
        viewModel.presentPayPalWebview
            .subscribe(onNext: { [weak self] (result, payPalWebViewModel) in
                if result == SubmissionResult.submissionError{
                    LoadingManager.shared.hideIndicatorWithMessage(message: "There is an error, please try again", timeInterval: 2)
                } else {
                    LoadingManager.shared.hideIndicator()
                    self?.performSegue(withIdentifier: "toPayPalWebView", sender: payPalWebViewModel)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.presentConfirmation
            .subscribe(onNext: { [weak self] (result, paymentConfirmationViewModel) in
                if result == PayPalQueryResult.error{
                    //show error to user
                    LoadingManager.shared.hideIndicatorWithMessage(message: "There is an error, please try again later", timeInterval: 1)
                } else {
                    //segue to confirmation
                    LoadingManager.shared.hideIndicator()
                    self?.performSegue(withIdentifier: "toPaymentConfirmation", sender: paymentConfirmationViewModel)
                }
            })
            .disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPayPalWebView" {
            if let payPalWebVC = segue.destination as? PayPalWebViewViewController {
                if let paypalWebViewModel = sender as? PayPalWebViewModeling{
                    payPalWebVC.viewModel = paypalWebViewModel
                    payPalWebVC.delegate  = self
                }
            }
        } else if segue.identifier == "toPaymentConfirmation" {
            if let paymentConfirmationVC = segue.destination as? PaymentConfirmationViewController{
                if let paymentConfirmationViewModel = sender as? PaymentConfirmationViewModeling{
                    paymentConfirmationVC.viewModel = paymentConfirmationViewModel
                }
            }
        }
    }

}

extension PaymentViewController: PayPalPaymentProtocol{
    func didFinishPayment(request: PayPalRequest) {
        viewModel.checkOutDidFinish.onNext(request)
        LoadingManager.shared.showIndicator()
    }
    
    func didFailPayment(request: PayPalRequest) {
        LoadingManager.shared.showIndicator()
        LoadingManager.shared.hideIndicatorWithMessage(message: "Failed to pay, please try again later", timeInterval: 1)
    }
    
}
