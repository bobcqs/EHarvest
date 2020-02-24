//
//  FilterViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 31/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AlgoliaSearch

class FilterViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var subCategoryTableView: UITableView!
    @IBOutlet weak var applyButton: UIButton!
    
    
    var viewModel: FilterViewModeling!
    var currentSelectedIndex = 0
    var currentCategoryIndex = 0
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

//        let client = Client(appID: "54SJYLVR4Q", apiKey: "3de5f649dc1c4279d247f99c960ffaf9")
//        let index = client.index(withName: "items")
//
//        var query = Query.init()
//       // query.filters = "price > 10 AND (brand: 'Jordan Brand' OR brand: 'Nike')"
//        query.filters = "(price:0 TO 1000)"
//        index.search(query, completionHandler: { (content, error) -> Void in
//            if error == nil {
//                if let result = content{
//                    if let hits = result["hits"]{
//                        print (hits)
//                        for e in (hits as! [[String: Any]]){
//                            print (e)
//                        }
////                        let res1 = (hits as! [[String: Any]])[0]
////                        print (res1)
//                    }
//                }
//            } else {
//                print (error)
//            }
//        })
        
        setupBinding()
    }
    
    func setupBinding(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceHorizontal = true
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        subCategoryTableView.delegate = self
        subCategoryTableView.dataSource = self
        
        viewModel.currentFilterDidUpdate
            .subscribe(onNext: { [weak self] _ in
                self?.reloadAllViews()
            })
            .disposed(by: disposeBag)
        
        applyButton.rx.tap
            .map({ [weak self] _ in
                self?.currentSelectedIndex ?? 0
            })
            .bind(to: viewModel.applyButtonDidTap)
            .disposed(by: disposeBag)
        
        viewModel.showFilteredItemView
            .subscribe(onNext: { [weak self] (filteredItemViewModel) in
                self?.showFilteredItemView(filteredItemViewModel: filteredItemViewModel)
            })
            .disposed(by: disposeBag)
        
        let rightButton = UIBarButtonItem(title: "CLEAR ALL", style: .plain, target: self, action: #selector(self.clearAll))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func clearAll(){
        viewModel.currentFilter.clearAllFilter()
        reloadAllViews()
    }
    
    func showFilteredItemView(filteredItemViewModel: FilteredItemViewModeling){
        let storyboard = UIStoryboard(name: "FilteredItemScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"filteredItemViewControllerId") as! FilteredItemViewController
        viewController.viewModel = filteredItemViewModel
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func reloadAllViews(){
        self.collectionView.reloadData()
        self.categoryTableView.reloadData()
        self.subCategoryTableView.reloadData()
    }

}

extension FilterViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var nbCol = 3
        if let count = viewModel.currentFilter.mainCategories?.count{
            nbCol = count
        }
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(nbCol - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(nbCol))
        return CGSize(width: size, height: 50)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = viewModel.currentFilter.mainCategories?.count{
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterMainCategoryCell",
                                                      for: indexPath) as! FilterMainCategoryCell
        
        if let mainCategories = viewModel.currentFilter.mainCategories{
            let mainCategory = mainCategories[indexPath.row]
            var isCurrent = false
            if indexPath.row == currentSelectedIndex{
                isCurrent = true
            }
            cell.configureCell(mainCategory: mainCategory, isCurrent: isCurrent)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentSelectedIndex = indexPath.row
        currentCategoryIndex = 0
        reloadAllViews()
    }
    
}

extension FilterViewController: PriceSubCategoryDelegate{
    func priceUpdate(cell: PriceSubCategoryCell, low: Int, high: Int, isValid: Bool) {
        if let indexPath = subCategoryTableView.indexPath(for: cell){
            let priceSubCategory = viewModel.currentFilter.mainCategories?[currentSelectedIndex].categories?[currentCategoryIndex].subCategories?[indexPath.row]
            if isValid{
                priceSubCategory?.isSelected = true
                priceSubCategory?.lowerRangeValue = low
                priceSubCategory?.higherRangeValue = high
            }else {
                priceSubCategory?.isSelected = false
            }
            subCategoryTableView.reloadData()
        }
    }
}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let mainCategory = viewModel.currentFilter.mainCategories?[currentSelectedIndex]{
            if let categories = mainCategory.categories{
                if tableView == categoryTableView{
                    return categories.count
                }
                let category = categories[currentCategoryIndex]
                if let subCategories = category.subCategories{
                    if tableView == subCategoryTableView{
                        return subCategories.count
                    }
                }
            }
        }
        if tableView == categoryTableView{
            
        } else if tableView == subCategoryTableView{
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == categoryTableView{
            let cell = categoryTableView.dequeueReusableCell(withIdentifier: "filterCategoryCell",
                                                          for: indexPath) as! FilterCategoryCell
            if let mainCategory = viewModel.currentFilter.mainCategories?[currentSelectedIndex]{
                if let categories = mainCategory.categories{
                    let category = categories[indexPath.row]
                    var isCurrent = false
                    if indexPath.row == currentCategoryIndex{
                        isCurrent = true
                    }
                    cell.configureCell(category: category, isCurrent: isCurrent)
                }
            }
            return cell
        } else if tableView == subCategoryTableView{
            if let mainCategory = viewModel.currentFilter.mainCategories?[currentSelectedIndex]{
                if let categories = mainCategory.categories{
                    let category = categories[currentCategoryIndex]
                    if let subCategories = category.subCategories{
                        let subCategory = subCategories[indexPath.row]
                        if let isRangeFilter = subCategory.isRangeFilter, isRangeFilter == true {
                            let cell = subCategoryTableView.dequeueReusableCell(withIdentifier: "priceSubCategoryCell",
                                                                             for: indexPath) as! PriceSubCategoryCell
                            cell.delegate = self
                            cell.configureCell(subCategory: subCategory)
                            return cell
                        } else {
                            let cell = subCategoryTableView.dequeueReusableCell(withIdentifier: "filterSubCategoryCell",
                                                                             for: indexPath) as! FilterSubCategoryCell
                            cell.configureCell(subCategory: subCategory)
                            return cell
                        }
                    }
                }
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == categoryTableView{
            currentCategoryIndex = indexPath.row
            reloadAllViews()
        } else if tableView == subCategoryTableView{
            if let mainCategory = viewModel.currentFilter.mainCategories?[currentSelectedIndex]{
                if let categories = mainCategory.categories{
                    let category = categories[currentCategoryIndex]
                    if let subCategories = category.subCategories{
                        let subCategory = subCategories[indexPath.row]
                        if let isRangeFilter = subCategory.isRangeFilter, isRangeFilter == true{
                            
                        } else {
                            if let isSelected = subCategory.isSelected, isSelected == true{
                                subCategory.isSelected = false
                            } else {
                                subCategory.isSelected = true
                            }
                            subCategoryTableView.reloadData()
                        }

                        //viewModel.currentFilter.mainCategories?[currentSelectedIndex].categories?[currentCategoryIndex].subCategories?[indexPath.row] = subCategory
                        
                    }
                }
            }
        }
    }
}
