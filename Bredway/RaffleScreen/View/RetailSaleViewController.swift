//
//  RetailSaleViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 19/9/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RetailSaleViewController: UIViewController, GenericReturnAction  {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: RetailSaleViewModeling?
    var selectedImageUrl: String?
    var instagramCaption: String?
    var facebookCaption: String?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBinding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: .stopRaffleTimer, object: nil, userInfo: nil)
        super.viewDidDisappear(animated)
    }
    
    func setupBinding(){
        viewModel?.sliders
            .drive(tableView.rx.items(cellIdentifier: "RetailSaleTableViewCell", cellType: RetailSaleTableViewCell.self)) { (row, element, cell) in
                cell.retailSlider = element
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(RetailSlider.self)
            .subscribe(onNext: { [weak self] (slider) in
                self?.selectedImageUrl = slider.shareImageUrl
                self?.instagramCaption = slider.captionForInstagram
                self?.facebookCaption = slider.captionForFacebook
                if let actionType = slider.actionType{
                    switch actionType{
                    case SliderType.webUrl.rawValue:
                        let storyboard = UIStoryboard(name: "WebViewScreen", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier :"WebViewViewControllerId") as! WebViewViewController
                        viewController.webUrl = slider.filterContent
                        self?.navigationController?.pushViewController(viewController, animated: true)
                        break
                    case SliderType.filter.rawValue:
                        break
                    case SliderType.retailSale.rawValue:
//                        URLCache.shared.removeAllCachedResponses()
//                        URLCache.shared.diskCapacity = 0
//                        URLCache.shared.memoryCapacity = 0
//
//                        if let cookies = HTTPCookieStorage.shared.cookies {
//                            print (cookies)
//                            for cookie in cookies {
//                                HTTPCookieStorage.shared.deleteCookie(cookie)
//                            }
//                        }
//
//                        let cookie = HTTPCookie.self
//                        let cookieJar = HTTPCookieStorage.shared
//
//                        for cookie in cookieJar.cookies! {
//                            cookieJar.deleteCookie(cookie)
//                        }
                        
                        let storyboard = UIStoryboard(name: "WebViewScreen", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier :"WebViewViewControllerId") as! WebViewViewController
                        viewController.webUrl = slider.filterContent
                        viewController.returnUrl = slider.returnUrl
                        viewController.delegate = self
                        viewController.actionType = slider.actionType
                        self?.navigationController?.pushViewController(viewController, animated: true)
                        break
                    default:
                        break
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    func didEnterGiveAwayContest() {
        let storyboard = UIStoryboard(name: "RaffleScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"RaffleLastStepViewController") as! RaffleLastStepViewController
        viewController.facebookCaption = facebookCaption
        viewController.instagramCaption = instagramCaption
        viewController.selectedImageUrl = selectedImageUrl
        navigationController?.pushViewController(viewController, animated: true)
    }

}
