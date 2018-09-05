//
//  ESPreviewResultSecondTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/19.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESPreviewResultSecondTableViewCell: UITableViewCell,UITextViewDelegate{
    
    @IBOutlet weak var placeHoldLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    private var isMark:Bool = false
    private var cellIndex:NSInteger = 0
    private weak var viewController:ESPreviewResultViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK: - setter
    func setCellIndex(index:NSInteger, vc:ESPreviewResultViewController){
        self.cellIndex = index
        self.viewController = vc
    }
    
    func setCellMark(isMark:Bool,address:String?){
        self.isMark = isMark
        if isMark {
            placeHoldLabel.text = "请输入备注说明"
            textViewHeight.constant = 92
        } else {
            textViewHeight.constant = 59.5
            placeHoldLabel.text = address ?? "请输入详细地址，需精确到单元-门牌号"
        }
    }
    
    
    //MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        placeHoldLabel.text = ""
        if let viewController = self.viewController {
            viewController.currentRect = ESCGRectUtil.getRelativeCGrect(view: textView)
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            if isMark {
                placeHoldLabel.text = "请输入备注说明"
            } else {
                placeHoldLabel.text = "请输入详细地址，需精确到单元-门牌号"
            }
        } else {
            placeHoldLabel.text = ""
            if let viewController = self.viewController {
                if isMark {
                    viewController.uploadDic[ESPreviewResultUploadDic.Mark.rawValue] = textView.text ?? ""
                } else {
                    viewController.uploadDic[ESPreviewResultUploadDic.Adress.rawValue] = textView.text ?? ""
                }
            }
        }
    }
}

