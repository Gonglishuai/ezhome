//
//  ESCreatBrandListFirstCell.swift
//  Consumer
//
//  Created by zhang dekai on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESCreatBrandListFirstCellProtocol:NSObjectProtocol {
    
    func textFiledText(text:String)
    
}

class ESCreatBrandListFirstCell: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var listName: UITextField!
    
    private weak var cellDelegate:ESCreatBrandListFirstCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        listName.placeholder = "请输入客户姓名"
        listName.delegate = self
    }
    
    func setCellDelegate(delegate:ESCreatBrandListFirstCellProtocol){
        self.cellDelegate = delegate
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        let originText : NSString = textField.text as NSString? ?? ""
        
        let resultText = originText.replacingCharacters(in: range, with: string)
        
        
        if resultText.count > 20 && resultText.count > originText.length {//限制位数
            return false
        }
        return true
    }
    
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        if let delegate = cellDelegate {
//            delegate.textFiledText(text: textField.text ?? "")
//        }
//        return true
//    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let delegate = cellDelegate {
            delegate.textFiledText(text: textField.text ?? "")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
