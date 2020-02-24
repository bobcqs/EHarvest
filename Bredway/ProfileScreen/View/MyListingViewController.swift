//
//  MyListingViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 18/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Lottie

class MyListingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var animationView = AnimationView()
    var viewModel: MyListingViewModeling!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getListingItems()
    }
    
    func setupView(){
//        animationView = animationView(name: "EmptyAnimation")
        animationView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        animationView.contentMode = .scaleAspectFit
        animationView.frame = view.bounds
        animationView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        animationView.animationSpeed = 1
  //      animationView.loopAnimation = true
        view.addSubview(animationView)
        animationView.isHidden = true
    }

    func setupBinding(){
        
        viewModel.items
            .asObservable().bind(to: tableView.rx.items(cellIdentifier: "myListingCell", cellType: MyListingTableViewCell.self)) { row, element, cell in
                cell.configureCell(item: element)
                cell.editButton.rx.tap.subscribe{ [unowned self] item in
                    self.performSegue(withIdentifier: "toEditItem", sender: element)
                    }.disposed(by: cell.disposeBag)
            }.disposed(by: disposeBag)
        
        viewModel.items
            .subscribe(onNext: { [weak self] items in
                if items.count == 0 {
                    self?.showEmptyView()
                } else {
                    self?.animationView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
    }
    
    func showEmptyView(){
        animationView.isHidden = false
        animationView.play()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditItem" {
            if let editItemVC = segue.destination as? EditItemViewController {
                if let itemToBeEdited = sender as? Item {
                    let firebaseService = FirebaseService()
                    editItemVC.viewModel = EditItemViewModel(itemToBeEdited: itemToBeEdited, firebaseService: firebaseService)
                }
            }
        }
    }

    
}
