//
//  ProfileViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 28/3/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

class ProfileViewController: UIViewController, UITabBarControllerDelegate{
    
    @IBOutlet weak var profileImage: ProfileImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var editProfileButton: MainStyleButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    
    var viewModel: ProfileViewModeling!
    private let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(showMyListing), name: .showMyListing, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self

        setupBinding()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUnreadMessageDot(isInboxViewController: false)
        let image = UIImage(named: "profilePhoto")
        if let url = URL(string: UserManager.shared.currentUserImageUrl){
            profileImage.kf.setImage(with: url, placeholder: image)
        } else {
            profileImage.image = image
        }
        userName.text = UserManager.shared.currentUserName
    }
    
    func setupView(){
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    func setupBinding(){
        
        viewModel.profileOptions
            .asObservable().bind(to: tableView.rx.items(cellIdentifier: "profileOptionCell", cellType: ProfileTableViewCell.self)) { row, element, cell in
                cell.configureCell(item: element)
            }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ProfileOption.self)
            .subscribe(onNext: { (profileOption) in
                let firebaseService = FirebaseService()
                switch profileOption{
                case .myListing:
                    let myListingViewModel = MyListingViewModel(firebaseService: firebaseService)
                    self.performSegue(withIdentifier: "toMyListing", sender: myListingViewModel)
                    break
                case .soldItems:
                    let soldItemViewModel = SoldItemViewModel(firebaseService: firebaseService)
                    self.performSegue(withIdentifier: "toSoldItems", sender: soldItemViewModel)
                    break
                case .purchases:
                    let purchasesViewModel = PurchasesViewModel(firebaseService: firebaseService)
                    self.performSegue(withIdentifier: "toPurchases", sender: purchasesViewModel)
                    break
                case .favourites:
                    let favouriteListViewModel = FavouriteListViewModel(firebaseService: firebaseService)
                    self.performSegue(withIdentifier: "toFavouriteList", sender: favouriteListViewModel)
                    break
                case .settings:
                    self.performSegue(withIdentifier: "toSettings", sender: nil)
                    break
                case .contactUs:
                    let email = "contact@bredway.com.au"
                    if let url = URL(string: "mailto:\(email)") {
                            UIApplication.shared.open(url)
                        }
                }
            })
            .disposed(by: disposeBag)
        
        editProfileButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let editProfileViewModel = EditProfileViewModel(firebaseService: FirebaseService())
                self?.performSegue(withIdentifier: "toEditProfile", sender: editProfileViewModel)
            })
            .disposed(by: disposeBag)
        
    }
    
    @objc func showMyListing(){
        let firebaseService = FirebaseService()
        let myListingViewModel = MyListingViewModel(firebaseService: firebaseService)
        self.performSegue(withIdentifier: "toMyListing", sender: myListingViewModel)
    }
    
    override func viewWillLayoutSubviews() {
        tableViewHeightConstraint.constant = tableView.contentSize.height
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMyListing" {
            if let myListingVC = segue.destination as? MyListingViewController {
                if let myListingViewModel = sender as? MyListingViewModeling{
                    myListingVC.viewModel = myListingViewModel
                }
            }
        } else if segue.identifier == "toFavouriteList" {
            if let favouriteListVC = segue.destination as? FavouriteListViewController {
                if let favouriteListViewModel = sender as? FavouriteListViewModeling{
                    favouriteListVC.viewModel = favouriteListViewModel
                }
            }
        } else if segue.identifier == "toSoldItems" {
            if let soldItemsVC = segue.destination as? SoldItemsViewController {
                if let soldItemViewModel = sender as? SoldItemViewModeling{
                    soldItemsVC.viewModel = soldItemViewModel
                }
            }
        } else if segue.identifier == "toPurchases" {
            if let purchasesVC = segue.destination as? PurchasesViewController {
                if let purchasesViewModel = sender as? PurchasesViewModeling{
                    purchasesVC.viewModel = purchasesViewModel
                }
            }
        } else if segue.identifier == "toSettings" {
            if let settingsVC = segue.destination as? SettingsViewController {
                settingsVC.tabDelegate = self
            }
        } else if segue.identifier == "toEditProfile" {
            if let editProfileVC = segue.destination as? EditProfileViewController{
                if let editProfileViewModel = sender as? EditProfileViewModeling{
                    editProfileVC.viewModel = editProfileViewModel
                }
            }
        }
    }
    
}

extension ProfileViewController: SwitchTabProtocol{
    func switchTab(selectIndex: Int) {
        tabBarController?.selectedIndex = selectIndex
    }
}
