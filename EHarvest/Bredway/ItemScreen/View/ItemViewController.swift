//
//  ItemViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 11/5/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import FSPagerView
import Kingfisher
import RxSwift
import RxCocoa

class ItemViewController: UIViewController {

    
    @IBOutlet weak var purchaseButton: UIButton! {
        didSet{

        }
    }
    
    @IBOutlet weak var askQuetionsButton: UIButton! {
        didSet{

        }
    }
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "pagerCell")
            self.pagerView.itemSize = .zero
        }
    }
    
    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            self.pageControl.setStrokeColor(UIColor.clear, for: .normal)
            self.pageControl.setFillColor(UIColor.lightGray, for: .normal)
            self.pageControl.numberOfPages = viewModel.imageUrls.count
            self.pageControl.contentHorizontalAlignment = .center
            self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var buttonsViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var editButtonView: UIView!
    @IBOutlet weak var editButton: UIButton!
    
    
    var viewModel: ItemViewModeling!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        purchaseButton.layoutIfNeeded()
        askQuetionsButton.layoutIfNeeded()
 //       purchaseButton.addBorderWithView(toSide: .Top, withColor: ColorDesign.flatBlackDark, andThickness: 1)
    //    purchaseButton.addBorderWithView(toSide: .Bottom, withColor: ColorDesign.flatBlackDark, andThickness: 1)
        purchaseButton.addBorderWithView(toSide: .Right, withColor: UIColor.white, andThickness: 0.5)
       // askQuetionsButton.addBorderWithView(toSide: .Top, withColor: ColorDesign.flatBlackDark, andThickness: 1)
        //askQuetionsButton.addBorderWithView(toSide: .Bottom, withColor: ColorDesign.flatBlackDark, andThickness: 1)
        askQuetionsButton.addBorderWithView(toSide: .Left, withColor: UIColor.white, andThickness: 0.5)
    }
    
    
    func setupView(){
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        editButtonView.isHidden = true
        
        if viewModel.isFavourite{
            configureHeartImage(isFavourite: true)
        } else {
            configureHeartImage(isFavourite: false)
        }
        
        if let timeStamp = Int(viewModel.timeStamp){
            timeLabel.text = TimeStampHelper.shared.getTime(timeStamp: timeStamp)
        }
        brandLabel.text = viewModel.brand
        itemNameLabel.text =  viewModel.itemName + " - " + (viewModel.itemSize )
        priceLabel.text = "$" + String(viewModel.price )
        descriptionLabel.text = viewModel.itemDescription
        shippingLabel.text = ( viewModel.shippingLabel ) + " - $5"
        usernameLabel.text = ""
        ratingLabel.text = viewModel.sellerRating
        
        if viewModel.isSold == true{
            purchaseButton.isEnabled = false
        }
        
        if viewModel.sellerId == UserManager.shared.currentUserId{
            buttonsView.isHidden = true
            buttonsViewHeightConstraint.constant = 0
            editButtonView.isHidden = false
        }
        
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
        
        purchaseButton.rx.tap
            .bind(to: viewModel.purchaseButtonPressed)
            .disposed(by: disposeBag)
        
        askQuetionsButton.rx.tap
            .bind(to: viewModel.askButtonPressed)
            .disposed(by: disposeBag)
        
        editButton.rx.tap
            .bind(to: viewModel.editButtonPressed)
            .disposed(by: disposeBag)
        
        heartButton.rx.tap
            .throttle(2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                if UserManager.shared.isLoggedIn{
                    if !self.viewModel.itemId.isEmpty && UserManager.shared.isFavouriteItem(itemId: self.viewModel.itemId){
                        self.switchHeartImage(isFavourite: true)
                    } else {
                        self.switchHeartImage(isFavourite: false)
                    }
                    self.viewModel.heartButtonPressed.onNext(())
                } else {
                    self.showLoginView(willSelectIndex: 0)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.presentPayment
            .subscribe(onNext: { [weak self] (paymentViewModel) in
                self?.performSegue(withIdentifier: "toPayWithPayPal", sender: paymentViewModel)
            })
            .disposed(by: disposeBag)
        
        viewModel.presentChatroom
            .subscribe(onNext: { [weak self] (chatroomViewModel) in
                self?.showChatroom(chatroomViewModel: chatroomViewModel)
            })
            .disposed(by: disposeBag)
        
        viewModel.presentEditItem
            .subscribe(onNext: { [weak self] (editItemViewModel) in
                self?.showEditItem(editItemViewModel: editItemViewModel)
            })
            .disposed(by: disposeBag)
    }
    
    func showChatroom(chatroomViewModel: ChatroomViewModeling){
        let storyboard = UIStoryboard(name: "ChatroomScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"chatroomViewControllerId") as! ChatroomViewController
        viewController.viewModel = chatroomViewModel
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showEditItem(editItemViewModel: EditItemViewModeling){
        let storyboard = UIStoryboard(name: "ProfileScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"EditItemViewControllerId") as! EditItemViewController
        viewController.viewModel = editItemViewModel
        viewController.isFromOtherView = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showLoginView(willSelectIndex: Int){
        let storyboard = UIStoryboard(name: "LoginScreen", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
        controller.selectedIndex = willSelectIndex
        //controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    func configureHeartImage(isFavourite: Bool){
        if isFavourite{
            if let image = UIImage(named: MasterConstants.ICON_HEART_FILLED){
                heartButton.setImage(image, for: .normal)
            }
        } else {
            if let image = UIImage(named: MasterConstants.ICON_HEART){
                heartButton.setImage(image, for: .normal)
            }
        }
    }
    
    func switchHeartImage(isFavourite: Bool){
        if isFavourite{
            if let image = UIImage(named: MasterConstants.ICON_HEART){
                heartButton.setImage(image, for: .normal)
            }
        } else {
            if let image = UIImage(named: MasterConstants.ICON_HEART_FILLED){
                heartButton.setImage(image, for: .normal)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPayWithPayPal" {
            if let paymentVC = segue.destination as? PaymentViewController {
                if let paymentViewModel = sender as? PaymentViewModeling{
                    paymentVC.viewModel = paymentViewModel
                }
            }
        }
        
    }
    
}

extension ItemViewController: FSPagerViewDataSource, FSPagerViewDelegate{
    
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
        cell.contentView.layer.shadowRadius = 0
        cell.contentView.layer.shadowOpacity = 0
        
        return cell
    }
    
    // MARK:- FSPagerView Delegate
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        self.pageControl.currentPage = index
        
        let storyboard = UIStoryboard(name: "ItemScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"ImageViewControllerId") as! ImageViewController
        let indexPath = IndexPath.init(item: index, section: 0)
        viewController.selectedIndex = indexPath
        viewController.imagesUrl = viewModel.imageUrls
        present(viewController, animated: true, completion: nil)
//        if let navigationController = navigationController {
//            navigationController.pushViewController(viewController, animated: true)
//        } else {
//            present(viewController, animated: true, completion: nil)
//        }
      //  viewController.selectedIndex =
//        let vc = (viewController(forStoryboardName: "ImageViewer") as? ImageViewController)!
//        vc.selectedIndex = indexPath
//        if let navigationController = navigationController {
//            navigationController.pushViewController(vc, animated: true)
//        } else {
//            present(vc, animated: true, completion: nil)
//        }
//        let imageUrl = viewModel.imageUrls[index]
//        var image = UIImage()
//        ImageCache.default.retrieveImage(forKey: imageUrl, options: nil) {
//            newImage, cacheType in
//            if let cachedImage = newImage {
//                image = cachedImage
//                let imageView = UIImageView(image: image)
//                imageView.frame = self.view.frame
//                imageView.backgroundColor = .black
//                imageView.contentMode = .top
//                imageView.isUserInteractionEnabled = true
//                imageView.contentMode = .scaleAspectFit
//                self.navigationController?.isNavigationBarHidden = true
//                let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullscreenImage))
//                imageView.addGestureRecognizer(tap)
//
//                self.view.addSubview(imageView)
//            } else {
//                print("Not exist in cache.")
//            }
//        }
    }
        
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        sender.view?.removeFromSuperview()
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        guard self.pageControl.currentPage != pagerView.currentIndex else {
            return
        }
        self.pageControl.currentPage = pagerView.currentIndex
    }
    
}
