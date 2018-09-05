//
//  ESTextViewTableViewCell.swift
//  Consumer
//
//  Created by jiang on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESTextViewTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textviewHeightLayoutConstraint: NSLayoutConstraint!
    private var myPlaceholder = "请输入备注说明~"
    @IBOutlet weak var lineLabel: UILabel!
    weak var delegate: ESEndEditTextDelegate?
    private var myIndexPath: IndexPath?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textviewHeightLayoutConstraint.constant = textView.contentSize.height
        textView.textColor = UIColor.stec_titleText()
        textView.font = UIFont.stec_subTitleFount()
        textView.delegate = self
        lineLabel.backgroundColor = UIColor.stec_lineGray()
    }

    public func setInfo(title: String, placeHolder: String, height:CGFloat, indexPath:IndexPath) {
        self.textView.text = title;
        self.myPlaceholder = placeHolder;
        if textView.text.isEmpty {
            textView.text = myPlaceholder;
            textView.textColor = UIColor.stec_contentText()
        }
        textviewHeightLayoutConstraint.constant = height
        myIndexPath = indexPath;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.myPlaceholder == textView.text {
            textView.text = ""
            textView.textColor = UIColor.stec_titleText()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let indepath = self.myIndexPath, let dele = delegate {
            dele.didFinishedEdit(text: textView.text, indexPath: indepath)
        }
        if textView.text.isEmpty {
            textView.text = myPlaceholder;
            textView.textColor = UIColor.stec_contentText()
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
