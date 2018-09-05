//
//  ESChargebackDetailFirstTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/26.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESChargebackDetailFirstTableViewCell: UITableViewCell {
    @IBOutlet weak var orderStatus: UILabel!
    
    @IBOutlet weak var orderMoney: UILabel!
    
    @IBOutlet weak var reasonBackView: UIView!
    
    @IBOutlet weak var reasonLabel: UILabel!
    
    @IBOutlet weak var bottomH: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        reasonBackView.layer.masksToBounds = true
        reasonBackView.layer.cornerRadius = 3
    }
    
    func setCellElementModel(_ model:ESChargebackDetailsModel){
        
        orderStatus.text = model.operateStatusName ?? "--"

        if let checkRemark = model.checkRemark, checkRemark != "" {
            reasonBackView.isHidden = false
            reasonLabel.attributedText = ESStringUtil.returnNSMutableAttributedString(checkRemark, space: 5)
        } else {
            reasonBackView.isHidden = true
            bottomH.constant = -32
        }
        
        
        if let money = model.amount, money != 0.0 {
            orderMoney.text = "￥\(money)"
        } else {
            orderMoney.text = "--"
        }
    }
    
    lazy var titleLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 50))
        label.text = "退款进度"
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = ESFont.font(name: ESFont.ESFontName.regular, size: 13)
        return label
        
    }()
    
}
