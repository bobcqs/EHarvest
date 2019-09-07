//
//  EditItemViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 20/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Spring
import TLPhotoPicker

class EditItemViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var categoryTextField: InputTextFieldView!
    @IBOutlet weak var brandTextField: InputTextFieldView!
    @IBOutlet weak var itemTextField: InputTextFieldView!
    @IBOutlet weak var sizeTextField: InputTextFieldView!
    @IBOutlet weak var conditionTextField: InputTextFieldView!
    @IBOutlet weak var descriptionTextView: SellDescriptionBorder!
    @IBOutlet weak var priceTextField: InputTextFieldView!
    @IBOutlet weak var emailTextField: InputTextFieldView!
    @IBOutlet weak var australiaShippingView: SellShippingBorder!
    @IBOutlet weak var shippingTickImage: UIImageView!
    @IBOutlet weak var editListingButton: UIButton!
    @IBOutlet weak var deleteListingButton: UIButton!
    
    @IBOutlet weak var categoryValidationLabel: UILabel!
    @IBOutlet weak var categoryValidationLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var brandValidationLabel: UILabel!
    @IBOutlet weak var brandValidationLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemNameValidationLabel: UILabel!
    @IBOutlet weak var itemNameValidationLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sizeValidationLabel: UILabel!
    @IBOutlet weak var sizeValidationLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var conditionValidationLabel: UILabel!
    @IBOutlet weak var conditionValidationLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var priceValidationLabel: UILabel!
    @IBOutlet weak var priceValidationLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailValidationLabel: UILabel!
    @IBOutlet weak var emailValidationLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var priceDetailView: SpringView!
    @IBOutlet weak var shippingFeeTitle: UILabel!
    @IBOutlet weak var shippingFeeLabel: UILabel!
    @IBOutlet weak var transactionFeeTitle: UILabel!
    @IBOutlet weak var transactionFeeLabel: UILabel!
    @IBOutlet weak var paymentProcessFeeTitle: UILabel!
    @IBOutlet weak var paymentProcessFeeLabel: UILabel!
    @IBOutlet weak var totalFeeTitle: UILabel!
    @IBOutlet weak var totalFeeLabel: UILabel!
    @IBOutlet weak var priceDetailViewHeightConstraint: NSLayoutConstraint!
    
    //picker views
    let categoryPickerView = UIPickerView()
    var categorySelectedRow = 0
    let brandPickerView = UIPickerView()
    let sizePickerView = UIPickerView()
    let conditionPickerView = UIPickerView()
    
    var toolBar: UIToolbar = UIToolbar(){
        didSet{
            toolBar.barStyle = .default
            toolBar.isTranslucent = true
            toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
            toolBar.sizeToFit()
            
            // Adding Button ToolBar
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
            toolBar.setItems([spaceButton, spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
        }
    }
    
    var viewModel: EditItemViewModeling!
    var imagePicker: UIImagePickerController!
    var itemImage: UIImage!
    var isFromOtherView = false
    
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
        setupKeyboard()
        setupUI()
        setupBinding()
        initDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PayPalManager.shared.getCommissionRate()
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            logger.info("reordered image item index is \(selectedIndexPath.row)")
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if indexPath.row == viewModel.images.count - 1 {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        let count = viewModel.images.count
        let isPhotoNumberMaxed = viewModel.isPhotoNumberMaxed
        if (!isPhotoNumberMaxed) && (row == count - 1){
            logger.info("can add photo")
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                
            }
            actionSheet.addAction(cancelAction)
            let cameraOption = UIAlertAction(title: "Take A Photo", style: .default) { action in
                if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
                    self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                    self.present(self.imagePicker, animated: true, completion:nil)
                }
            }
            actionSheet.addAction(cameraOption)
            let photoAlbumOption = UIAlertAction(title: "From Camera Roll", style: .default) { action in
                //self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                //self.present(self.imagePicker, animated: true, completion:nil)
                self.pickerWithCustomCameraCell()
            }
            actionSheet.addAction(photoAlbumOption)
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func pickerWithCustomCameraCell() {
        let viewController = CustomPhotoPickerViewController()
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            self?.showExceededMaximumAlert(vc: picker)
        }
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.allowedVideo = false
        configure.maxSelectedAssets = 8
        configure.selectedColor = ColorDesign.flatRed.withAlphaComponent(0.8)
        if #available(iOS 10.2, *) {
            configure.cameraCellNibSet = (nibName: "CustomCameraCell", bundle: Bundle.main)
        }
        viewController.configure = configure
        //  viewController.selectedAssets = self.selectedAssets
        self.present(viewController.wrapNavigationControllerWithoutBar(), animated: true, completion: nil)
    }
    
    func showExceededMaximumAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "", message: "Exceed Maximum Number Of Selection", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    
    func initDelegate(){
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        viewModel.delegate = self
        
        //pickerview delegate and datasource
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        brandPickerView.delegate = self
        brandPickerView.dataSource = self
        sizePickerView.delegate = self
        sizePickerView.dataSource = self
        conditionPickerView.delegate = self
        conditionPickerView.dataSource = self
        
    }
    
    func setupUI(){
        categoryTextField.text = viewModel.item.category
        brandTextField.text = viewModel.item.brand
        itemTextField.text = viewModel.item.name
        sizeTextField.text = viewModel.item.size
        conditionTextField.text = viewModel.item.condition
        priceTextField.text = String(viewModel.item.price ?? 0)
        emailTextField.text = viewModel.item.email
        descriptionTextView.text = viewModel.item.itemDescription
    }
    
    func setupBinding(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        toolBar = UIToolbar()
        categoryTextField.delegate = self
        categoryTextField.inputAccessoryView = toolBar
        categoryTextField.inputView = categoryPickerView
        brandTextField.delegate = self
        brandTextField.inputAccessoryView = toolBar
        brandTextField.inputView = brandPickerView
        itemTextField.delegate = self
        sizeTextField.delegate = self
        sizeTextField.inputAccessoryView = toolBar
        //sizeTextField.inputView = sizePickerView
        conditionTextField.delegate = self
        conditionTextField.inputAccessoryView = toolBar
        conditionTextField.inputView = conditionPickerView
        descriptionTextView.delegate = self
        descriptionTextView.inputAccessoryView = toolBar
        priceTextField.delegate = self
        priceTextField.inputAccessoryView = toolBar
        priceTextField.keyboardType = .numberPad
        emailTextField.delegate = self
        emailTextField.inputAccessoryView = toolBar
        
        categoryValidationLabel.isHidden = true
        categoryValidationLabelHeightConstraint.constant = 0
        brandValidationLabel.isHidden = true
        brandValidationLabelHeightConstraint.constant = 0
        itemNameValidationLabel.isHidden = true
        itemNameValidationLabelHeightConstraint.constant = 0
        sizeValidationLabel.isHidden = true
        sizeValidationLabelHeightConstraint.constant = 0
        conditionValidationLabel.isHidden = true
        conditionValidationLabelHeightConstraint.constant = 0
        descriptionLabel.isHidden = true
        descriptionLabelHeightConstraint.constant = 0
        priceValidationLabel.isHidden = true
        priceValidationLabelHeightConstraint.constant = 0
        emailValidationLabel.isHidden = true
        emailValidationLabelHeightConstraint.constant = 0
        priceDetailView.isHidden = true
        priceDetailViewHeightConstraint.constant = 0
        
        //default colour
        categoryTextField.textColor = ColorDesign.blackTextColor
        brandTextField.textColor = ColorDesign.blackTextColor
        itemTextField.textColor = ColorDesign.blackTextColor
        sizeTextField.textColor = ColorDesign.blackTextColor
        conditionTextField.textColor = ColorDesign.blackTextColor
        priceTextField.textColor = ColorDesign.blackTextColor
        emailTextField.textColor = ColorDesign.blackTextColor
        descriptionTextView.textColor = ColorDesign.blackTextColor
        
        let shipppingTap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(toggleShipping))
        
        australiaShippingView.addGestureRecognizer(shipppingTap)
        
        categoryTextField.rx.text.orEmpty
            .bind(to: viewModel.selectedCategory)
            .disposed(by: disposeBag)
        
        brandTextField.rx.text.orEmpty
            .bind(to: viewModel.selectedBrand)
            .disposed(by: disposeBag)
        
        itemTextField.rx.text.orEmpty
            .bind(to: viewModel.itemName)
            .disposed(by: disposeBag)
        
        sizeTextField.rx.text.orEmpty
            .bind(to: viewModel.selectedSize)
            .disposed(by: disposeBag)
        
        conditionTextField.rx.text.orEmpty
            .bind(to: viewModel.selectedCondition)
            .disposed(by: disposeBag)
        
        descriptionTextView.rx.text.orEmpty
            .bind(to: viewModel.itemDescription)
            .disposed(by: disposeBag)
        
        priceTextField.rx.text.orEmpty
            .map({ (priceString) -> Int in
                if let price = Int(priceString){
                    return price
                }
                return 0
            })
            .bind(to: viewModel.itemPrice)
            .disposed(by: disposeBag)
        
        emailTextField.rx.text.orEmpty
            .bind(to: viewModel.payPalEmail)
            .disposed(by: disposeBag)
        
        viewModel.shippingEnabled
            .map { (enable) -> Bool in
                return !enable
            }
            .bind(to: shippingTickImage.rx.isHidden)
            .disposed(by: disposeBag)
        
