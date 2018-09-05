//
//  ESCancleAppointReasonTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/25.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit



class ESCancleAppointReasonTableViewCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var placeHoldLabel: UILabel!
    
    private var cellIndex:NSInteger = 0
    private weak var viewController:ESCancleAppointViewController?
    private weak var viewController1:ESApplyChargebackViewController?
    private var isApplyChargeback = false //是申请退款？
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = ESColor.color(sample: .separatorLine).cgColor
        
        textView.delegate = self
    }
    
    //MARK: - setter
    func setCellIndex(index:NSInteger, vc:ESCancleAppointViewController){
        self.cellIndex = index
        self.viewController = vc
        self.isApplyChargeback = false
    }
    
    func setApplyChargebackCellIndex(index:NSInteger, vc:ESApplyChargebackViewController){
        self.cellIndex = index
        self.viewController1 = vc
        self.isApplyChargeback = true
        
    }
    
    //MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        placeHoldLabel.text = ""
        if isApplyChargeback {
            if let viewController1 = self.viewController1 {
                viewController1.currentRect = ESCGRectUtil.getRelativeCGrect(view: textView)
            }
        } else {
            if let viewController = self.viewController {
                viewController.currentRect = ESCGRectUtil.getRelativeCGrect(view: textView)
            }
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if !isApplyChargeback {
            let text = textView.text
            if textView.text.count > 500 {
                if let viewController = self.viewController {
                    
                    MBProgressHUD.showError("最多500字哦～", to: viewController.view)
                }
                textView.text = NSString(string: text!).substring(to: 500)
            }
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            placeHoldLabel.text = "您可以在这里填写您取消预约的原因哦～"
        } else {
            placeHoldLabel.text = ""
            if isApplyChargeback {
                if let viewController1 = self.viewController1 {
                    viewController1.uploadDic[ESCancleAppointUploadDic.CancleInputed.rawValue] = textView.text ?? ""
                }
            } else {
                if let viewController = self.viewController {
                    viewController.uploadDic[ESCancleAppointUploadDic.CancleInputed.rawValue] = textView.text ?? ""
                }
            }
        }
    }
}
