//
//  ESCaseOfferSectionHeaderView.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/8.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESCaseOfferSectionHeaderView: UITableViewHeaderFooterView {
    
    lazy var statusLabel: UILabel = {
        return customView(title: "项目")
    }()
    
    var downLeftLabel: UILabel!
    
    lazy var packageType = UILabel()
    
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
            make.size.equalTo(CGSize(width: ScreenWidth, height: 50))
        }
        
        let leftImage = UIImageView(image: #imageLiteral(resourceName: "case_offer_icon"))
        addSubview(leftImage)
        
        leftImage.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(self.snp.top).offset(20)
            make.size.equalTo(CGSize(width: 16, height: 20))
        }
        
        
        let leftLabel = customView(title: "报价汇总表")
        
        addSubview(leftLabel)
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(leftImage.snp.right).offset(10)
            make.top.equalTo(self.snp.top).offset(22)
            make.height.equalTo(20)
        }
        
        addSubview(packageType)
        packageType.snp.makeConstraints { (make) in
            make.left.equalTo(leftImage.snp.right).offset(10)
            make.top.equalTo(self.snp.top).offset(22)
            make.height.equalTo(20)
        }
        addSubview(statusLabel)
        statusLabel.font = ESFont.font(name: .medium, size: 12)
        statusLabel.snp.makeConstraints { (make) in
            make.left.equalTo(88)
            make.top.equalTo(line.snp.bottom).offset(15)
            make.height.equalTo(17)
        }
        
        downLeftLabel = customView(title: "金额")
        downLeftLabel.font = ESFont.font(name: .medium, size: 12)

        addSubview(downLeftLabel)
        downLeftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(274.scalValue)
            make.top.equalTo(line.snp.bottom).offset(15)
            make.height.equalTo(17)
        }
    }
    
    private func customView(title:String)-> UILabel {
        
        let label = UILabel()
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = ESFont.font(name: ESFont.ESFontName.regular, size: 14)
        label.text = title
        label.numberOfLines = 1
        label.sizeToFit()
        
        return label
    }
    
    //TODO: - model
    func setHeaderDateLabel(){
        statusLabel.text = "定金"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
