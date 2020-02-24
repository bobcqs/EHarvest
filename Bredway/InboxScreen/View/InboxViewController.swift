//
//  InboxViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 17/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Lottie

class InboxViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var viewModel: InboxViewModeling!
    var animationView = AnimationView()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
//        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUnreadMessageDot(isInboxViewController: true)
        LoadingManager.shared.showIndicator()
        viewModel.getChatroomList()
        
    }
    
    func setupBinding(){
        
        viewModel.chatrooms
            .asObservable().bind(to: tableView.rx.items(cellIdentifier: "inboxCell", cellType: InboxTableViewCell.self)) { row, element, cell in
                cell.configureCell(chatroom: element)
            }.disposed(by: disposeBag)
        
        viewModel.chatrooms
            .subscribe(onNext: { [weak self] chatrooms in
                LoadingManager.shared.hideIndicator()
                if chatrooms.count == 0 {
                    self?.showEmptyView()
                } else {
                    self?.animationView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Chatroom.self)
            .subscribe(onNext: { [weak self] chatroom in
                self?.viewModel.selectedChatroom.onNext(chatroom)
            }).disposed(by: disposeBag)
        
        viewModel.presentChatroom
            .subscribe(onNext: { [weak self] (chatroomViewModel) in
                self?.showChatroom(chatroomViewModel: chatroomViewModel)
            })
            .disposed(by: disposeBag)
    }
    
//    func setupView(){
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        animationView = animationView(name: "EmptyAnimation")
//        animationView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        animationView.contentMode = .scaleAspectFit
//        animationView.frame = view.bounds
//        animationView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
//        animationView.animationSpeed = 1
//        animationView.loopAnimation = true
//        view.addSubview(animationView)
//        animationView.isHidden = true
//    }
    
    func showEmptyView(){
        animationView.isHidden = false
        animationView.play()
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
