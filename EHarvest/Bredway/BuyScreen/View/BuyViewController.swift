//
//  FirstViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 11/3/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Lottie
import FSPagerView

class BuyViewController: UIViewController, UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var searchView: RoundedView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var smallFilterCollectionView: UICollectionView!
    @IBOutlet weak var smallFilterCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var brandFilterCollectionView: UICollectionView!
    
    //Retail sale
    @IBOutlet weak var retailSaleView: UIView!
    @IBOutlet weak var retailSaleLabel: UILabel!
    @IBOutlet weak var retailSaleQuantityLabel: UILabel!
    @IBOutlet weak var retailSaleItemLabel: UILabel!
    @IBOutlet weak var retailSaleNewPrice: UILabel!
    @IBOutlet weak var retailSaleOriginalPrice: UILabel!
    @IBOutlet weak var retailSaleItemImageView: UIImageView!
    
    //Give away
    @IBOutlet weak var giveAwayView: UIView!
    @IBOutlet weak var giveAwayLabel: UILabel!
    @IBOutlet weak var giveAwayItemLabel: UILabel!
    @IBOutlet weak var giveAwayNewPrice: UILabel!
    @IBOutlet weak var giveAwayOriginalPrice: UILabel!
    @IBOutlet weak var giveAwayItemImageView: UIImageView!
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "pagerCell")
            self.pagerView.itemSize = .zero
            self.pagerView.isInfinite = true
            self.pagerView.automaticSlidingInterval = 3.0
            self.pagerView.transformer = FSPagerViewTransformer(type: .crossFading)
        }
    }
    
    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            self.pageControl.setStrokeColor(UIColor.clear, for: .normal)
            self.pageControl.setFillColor(UIColor.lightGray, for: .normal)
            self.pageControl.contentHorizontalAlignment = .right
            self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    
    var viewModel: BuyViewModeling!
    var itemsCount: Int?
    var shouldFetchMore = true
    var refreshControl = UIRefreshControl()
    
    let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBuyScreen), name: .refreshBuyScreen, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupBinding()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        setupUnreadMessageDot(isInboxViewController: false)
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.delegate = self
        refreshControl.didMoveToSuperview()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topView.layoutIfNeeded()
        topView.addBorder(toSide: .Bottom, withColor: UIColor.gray.cgColor, andThickness: 0.2)
    }
    
    func setupView() {

        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        searchView.addGestureRecognizer(gesture)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //smallFilterCollectionViewHeightConstraint.constant = 0

        //retailSaleView.isHidden = true
        //giveAwayView.isHidden = true

    }
    
    func setupBinding(){
        contentScrollView.delegate = self
        refreshControl = UIRefreshControl()
        //contentScrollView.addSubview(refreshControl)
        contentScrollView.refreshControl = refreshControl
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map { [refreshControl] in
                return refreshControl.isRefreshing
            }.filter { $0 == true }
            .map { _ in return () }
            .do(onNext: { [weak self] _ in
                self?.shouldFetchMore = true
                logger.debug("Start to refresh the items")
            })
            .bind(to: viewModel.pullToRefresh)
            .disposed(by: disposeBag)

        collectionView.alwaysBounceVertical = true
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
        
        viewModel.updateListSuccess
            .subscribe(onNext: { (result) in
                if result == FirebaseQueryResult.error{
                    
                } else if result == FirebaseQueryResult.success{
                    
                }
            })
            .disposed(by: disposeBag)

        viewModel.refreshEnd
            .subscribe(onNext: { value in
                if self.refreshControl.isRefreshing{
                    self.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.items
            .scan([Item]()) { [weak self] (previousItems: [Item], currentItems: [Item])  in
                if previousItems.count != currentItems.count || self?.shouldFetchMore == true {
                    self?.shouldFetchMore = true
                } else {
                    self?.shouldFetchMore = false
                }
                return currentItems
            }
            .subscribe(onNext: { [weak self] items in
                self?.itemsCount = items.count
                logger.debug("More items are fetched successfully, ready to fetch more now")
               // self?.collectionView.layoutIfNeeded()
                if let height = self?.collectionView.collectionViewLayout.collectionViewContentSize.height, let constraintHeightConstant = self?.collectionViewHeightConstraint.constant{
                    if constraintHeightConstant < height || constraintHeightConstant >= 370{
                        self?.collectionViewHeightConstraint.constant = height
                    }
                }
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(Item.self)
            .subscribe(onNext: { [weak self] item in
                self?.showItem(item: item)
            }).disposed(by: disposeBag)
        
        viewModel.getSliderResult
            .subscribe(onNext: { [weak self] (result) in
                if result == FirebaseQueryResult.success{
                    if let count = self?.viewModel.mainSlider.sliders?.count{
                        self?.pageControl.numberOfPages = count
                        self?.pagerView.reloadData()
                        //self?.smallFilterCollectionView.reloadData()
                    //    self?.brandFilterCollectionView.reloadData()
                        //self?.refreshRetailSliderView()
                       // self?.refreshGiveAwaySliderView()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // add this line you can provide the cell size from delegate method
//        smallFilterCollectionView.dataSource = self
    //    smallFilterCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
       // brandFilterCollectionView.dataSource = self
        //brandFilterCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        //add gesture to retail sale view
      //  let retailSaleTap = UITapGestureRecognizer(target: self, action:  #selector(self.showRetailSaleView))
      //  retailSaleView.addGestureRecognizer(retailSaleTap)
        
        //add gesture to give away view
        //let giveAwayTap = UITapGestureRecognizer(target: self, action:  #selector(self.showGiveAwaySaleView))
      //  giveAwayView.addGestureRecognizer(giveAwayTap)
        
    }
    
    func refreshRetailSliderView(){
        if let retailSliders =  viewModel.mainSlider.retailSliders, retailSliders.count > 0{
        //    retailSaleView.isHidden = false
            
            let retailSlider = retailSliders[0]
            //retailSaleLabel.text = retailSlider.retailSaleLabel?.uppercased()
           // retailSaleQuantityLabel.text = retailSlider.retailSaleQuantity
            //retailSaleItemLabel.text = retailSlider.name?.uppercased()
            //retailSaleNewPrice.text = retailSlider.newPrice
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: retailSlider.originalPrice ?? "")
            attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            //retailSaleOriginalPrice.text = retailSlider.originalPrice
            //retailSaleOriginalPrice.attributedText = attributeString
            
            if let imageUrl = retailSlider.imageUrl{
                if let url = URL.init(string: imageUrl){
                   // retailSaleItemImageView.kf.setImage(with: url)
                }
            }

        }
    }
    
//    func refreshGiveAwaySliderView(){
//        if let giveAwaySliders =  viewModel.mainSlider.giveAwaySliders, giveAwaySliders.count > 0{
//   //         giveAwayView.isHidden = false
//
//            let giveAwaySlider = giveAwaySliders[0]
//         //   giveAwayLabel.text = giveAwaySlider.retailSaleLabel?.uppercased()
//            giveAwayItemLabel.text = giveAwaySlider.name?.uppercased()
//            giveAwayNewPrice.text = giveAwaySlider.newPrice
//            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: giveAwaySlider.originalPrice ?? "")
//            attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
//            giveAwayOriginalPrice.attributedText = attributeString
//
//            if let imageUrl = giveAwaySlider.imageUrl{
//                if let url = URL.init(string: imageUrl){
//                    giveAwayItemImageView.kf.setImage(with: url)
//                }
//            }
//
//        }
//    }
//
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0{
            changeTabBar(hidden: true, animated: true)
        }
        else{
            changeTabBar(hidden: false, animated: true)
        }
    }
    
//    func changeTabBar(hidden:Bool, animated: Bool){
//        guard let tabBar = self.tabBarController?.tabBar else { return; }
//        if tabBar.isHidden == hidden{ return }
//        let frame = tabBar.frame
//        let offset = hidden ? frame.size.height : -frame.size.height
//        let duration:TimeInterval = (animated ? 0.5 : 0.0)
//        tabBar.isHidden = false
//
//        UIView.animate(withDuration: duration, animations: {
//            tabBar.frame = frame.offsetBy(dx: 0, dy: offset)
//        }, completion: { (true) in
//            tabBar.isHidden = hidden
//        })
//    }
    
    func changeTabBar(hidden:Bool, animated: Bool){
        let tabBar = self.tabBarController?.tabBar
        let offset = (hidden ? UIScreen.main.bounds.size.height : UIScreen.main.bounds.size.height - (tabBar?.frame.size.height)! )
        if offset == tabBar?.frame.origin.y {return}
        let duration:TimeInterval = (animated ? 0.5 : 0.0)
        UIView.animate(withDuration: duration,
                       animations: {tabBar!.frame.origin.y = offset},
                       completion:nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == contentScrollView{
            if (((scrollView.contentOffset.y + scrollView.frame.size.height) > (scrollView.contentSize.height - 200)) && shouldFetchMore){
                    logger.debug("Reach to the bottom and ready to load more content")
                    shouldFetchMore = false
                    viewModel.shouldStartFetch.onNext(())
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.collectionView {
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
        } else if collectionView == self.smallFilterCollectionView{
            return CGSize(width: 75, height: 60)
        } else if collectionView == self.brandFilterCollectionView{
            return CGSize(width: 100, height: 130)
        } else {
            return CGSize(width: 60, height: 60)
        }


    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.collectionView {
            return UIEdgeInsetsMake(8,8,8,8)
        } else if collectionView == self.smallFilterCollectionView{
            return UIEdgeInsetsMake(0,0,0,0)
        } else if collectionView == self.brandFilterCollectionView{
            return UIEdgeInsetsMake(0,0,0,0)
        } else {
            return UIEdgeInsetsMake(8,8,8,8)
        }
    }
    
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "toSearch", sender: nil)
    }
    
    @IBAction func filterDidTap(_ sender: Any) {
        performSegue(withIdentifier: "toFilter", sender: nil)
    }
    
    @objc func refreshBuyScreen(){
        refreshControl.beginRefreshing()
        refreshControl.sendActions(for: .valueChanged)
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
    
    func showFilteredItemView(filteredItemViewModel: FilteredItemViewModeling){
        let storyboard = UIStoryboard(name: "FilteredItemScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"filteredItemViewControllerId") as! FilteredItemViewController
        viewController.viewModel = filteredItemViewModel
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func showRetailSaleView(){
        let storyboard = UIStoryboard(name: "RaffleScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"RetailSaleViewControllerId") as! RetailSaleViewController
        let retailSliderViewModel = RetailSaleViewModel.init(firebaseService: FirebaseService())
        viewController.viewModel = retailSliderViewModel
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func showGiveAwaySaleView(){
        let storyboard = UIStoryboard(name: "RaffleScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"GiveAwayViewControllerId") as! GiveAwayViewController
        let giveAwaySliderViewModel = GiveAwayViewModel.init(firebaseService: FirebaseService())
        viewController.viewModel = giveAwaySliderViewModel
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toSearch" {
            if let searchItemVC = segue.destination as? SearchItemViewController {
                let firebaseService = FirebaseService()
                let algoliaService = AlgoliaSearchService()
                let viewModel = SearchItemViewModel(firebaseService: firebaseService, algoliaService: algoliaService)
                searchItemVC.viewModel = viewModel
            }
        } else if segue.identifier == "toFilter" {
            if let filterVC = segue.destination as? FilterViewController {
                let firebaseService = FirebaseService()
                let algoliaService = AlgoliaSearchService()
                let viewModel = FilterViewModel(firebaseService: firebaseService, algoliaService: algoliaService)
                filterVC.viewModel = viewModel
            }
        }
        
    }

}

extension BuyViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.smallFilterCollectionView{
            return 1
        } else if collectionView == self.brandFilterCollectionView{
            return 1
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.smallFilterCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SmallFilterCell",
                                                          for: indexPath) as! SmallFilterCell
            if let smallFilters = viewModel.mainSlider.smallFilters{
                let smallFilter = smallFilters[indexPath.item]
                cell.smallFilter = smallFilter
            }
            return cell
        } else if collectionView == self.brandFilterCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrandFilterCell",
                                                          for: indexPath) as! BrandFilterCell
            if let brandFilters = viewModel.mainSlider.brandFilters{
                let brandFilter = brandFilters[indexPath.item]
                cell.brandFilter = brandFilter
            }
            return cell
        }
        
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.smallFilterCollectionView{
            if let count = viewModel.mainSlider.smallFilters?.count{
                return count
            } else {
                return 0
            }
        } else if collectionView == self.brandFilterCollectionView{
            if let count = viewModel.mainSlider.brandFilters?.count{
                return count
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == smallFilterCollectionView{
            if let smallFilters = viewModel.mainSlider.smallFilters{
                let smallFilter = smallFilters[indexPath.item]
                if let actionType = smallFilter.actionType{
                    switch actionType{
                    case SliderType.filter.rawValue:
                        if let filterText = smallFilter.filterContent{
                            let filteredItemViewModel = FilteredItemViewModel.init(algoliaService: AlgoliaSearchService(), firebaseService: FirebaseService(), filterType: ItemFilterType.lightSearch, filterQuery: filterText)
                            self.showFilteredItemView(filteredItemViewModel: filteredItemViewModel)
                        }
                        break
                    case SliderType.webUrl.rawValue:
                        break
                    default:
                        break
                    }
                }
            }
        } else if collectionView == self.brandFilterCollectionView{
            if let brandFilters = viewModel.mainSlider.brandFilters{
                let brandFilter = brandFilters[indexPath.item]
                if let actionType = brandFilter.actionType{
                    switch actionType{
                    case SliderType.filter.rawValue:
                        if let filterText = brandFilter.filterContent{
                            let filteredItemViewModel = FilteredItemViewModel.init(algoliaService: AlgoliaSearchService(), firebaseService: FirebaseService(), filterType: ItemFilterType.lightSearch, filterQuery: filterText)
                            self.showFilteredItemView(filteredItemViewModel: filteredItemViewModel)
                        }
                        break
                    case SliderType.webUrl.rawValue:
                        break
                    default:
                        break
                    }
                }
            }
        }
    }
}

extension BuyViewController: FSPagerViewDataSource, FSPagerViewDelegate{
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        if let count = viewModel.mainSlider.sliders?.count{
            return count
        }
        return 0
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "pagerCell", at: index)
        if let sliders = viewModel.mainSlider.sliders{
            let slider = sliders[index]
            if let url = URL(string: slider.imageUrl ?? ""){
                cell.imageView?.kf.setImage(with: url)
            }
            
            cell.imageView?.contentMode = .scaleAspectFill
            cell.imageView?.clipsToBounds = true
        }
        return cell
    }
    
    // MARK:- FSPagerView Delegate
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        self.pageControl.currentPage = index

        if let sliders = viewModel.mainSlider.sliders{
            let slider = sliders[index]
            if let actionType = slider.actionType{
                switch actionType{
                case SliderType.webUrl.rawValue:
                    let storyboard = UIStoryboard(name: "WebViewScreen", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"WebViewViewControllerId") as! WebViewViewController
                    viewController.webUrl = slider.filterContent
                    navigationController?.pushViewController(viewController, animated: true)
                    break
                case SliderType.filter.rawValue:
                    if let filterText = slider.filterContent{
                        let filteredItemViewModel = FilteredItemViewModel.init(algoliaService: AlgoliaSearchService(), firebaseService: FirebaseService(), filterType: ItemFilterType.lightSearch, filterQuery: filterText)
                        self.showFilteredItemView(filteredItemViewModel: filteredItemViewModel)
                    }
                    break
                case SliderType.retailSale.rawValue:
                    showRetailSaleView()
                    break
                case SliderType.giveAway.rawValue:
                    showGiveAwaySaleView()
                default:
                    break
                }
            }
        
        }
        
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        guard self.pageControl.currentPage != pagerView.currentIndex else {
            return
        }
        self.pageControl.currentPage = pagerView.currentIndex
    }
}

extension BuyViewController: UITabBarControllerDelegate {
    
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        let selectIndex = tabBarController.selectedIndex
//        switch selectIndex {
//        case 0:
//            break
//        case 1:
//            if !UserManager.shared.isLoggedIn{
//                showLoginView()
//            }
//        case 2:
//            if !UserManager.shared.isLoggedIn{
//                showLoginView()
//            }
//        case 3:
//            if !UserManager.shared.isLoggedIn{
//                showLoginView()
//            }
//        default:
//            break
//        }
//    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let selectIndex = tabBarController.selectedIndex
        let willSelectIndex = tabBarController.viewControllers?.index(of: viewController)
        logger.debug("The willSelectIndex is \(String(describing: willSelectIndex))")
        switch selectIndex {
        case 0:
            if !UserManager.shared.isLoggedIn{
                if let index = willSelectIndex{
                    showLoginView(willSelectIndex: index)
                }
                return false
            }
        case 1:
            return true
        case 2:
            return true
        case 3:
            return true
        default:
            break
        }
        
        return true
    }

}

extension BuyViewController: SwitchTabProtocol{
    func switchTab(selectIndex: Int) {
        tabBarController?.selectedIndex = selectIndex
    }
}

