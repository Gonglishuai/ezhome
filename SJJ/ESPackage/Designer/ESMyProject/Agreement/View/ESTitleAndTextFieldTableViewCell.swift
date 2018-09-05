//
//  ESTitleAndTextFieldTableViewCell.swift
//  Consumer
//
//  Created by jiang on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESEndEditTextDelegate: NSObjectProtocol {
    func didFinishedEdit(text: String?, indexPath:IndexPath?)
}

class ESTitleAndTextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTextfield: UITextField!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var arrowImgView: UIImageView!
    weak var delegate: ESEndEditTextDelegate?
    private var myIndexPath: IndexPath?
    private var lastArea: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.textColor = UIColor.stec_titleText()
        self.titleLabel.font = UIFont.stec_titleFount()
        
        self.subTextfield.textColor = UIColor.stec_titleText()
        self.subTextfield.font = UIFont.stec_titleFount()
        self.subTextfield.delegate = self;
        self.unitLabel.font = UIFont.stec_subTitleFount()
        self.unitLabel.textColor = UIColor.stec_titleText()
        self.lineLabel.backgroundColor = UIColor.stec_lineGray()
        // Initialization code
    }
    public func setInfo(title: String, subTitle: String, placeHolder: String, unintTitle: String, hiddenArrow:Bool, indexPath:IndexPath) {
        self.titleLabel.text = title
        self.subTextfield.placeholder = placeHolder
        self.subTextfield.text = subTitle
        self.unitLabel.text = unintTitle
        self.arrowImgView.isHidden = hiddenArrow
        self.subTextfield.isEnabled = hiddenArrow
        myIndexPath = indexPath;
        
        var keyboardType = UIKeyboardType.default
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                keyboardType = .numberPad
            } else if indexPath.row == 2 || indexPath.row == 8 {
                keyboardType = .decimalPad
                self.arrowImgView.isHidden = true
            } else if indexPath.row == 11 {
                keyboardType = .numberPad
            }
        }
        
        subTextfield.keyboardType = keyboardType
    }
    
    public func hiddenLineLabel(hiddenLabel:Bool) {
        self.lineLabel.isHidden = hiddenLabel
    }
    public func setSubTitle(textFieldTitle: String) {
        self.subTextfield.text = textFieldTitle
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let indepath = self.myIndexPath, let dele = delegate {
            dele.didFinishedEdit(text: textField.text, indexPath: indepath)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if myIndexPath?.section == 0 && myIndexPath?.row == 2 {
            return ESFormCheck.checkHouseSizeForm(textField: textField, range: range, string: string)
        } else if myIndexPath?.section == 0 && myIndexPath?.row == 8 {
            if let text = textField.text, text.contains("."), string == "." {
                return false
            }
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if myIndexPath?.section == 0 && myIndexPath?.row == 2 {
            let fixedText =  ESFormCheck.fixInputedHouseSize(text: textField.text ?? "")
            textField.text = fixedText
        }
        return true
    }
}
