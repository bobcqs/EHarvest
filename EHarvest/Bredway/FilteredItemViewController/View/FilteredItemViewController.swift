//
//  FilteredItemViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 31/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FilteredItemViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: FilteredItemViewModeling!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBinding()
    }
    
    func setupBinding(){
        viewModel.items
            .asObservable().bind(to: self.collectionView.rx.items(cellIdentifier: "buyCell", cellType: BuyCollectionViewCell.self)) { row, data, cell in
                cell.item = data
                cell.heartImage.rx.tap
                    .throttle(2, scheduler: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] _ in
                        if UserManager.shared.isLoggedIn{
                            if let itemId = data.itemId{
                                if UserManager.shared.isFavouriteItem(itemId: itemId){
                                    cell.switchHeartImage(isFavourite: true)
                                } else {
                                    cell.switchHeartImage(isFavourite: false)
                                }
                            }
                            self?.viewModel.likedItemIndex.onNext(row)
                        } else {
                            self?.showLoginView(willSelectIndex: 0)
                        }
                    })
                    .disposed(by: cell.disposeBag)
            }.disposed(by: disposeBag)
        
        // add this line you can provide the cell size from delegate method
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(Item.self)
            .subscribe(onNext: { [weak self] item in
                self?.showItem(item: item)
            }).disposed(by: disposeBag)
    }
    
    func showLoginView(willSelectIndex: Int){
        let storyboard = UIStoryboard(name: "LoginScreen", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
        controller.selectedIndex = willSelectIndex
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    func showItem(item: Item){
        let storyboard = UIStoryboard(name: "ItemScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"itemViewControllerId") as! ItemViewController
        let itemViewModel = ItemViewModel(item: item, firebaseService: FirebaseService())
        viewController.viewModel = itemViewModel
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let nbCol = 2
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.sectionInset.left = 8
        flowLayout.sectionInset.right = 8
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(nbCol - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(nbCol))
        return CGSize(width: size, height: 275)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8,8,8,8)
    }

}

extension FilteredItemViewController: SwitchTabProtocol{
    func switchTab(selectIndex: Int) {
        tabBarController?.selectedIndex = selectIndex
    }
}
