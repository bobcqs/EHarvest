//
//  PriceSubCategoryCell.swift
//  Bredway
//
//  Created by Xudong Chen on 3/8/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

protocol PriceSubCategoryDelegate: class {
    func priceUpdate(cell:PriceSubCategoryCell, low: Int, high: Int, isValid: Bool)
}

class PriceSubCategoryCell: UITableViewCell {
    
    @IBOutlet weak var minTextField: UITextField!
    @IBOutlet weak var maxTextField: UITextField!
    @IBOutlet weak var redTickView: UIImageView!
    
    
    weak var delegate: PriceSubCategoryDelegate?
    
    var lowerValue: String?
    var higherValue: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let doneBar = UIToolbar()
        doneBar.barStyle = .default
        doneBar.isTranslucent = true
        doneBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        doneBar.sizeToFit()
        
        // Adding Button ToolBar
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        doneBar.setItems([spaceButton, spaceButton, doneButton], animated: false)
        doneBar.isUserInteractionEnabled = true
        minTextField.delegate = self
        minTextField.inputAccessoryView = doneBar
        minTextField.keyboardType = .numberPad
        maxTextField.delegate = self
        maxTextField.inputAccessoryView = doneBar
        maxTextField.keyboardType = .numberPad
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(subCategory: FilterSubCategory){
        if let isSelected = subCategory.isSelected, isSelected == true{
            redTickView.isHidden = false
        } else {
            redTickView.isHidden = true
        }
    }

    @objc func doneClick(){
        endEditing(true)
    }
    
}

extension PriceSubCategoryCell: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField{
        case minTextField:
            let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
            return string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil
        case maxTextField:
            let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
            return string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil
        default:
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == minTextField{
            lowerValue = textField.text
        } else if textField == maxTextField{
            higherValue = textField.text
        }
        if let lowVal = lowerValue, let highVal = higherValue{
            if let low = Int(lowVal), let high = Int(highVal), high >= low{
                delegate?.priceUpdate(cell: self, low: low, high: high, isValid: true)
            } else {
                delegate?.priceUpdate(cell: self, low: 0, high: 0, isValid: false)
            }
        } else {
            delegate?.priceUpdate(cell: self, low: 0, high: 0, isValid: false)
        }
    }
    
}
