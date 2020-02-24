//
//  UpdateShipmentViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 1/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UpdateShipmentViewController: UIViewController {
    
    @IBOutlet weak var buyerNameLabel: UILabel!
    @IBOutlet weak var buyerAddressLabel: UILabel!
    @IBOutlet weak var courierCompanyLabel: InputTextFieldView!
    @IBOutlet weak var trackingNumberLabel: InputTextFieldView!
    @IBOutlet weak var updateListButton: UIButton!
    
    var viewModel: UpdateShipmentViewModeling!
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboard()
        setupBinding()
    }
    
    func setupBinding(){
        courierCompanyLabel.rx.text.orEmpty
            .bind(to: viewModel.courierCompany)
            .disposed(by: disposeBag)
        
        trackingNumberLabel.rx.text.orEmpty
            .bind(to: viewModel.trackingNumber)
            .disposed(by: disposeBag)
        
        updateListButton.rx.tap
            .do(onNext: {
                LoadingManager.shared.showIndicator()
            })
            .bind(to: viewModel.updateButtonDidPress)
            .disposed(by: disposeBag)
        
        viewModel.submissionResult.subscribe(onNext: { [weak self] result in
            switch result {
            case .submissionSuccess:
                LoadingManager.shared.hideIndicator()
                self?.navigationController?.popViewController(animated: true)
                break
            case .submissionFail:
                LoadingManager.shared.hideIndicatorWithMessage(message: "Please try again later", timeInterval: 2)
                break
            default:
                LoadingManager.shared.hideIndicator()
                break
            }
        })
        .disposed(by: disposeBag)
        
        buyerNameLabel.text = viewModel.buyerName
        buyerAddressLabel.text = viewModel.buyerAddress
    }

}
