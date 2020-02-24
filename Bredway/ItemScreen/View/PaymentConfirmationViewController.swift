//
//  PaymentConfirmationViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 7/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PaymentConfirmationViewController: UIViewController {

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var confirmationButton: UIButton!
    
    var viewModel: PaymentConfirmationViewModeling!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBinding()
    }
    
    func setupBinding(){
        //Item name label
        itemLabel.text = viewModel.response.itemName ?? ""
        
        //Item price label
        let itemPrice: Double
        if let price = viewModel.response.paymentAmount {
            itemPrice = Double(price) ?? 0
        } else {
            itemPrice = 0
        }
        let comissionAmount: Double
        if let comission = viewModel.response.commissionAmount{
            comissionAmount = Double(comission) ?? 0
        } else {
            comissionAmount = 0
        }
        priceLabel.text = "$" + String(itemPrice + comissionAmount)
        
        //shipping address
        let shipToName = viewModel.response.shipToName ??  ""
        let shipToStreet = viewModel.response.shipToStreet ?? ""
        let shipToCity = viewModel.response.shipToCity ?? ""
        let shipToState = viewModel.response.shipToState ?? ""
        let shipToZip = viewModel.response.shipToZip ?? ""
        let shipToCountry = viewModel.response.countryCode ?? ""
        let finalAddress = shipToName + ", " + shipToStreet + " " + shipToCity + " " + shipToState.uppercased() + " " + shipToCountry.uppercased() + ", " + shipToZip
        shippingLabel.text = finalAddress
        
        confirmationButton.rx.tap
            .do(onNext: {  _ in
                LoadingManager.shared.showIndicator()
            })
            .bind(to: viewModel.confirmationDidTap)
            .disposed(by: disposeBag)
        
        viewModel.submissionResult
            .subscribe(onNext:  { [weak self] (result) in
                if result == PayPalQueryResult.error {
                    LoadingManager.shared.hideIndicatorWithMessage(message: "There is an error, please try again later or contact our support", timeInterval: 2)
                } else {
                    LoadingManager.shared.hideIndicator()
                    guard let _ = self else {
                        return
                    }
                    
                    guard let _ = self?.navigationController else {
                        return
                    }
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
    }

}
