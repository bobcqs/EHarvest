//
//  FavouriteListViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 25/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Lottie

class FavouriteListViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var animationView = AnimationView()
    var viewModel: FavouriteListViewModeling!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBinding()
        viewModel.getFavouriteItems()   
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func setupView(){
//        animationView = animationView(name: "EmptyAnimation")
//        animationView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        animationView.contentMode = .scaleAspectFit
//        animationView.frame = view.bounds
//        animationView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
//        animationView.animationSpeed = 1
//        animationView.loopAnimation = true
//        view.addSubview(animationView)
//        animationView.isHidden = true
    }
    
    func setupBinding(){
        viewModel.items
            .asObservable().bind(to: self.collectionView.rx.items(cellIdentifier: "buyCell", cellType: BuyCollectionViewCell.self)) { row, data, cell in
                cell.item = data
                cell.heartImage.rx.tap
                    .throttle(2, scheduler: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] _ in
                        if let itemId = data.itemId{
                            if UserManager.shared.isFavouriteItem(itemId: itemId){
                                cell.switchHeartImage(isFavourite: true)
                            } else {
                                cell.switchHeartImage(isFavourite: false)
                            }
                        }
                        self?.viewModel.likedItemIndex.onNext(row)
                    })
                    .disposed(by: cell.disposeBag)
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
        
        // add this line you can provide the cell size from delegate method
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(Item.self)
            .subscribe(onNext: { [weak self] item in
                self?.showItem(item: item)
            }).disposed(by: disposeBag)
    }
    
    func showEmptyView(){
        animationView.isHidden = false
        animationView.play()
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
