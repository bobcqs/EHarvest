//
//  TrackingViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 3/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class TrackingViewController: UIViewController {

    @IBOutlet weak var referenceIdLabel: UILabel!
    @IBOutlet weak var courierCompanyLabel: UILabel!
    @IBOutlet weak var trackingLabel: UILabel!
    
    
    var viewModel: TrackingViewModeling!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBinding()
    }
    
    func setupBinding(){
        referenceIdLabel.text = viewModel.referenceId
        courierCompanyLabel.text = viewModel.courierCompany
        trackingLabel.text = viewModel.trackingNumber
    }



}
