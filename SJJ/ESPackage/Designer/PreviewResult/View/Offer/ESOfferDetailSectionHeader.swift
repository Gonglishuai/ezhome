//
//  ESOfferDetailSectionHeader.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/27.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESOfferDetailSectionHeader: UITableViewHeaderFooterView {
    lazy var statusLabel: UILabel = {
        return customView(title: "")
    }()
    
    lazy var amountLabel: UILabel = {
        return customView(title: "")
    }()
    
    lazy var dateLabel: UILabel = {
        return customView(title: "")
    }()
    
    var downLeftLabel: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let backView = UIView()
        backView.backgroundColor = UIColor.white
        
        backgroundView = backView
        
        let line = UIView()
        line.backgroundColor = ESColor.color(sample: .backgroundView)
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
            make.size.equalTo(CGSize(width: ScreenWidth, height: 10))
        }
        
        let leftLabel = customView(title: "当前状态")
        
        addSubview(leftLabel)
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(line.snp.bottom).offset(18)
            make.height.equalTo(20)
        }
        
        addSubview(statusLabel)
        statusLabel.snp.makeConstraints { (make) in
            make.left.equalTo(leftLabel.snp.right).offset(15)
            make.top.equalTo(line.snp.bottom).offset(18)
            make.height.equalTo(20)
        }
        statusLabel.textColor = ESColor.color(sample: .buttonOrange)
        
        
        let amountTitle = customView(title: "合同金额")
        addSubview(amountTitle)
        amountTitle.snp.makeConstraints { (make) in
            make.top.equalTo(leftLabel.snp.bottom).offset(10)
            make.left.equalTo(leftLabel)
            make.height.equalTo(20)
        }
        
        addSubview(amountLabel)
        amountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(amountTitle.snp.right).offset(15)
            make.top.equalTo(amountTitle)
            make.height.equalTo(amountTitle)
        }
        
        downLeftLabel = customView(title: "审核时间")
        
        addSubview(downLeftLabel)
        downLeftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(amountTitle.snp.bottom).offset(10)
            make.height.equalTo(20)
        }
        
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(downLeftLabel.snp.right).offset(15)
            make.top.equalTo(downLeftLabel)
            make.height.equalTo(20)
        }
        
        let line1 = UIView()
        line1.backgroundColor = ESColor.color(sample: .backgroundView)
        addSubview(line1)
        line1.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(dateLabel.snp.bottom).offset(18)
            make.size.equalTo(CGSize(width: ScreenWidth, height: 10))
        }
    }
    
    private func customView(title:String)-> UILabel {
        
        let label = UILabel()
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.font = ESFont.font(name: ESFont.ESFontName.regular, size: 14)
        label.text = title
        label.numberOfLines = 1
        label.sizeToFit()
        
        return label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
