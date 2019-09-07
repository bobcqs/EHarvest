//
//  SoldItemViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 3/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import FSPagerView
import Kingfisher
import RxSwift
import RxCocoa

class SingleSoldItemViewController: UIViewController {

    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "pagerCell")
            self.pagerView.itemSize = .zero
        }
    }
    
    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            self.pageControl.numberOfPages = viewModel.imageUrls.count
            self.pageControl.contentHorizontalAlignment = .center
            self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var viewModel: SingleSoldItemViewModeling!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

       setupBinding()
    }
    
    func setupBinding(){
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if let timeStamp = Int(viewModel.timeStamp){
            timeLabel.text = TimeStampHelper.shared.getTime(timeStamp: timeStamp)
        }
        brandLabel.text = viewModel.brand
        itemNameLabel.text = viewModel.itemName
        priceLabel.text = "$" + String(viewModel.price)
        descriptionLabel.text = viewModel.itemDescription
        shippingLabel.text = viewModel.shippingLabel
        usernameLabel.text = ""
        ratingLabel.text = viewModel.sellerRating
        
        viewModel.sellerImageUrl
            .subscribe(onNext: { [weak self] (imageUrl) in
                if let url = URL(string: imageUrl){
                    let image = UIImage(named: "defaultImage")
                    self?.userProfileImage.kf.setImage(with: url, placeholder: image)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.sellerName
            .subscribe(onNext: { [weak self] (sellerName) in
                self?.usernameLabel.text = sellerName
            })
            .disposed(by: disposeBag)
        
    }

}

extension SingleSoldItemViewController: FSPagerViewDataSource, FSPagerViewDelegate{
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return viewModel.imageUrls.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "pagerCell", at: index)
        let imageUrl = viewModel.imageUrls[index]
        if let url = URL(string: imageUrl){
            cell.imageView?.kf.setImage(with: url)
        }
        
        // cell.imageView?.image = UIImage(named: self.imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        return cell
    }
    
    // MARK:- FSPagerView Delegate
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        self.pageControl.currentPage = index
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        guard self.pageControl.currentPage != pagerView.currentIndex else {
            return
        }
        self.pageControl.currentPage = pagerView.currentIndex
    }
    
}
