//
//  SoldItemsViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 30/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Lottie

class SoldItemsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var animationView = AnimationView()
    var viewModel: SoldItemViewModeling!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupView()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LoadingManager.shared.showIndicator()
        viewModel.getListingItems()
    }
    
//    func setupView(){
//        animationView = LOTAnimationView(name: "EmptyAnimation")
//        animationView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        animationView.contentMode = .scaleAspectFit
//        animationView.frame = view.bounds
//        animationView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
//        animationView.animationSpeed = 1
//        animationView.loopAnimation = true
//        view.addSubview(animationView)
//        animationView.isHidden = true
//    }
    
    func setupBinding(){
        
        viewModel.items
            .asObservable().bind(to: tableView.rx.items(cellIdentifier: "soldItemCell", cellType: SoldItemTableViewCell.self)) { row, element, cell in
                cell.configureCell(item: element)
                cell.shipmentButton.rx.tap.subscribe{ [unowned self] item in
                    self.performSegue(withIdentifier: "toUpdateShipment", sender: element)
                    }.disposed(by: cell.disposeBag)
                cell.askBuyerButton.rx.tap.subscribe{ [unowned self] item in
                    self.viewModel.selectedItem.onNext(element)
                    }.disposed(by: cell.disposeBag)
            }.disposed(by: disposeBag)
        
        viewModel.items
            .subscribe(onNext: { [weak self] items in
                LoadingManager.shared.hideIndicator()
                if items.count == 0 {
                    self?.showEmptyView()
                } else {
                    self?.animationView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(SoldItem.self)
            .subscribe(onNext: { [weak self] item in
                self?.showItem(item: item)
            }).disposed(by: disposeBag)
        
        viewModel.presentChatroom
            .subscribe(onNext: { [weak self] (chatroomViewModel) in
                self?.showChatroom(chatroomViewModel: chatroomViewModel)
            })
            .disposed(by: disposeBag)
    }
    
    func showEmptyView(){
        animationView.isHidden = false
        animationView.play()
    }
    
    func showItem(item: SoldItem){
        let storyboard = UIStoryboard(name: "SoldItemScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"singleSoldItemViewControllerId") as! SingleSoldItemViewController
        let firebaseService = FirebaseService()
        let singleSoldItemViewModel = SingleSoldItemViewModel(item: item, firebaseService: firebaseService)
        viewController.viewModel = singleSoldItemViewModel
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showChatroom(chatroomViewModel: ChatroomViewModeling){
        let storyboard = UIStoryboard(name: "ChatroomScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"chatroomViewControllerId") as! ChatroomViewController
        viewController.viewModel = chatroomViewModel
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUpdateShipment" {
            if let updateShipmentVC = segue.destination as? UpdateShipmentViewController {
                if let item = sender as? SoldItem {
                    let firebaseService = FirebaseService()
                    updateShipmentVC.viewModel = UpdateShipmentViewModel(item: item, firebaseService: firebaseService)
                }
            }
        }
    }

}
