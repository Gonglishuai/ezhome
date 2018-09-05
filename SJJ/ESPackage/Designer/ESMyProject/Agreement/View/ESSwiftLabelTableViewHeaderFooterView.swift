//
//  ESSwiftLabelTableViewHeaderFooterView.swift
//  Consumer
//
//  Created by jiang on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESSwiftLabelTableViewHeaderFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.titleLabel.textColor = UIColor.stec_titleText()
        self.titleLabel.font = UIFont.stec_titleFount()
        
        self.subTitleLabel.textColor = UIColor.stec_titleText()
        self.subTitleLabel.font = UIFont.stec_titleFount()
        
        
    }

    public func setInfo(backColor:UIColor, title:String, titleColor:UIColor, subTitle:String?, subTitleColor:UIColor?) {
        self.backView.backgroundColor = backColor
        self.titleLabel.text = title;
        self.titleLabel.textColor = titleColor

        self.subTitleLabel.text = subTitle ?? "";
        self.subTitleLabel.textColor = subTitleColor ?? UIColor.stec_subTitleText()
    }

}
