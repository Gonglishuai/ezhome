//
//  ESCreatBrandListSecondCell.swift
//  Consumer
//
//  Created by zhang dekai on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESCreatBrandListSecondCellProtocol:NSObjectProtocol {
    func textViewText(text:String)
}

class ESCreatBrandListSecondCell: UITableViewCell,UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var placeHold: UILabel!
    
    private weak var cellDelegate:ESCreatBrandListSecondCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.delegate = self
        
        sendSubview(toBack: textView)
    }
    
    func setCellDelegate(delegate:ESCreatBrandListSecondCellProtocol){
        self.cellDelegate = delegate
    }
    
    func setTextViewText(text:String){
            placeHold.isHidden = true
            textView.text = text
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        placeHold.isHidden = true

        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {

//        let text = textView.text ?? ""
        
//        if text.count > 50 {
//            textView.text = NSString(string: text).substring(to: 50)
//        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        let text = textView.text ?? ""
        
        if text.isEmpty {
            placeHold.isHidden = false
        } else {
            placeHold.isHidden = true
        }
        if let delegate = cellDelegate {
            delegate.textViewText(text: text)
        }
        return true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