//        editListingButton.rx.tap
//            .do(onNext: {
//                LoadingManager.shared.showIndicator()
//            })
//            .bind(to: viewModel.editDidTap)
//            .disposed(by: disposeBag)
        
        editListingButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                if let result = self?.validateAllFields(), result == true{
                    if let count = self?.viewModel.images.count, count > 1 {
                        LoadingManager.shared.showIndicator()
                        self?.viewModel.editDidTap.onNext(())
                    } else {
                        AlertManager.shared.showAlert(message: "Please add some images for your item", timeInterval: 1, viewController: self!)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        deleteListingButton.rx.tap
            .do(onNext: {
                LoadingManager.shared.showIndicator()
            })
            .bind(to: viewModel.deleteDidTap)
            .disposed(by: disposeBag)
        
        viewModel.submissionResult.subscribe(onNext: { [weak self] result in
            switch result {
            case .submissionSuccess:
                LoadingManager.shared.hideIndicatorWithMessage(message: "Item updated successfully", timeInterval: 2)
                if let isFromOtherView = self?.isFromOtherView, isFromOtherView == true {
                    self?.tabBarController?.selectedIndex = 3
                    NotificationCenter.default.post(name: .showMyListing, object: nil, userInfo: nil)
                    self?.navigationController?.popToRootViewController(animated: true)
                    NotificationCenter.default.post(name: .refreshBuyScreen, object: nil, userInfo: nil)
                } else {
                    self?.navigationController?.popViewController(animated: true)
                }
                break
            case .submissionFail:
                LoadingManager.shared.hideIndicatorWithMessage(message: "Please try again later", timeInterval: 2)
                break
            default:
                LoadingManager.shared.hideIndicator()
                break
            }
        })
        .disposed(by: disposeBag)
    }
    
    func validateAllFields()-> Bool{
        if let text = categoryTextField.text, text.isEmpty{
            self.categoryTextField.becomeFirstResponder()
            self.categoryTextField.text = ""
            self.categoryTextField.endEditing(true)
            return false
        } else if let text = brandTextField.text, text.isEmpty{
            self.brandTextField.becomeFirstResponder()
            self.brandTextField.text = ""
            self.brandTextField.endEditing(true)
            return true
        } else if let text = itemTextField.text, text.isEmpty{
            self.itemTextField.becomeFirstResponder()
            self.itemTextField.text = ""
            self.itemTextField.endEditing(true)
            return false
        } else if let text = sizeTextField.text, text.isEmpty{
            self.sizeTextField.becomeFirstResponder()
            self.sizeTextField.text = ""
            self.sizeTextField.endEditing(true)
            return true
        } else if let text = conditionTextField.text, text.isEmpty{
            self.conditionTextField.becomeFirstResponder()
            self.conditionTextField.text = ""
            self.conditionTextField.endEditing(true)
            return false
        } else if let text = descriptionTextView.text, text.isEmpty{
            self.descriptionTextView.becomeFirstResponder()
            self.descriptionTextView.text = ""
            self.descriptionTextView.endEditing(true)
            return false
        } else if let text = priceTextField.text, text.isEmpty{
            self.priceTextField.becomeFirstResponder()
            self.priceTextField.text = ""
            self.priceTextField.endEditing(true)
            return false
        } else if let text = emailTextField.text, text.isEmpty{
            self.emailTextField.becomeFirstResponder()
            self.emailTextField.text = ""
            self.emailTextField.endEditing(true)
            return false
        }
        return true
    }
    
    @objc func doneClick(){
        view.endEditing(true)
    }
    
    @objc func toggleShipping(){
        viewModel.shippingEnabled.onNext(shippingTickImage.isHidden)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    func refreshCollectionView(){
        collectionView.reloadData()
        if viewModel.images.count > 4 {
            collectionViewHeightConstraint.constant = CGFloat(200)
        } else {
            collectionViewHeightConstraint.constant = CGFloat(90)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let nbCol = 4
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(nbCol - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(nbCol))
        return CGSize(width: size, height: 90)
        
    }
    
    func priceDetailViewAnimateFrom(){
        UIView.animate(withDuration: 0.7, delay: 0.0, options: [], animations: {
            self.priceDetailViewHeightConstraint.constant = 110
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func priceDetailViewAnimateTo(){
        self.priceDetailViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.7, delay: 0.0, options: [], animations: {
            self.priceDetailViewHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func displayPriceDetail(totalPrice: Double){
        //price calculation
        var totalPrice = totalPrice
        let commissionRate = PayPalManager.shared.commissionRate
        let payPalProcessRate = PayPalManager.shared.payPalRate
        totalPrice += 5
        let sellerShouldReceiveAmount = totalPrice * ((100 - commissionRate) / 100)
        let shouldSendToSellerAmount = (sellerShouldReceiveAmount + 0.3) / ((100 - payPalProcessRate) / 100) //2.6 % is Paypal Fee
        var sellerAmount = (shouldSendToSellerAmount * 100).rounded() / 100
        var comissionAmount = totalPrice - sellerAmount
        if comissionAmount < 1 {
            comissionAmount = 1
            sellerAmount = totalPrice - comissionAmount
        }
        
        let processAmount = sellerAmount - sellerShouldReceiveAmount
        let formatString = "%.2f"
        let formattedSellerShouldReceiveAmount = String(format: formatString, sellerShouldReceiveAmount)
        let formattedComissionAmount = String(format: formatString, comissionAmount)
        let formattedProcessAmount = String(format: formatString, processAmount)
        let shippingTitle = "Shipping Fee from buyer"
        let shippingFee = "+$5"
        //let transactionTitle = "Transaction Fee" + "(" + String(commissionRate) + "%)"
        let transactionTitle = "Transaction Fee"
        let transactionFee = "-$" + formattedComissionAmount
        let processFeeTitle = "Payment Proc." + "(" + String(payPalProcessRate) + "%)"
        let processFee = "-$" + formattedProcessAmount
        let totalPayTitle = "Total Payout (AUD)"
        let totalPayFee = "$" + formattedSellerShouldReceiveAmount
        
        shippingFeeTitle.text = shippingTitle
        shippingFeeLabel.text = shippingFee
        transactionFeeTitle.text = transactionTitle
        transactionFeeLabel.text = transactionFee
        paymentProcessFeeTitle.text = processFeeTitle
        paymentProcessFeeLabel.text = processFee
        totalFeeTitle.text = totalPayTitle
        totalFeeLabel.text = totalPayFee
    }

}

extension EditItemViewController: UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField{
        case categoryTextField:
            if let text = categoryTextField.text{
                if text.isEmpty{
                    categoryTextField.text = viewModel.categoryData[0][0]
                }
            }
        case brandTextField:
            brandTextField.text = viewModel.brand[0]
        case sizeTextField:
            sizeTextField.text = viewModel.size[0]
        case conditionTextField:
            conditionTextField.text = viewModel.conditions[0]
        default:
            break
        }
        textField.textColor = ColorDesign.blackTextColor
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField{
        case categoryTextField:
            if let text = categoryTextField.text, let sizeText = sizeTextField.text{
                if !text.isEmpty && !sizeText.isEmpty {
                    sizeTextField.text = viewModel.size[0]
                }
            }
            let validation = InputValidationService.shared.isValid(input: textField.text ?? "", type: .category)
            if validation.result{
                categoryValidationLabel.isHidden = true
                categoryValidationLabelHeightConstraint.constant = 0
                categoryTextField.layer.borderColor = UIColor.lightGray.cgColor
            } else {
                categoryValidationLabel.isHidden = false
                categoryValidationLabel.text = validation.message
                categoryValidationLabelHeightConstraint.constant = 19.5
                categoryTextField.layer.borderColor = ColorDesign.flatRed.cgColor
            }
        case brandTextField:
            let validation = InputValidationService.shared.isValid(input: textField.text ?? "", type: .brand)
            if validation.result{
                brandValidationLabel.isHidden = true
                brandValidationLabelHeightConstraint.constant = 0
                brandTextField.layer.borderColor = UIColor.lightGray.cgColor
            } else {
                brandValidationLabel.isHidden = false
                brandValidationLabel.text = validation.message
                brandValidationLabelHeightConstraint.constant = 19.5
                brandTextField.layer.borderColor = ColorDesign.flatRed.cgColor
            }
        case sizeTextField:
            let validation = InputValidationService.shared.isValid(input: textField.text ?? "", type: .size)
            if validation.result{
                sizeValidationLabel.isHidden = true
                sizeValidationLabelHeightConstraint.constant = 0
                sizeTextField.layer.borderColor = UIColor.lightGray.cgColor
            } else {
                sizeValidationLabel.isHidden = false
                sizeValidationLabel.text = validation.message
                sizeValidationLabelHeightConstraint.constant = 19.5
                sizeTextField.layer.borderColor = ColorDesign.flatRed.cgColor
            }
        case itemTextField:
            let validation = InputValidationService.shared.isValid(input: textField.text ?? "", type: .itemName)
            if validation.result{
                itemNameValidationLabel.isHidden = true
                itemNameValidationLabelHeightConstraint.constant = 0
                itemTextField.layer.borderColor = UIColor.lightGray.cgColor
            } else {
                itemNameValidationLabel.isHidden = false
                itemNameValidationLabel.text = validation.message
                itemNameValidationLabelHeightConstraint.constant = 19.5
                itemTextField.layer.borderColor = ColorDesign.flatRed.cgColor
            }
        case conditionTextField:
            let validation = InputValidationService.shared.isValid(input: textField.text ?? "", type: .condition)
            if validation.result{
                conditionValidationLabel.isHidden = true
                conditionValidationLabelHeightConstraint.constant = 0
                conditionTextField.layer.borderColor = UIColor.lightGray.cgColor
            } else {
                conditionValidationLabel.isHidden = false
                conditionValidationLabel.text = validation.message
                conditionValidationLabelHeightConstraint.constant = 19.5
                conditionTextField.layer.borderColor = ColorDesign.flatRed.cgColor
            }
        case priceTextField:
            let validation = InputValidationService.shared.isValid(input: textField.text ?? "", type: .price)
            if validation.result{
                priceValidationLabel.isHidden = true
                priceValidationLabelHeightConstraint.constant = 0
                priceTextField.layer.borderColor = UIColor.lightGray.cgColor
                priceDetailView.isHidden = false
                priceDetailViewAnimateFrom()
                if let price = Double(priceTextField.text ?? "0"){
                    displayPriceDetail(totalPrice: price)
                }
            } else {
                priceValidationLabel.isHidden = false
                priceValidationLabel.text = validation.message
                priceValidationLabelHeightConstraint.constant = 19.5
                priceTextField.layer.borderColor = ColorDesign.flatRed.cgColor
                priceDetailViewAnimateTo()
            }
        case emailTextField:
            let validation = InputValidationService.shared.isValid(input: textField.text ?? "", type: .email)
            if validation.result{
                emailValidationLabel.isHidden = true
                emailValidationLabelHeightConstraint.constant = 0
                emailTextField.layer.borderColor = UIColor.lightGray.cgColor
            } else {
                emailValidationLabel.isHidden = false
                emailValidationLabel.text = validation.message
                emailValidationLabelHeightConstraint.constant = 19.5
                emailTextField.layer.borderColor = ColorDesign.flatRed.cgColor
            }
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField{
        case priceTextField:
            let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
            return string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil
        default:
            return true
        }
    }
}

extension EditItemViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Description" {
            textView.text = nil
            textView.textColor = ColorDesign.blackTextColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let validation = InputValidationService.shared.isValid(input: textView.text ?? "", type: .itemDescription)
        if validation.result{
            descriptionLabel.isHidden = true
            descriptionLabelHeightConstraint.constant = 0
            textView.layer.borderColor = UIColor.lightGray.cgColor
        } else {
            descriptionLabel.isHidden = false
            descriptionLabel.text = validation.message
            descriptionLabelHeightConstraint.constant = 19.5
            textView.layer.borderColor = ColorDesign.flatRed.cgColor
        }
    }
}

extension EditItemViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView{
        case categoryPickerView:
            return 2
        case brandPickerView:
            return 1
        case sizePickerView:
            return 1
        case conditionPickerView:
            return 1
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView{
        case categoryPickerView:
            if component == 0 {
                return viewModel.category.count
            } else {
                let selected = categoryPickerView.selectedRow(inComponent: 0)
                logger.debug("The selected number is \(selected)")
                logger.debug("Category item count is \(viewModel.categoryData[selected].count)")
                return viewModel.categoryData[categorySelectedRow].count
            }
        case brandPickerView:
            return viewModel.brand.count
        case sizePickerView:
            return viewModel.size.count
        case conditionPickerView:
            return viewModel.conditions.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView{
        case categoryPickerView:
            if component == 0 {
                return viewModel.category[row]
            } else {
                let selected = categoryPickerView.selectedRow(inComponent: 0)
                return viewModel.categoryData[selected][row]
            }
        case brandPickerView:
            return viewModel.brand[row]
        case sizePickerView:
            return viewModel.size[row]
        case conditionPickerView:
            return viewModel.conditions[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView{
        case categoryPickerView:
            let selected = categoryPickerView.selectedRow(inComponent: 0)
            if component == 0 {
                categoryTextField.text = viewModel.categoryData[selected][0]
                categorySelectedRow = categoryPickerView.selectedRow(inComponent: component)
                pickerView.reloadComponent(1)
                categoryPickerView.selectRow(0, inComponent: 1, animated: true)
            } else {
                categoryTextField.text = viewModel.categoryData[selected][row]
            }
        case brandPickerView:
            brandTextField.text = viewModel.brand[row]
        case sizePickerView:
            sizeTextField.text = viewModel.size[row]
        case conditionPickerView:
            conditionTextField.text = viewModel.conditions[row]
        default:
            break
        }
    }
    
    
}

extension EditItemViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sellCell", for: indexPath) as! SellCollectionViewCell
        let image = viewModel.images[indexPath.row]
        cell.itemImage.image = image
        
        if indexPath.row == viewModel.images.count - 1 && (!viewModel.isPhotoNumberMaxed){
            cell.closeButton.isHidden = true
        } else {
            cell.closeButton.isHidden = false
        }
        
        cell.closeButton.rx.tap.subscribe{ [unowned self] item in
            print (indexPath)
            self.viewModel.deleteImage(index: indexPath.row)
            }.disposed(by: cell.disposeBag)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if destinationIndexPath.row != viewModel.images.count - 1 {
            let temp = viewModel.images.remove(at: sourceIndexPath.item)
            viewModel.images.insert(temp, at: destinationIndexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        //To prevent the add photo item be replaced
        if proposedIndexPath.row == viewModel.images.count - 1 && (!viewModel.isPhotoNumberMaxed){
            return originalIndexPath
        }
        return proposedIndexPath
    }
}

extension EditItemViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            sendImage(image: image)
        } else{
            print ("Log: A valid image isn't selected")
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            sendImage(image: image)
        }
        imagePicker.dismiss(animated:true, completion: nil)
    }
    
    func sendImage(image: UIImage){
        viewModel.addImage(image: image)
    }
    
}

extension EditItemViewController: SellViewImageDelegate {
    func addImageFinished() {
        refreshCollectionView()
    }
    
    func deleteImageFinished() {
        refreshCollectionView()
    }
    
    func refreshAllData() {
        
    }
}

extension EditItemViewController: TLPhotosPickerViewControllerDelegate{
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        for asset in withTLPHAssets{
            if let image = asset.fullResolutionImage{
                sendImage(image: image)
            }
        }
    }
}

