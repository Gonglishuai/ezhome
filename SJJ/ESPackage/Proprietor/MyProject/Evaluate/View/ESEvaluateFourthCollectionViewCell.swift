//
//  ESEvaluateFourthCollectionViewCell.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/31.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESEvaluateFourthCollectionViewCellProtocol:NSObjectProtocol {
    func textViewText(text:String)
}

class ESEvaluateFourthCollectionViewCell: UICollectionViewCell, UITextViewDelegate {
    
    var cellDelegate:ESEvaluateFourthCollectionViewCellProtocol?
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var placeHolder: UILabel!
    
    @IBOutlet weak var number: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.delegate = self
        
        textView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        placeHolder.isHidden = true
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
       
        let text = textView.text ?? ""
        
        if text.isEmpty {
            placeHolder.isHidden = false
        } else {
            placeHolder.isHidden = true
        }
        if text.count > 500 {
            
            textView.text = NSString(string: text).substring(to: 500)
            number.text = "0"

        } else {
            
            number.text = "\(500 - text.count)"
        }
        
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let delegate = self.cellDelegate {
            delegate.textViewText(text: textView.text ?? "")
        }
        return true
    }
    
    
    
}
