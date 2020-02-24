//
//  SearchItemViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 26/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import AlgoliaSearch
import RxCocoa
import RxSwift


class SearchItemViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    
    var viewModel: SearchItemViewModeling!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

//        // Do any additional setup after loading the view.
//        let client = Client(appID: "54SJYLVR4Q", apiKey: "3de5f649dc1c4279d247f99c960ffaf9")
//        let index = client.index(withName: "items")
//
//        index.search(Query(query: "定律"), completionHandler: { (content, error) -> Void in
//            if error == nil {
//                if let result = content{
//                    if let hits = result["hits"]{
//                        let res1 = (hits as! [[String: Any]])[0]
//                        print (res1)
//                    }
//                }
//            }
//        })
//        let ss = AlgoliaSearchService()
//        ss.lightSearch(searchText: "定律")
//            .subscribe(onNext: { (items) in
//                for e in items{
//                    print (e)
//                }
//            })
        setupBinding()
        searchTextField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchTextField.addBorder(toSide: .Bottom, withColor: UIColor.black.cgColor, andThickness: 0.3)
    }

    func setupBinding(){
        searchTextField.rx.text.orEmpty
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        searchTextField.rx.controlEvent([.editingDidEnd])
            .asObservable()
            .withLatestFrom(viewModel.searchText){ aa, text in
                return (text)
            }
            .subscribe(onNext: { [weak self] text in
                if !text.isEmpty{
                    var originalList = UserManager.shared.currentUserSearchHistory
                    originalList.insert(text, at: 0)
                    originalList.remove(at: originalList.count - 1)
                    UserManager.shared.currentUserSearchHistory = originalList
                    self?.viewModel.beginSearch.onNext(())
                }
            })
            .disposed(by: disposeBag)
        
        tableview.rx.setDelegate(self).disposed(by: disposeBag)
        viewModel.searchTextList    
            .asObservable()
            .bind(to: tableview.rx.items(cellIdentifier: "searchItemTableViewCell", cellType: SearchItemTableViewCell.self)) { row, element, cell in
                cell.configureCell(text: element)
            }.disposed(by: disposeBag)
        
        viewModel.showFilteredItemView
            .subscribe(onNext: { [weak self] (filteredItemViewModel) in
                self?.showFilteredItemView(filteredItemViewModel: filteredItemViewModel)
            })
            .disposed(by: disposeBag)
        
        tableview.rx.modelSelected(String.self)
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.searchText.onNext(text)
                self?.viewModel.beginSearch.onNext(())
            }).disposed(by: disposeBag)
        
    }
    
    func showFilteredItemView(filteredItemViewModel: FilteredItemViewModeling){
        let storyboard = UIStoryboard(name: "FilteredItemScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"filteredItemViewControllerId") as! FilteredItemViewController
        viewController.viewModel = filteredItemViewModel
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SearchItemViewController: UITableViewDelegate{
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 40
//    }
}
