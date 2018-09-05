//
//  ESPreviewResultDetailSectionHeader.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/20.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESPreviewResultDetailSectionHeader: UITableViewHeaderFooterView {

    lazy var statusLabel: UILabel = {
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
            make.left.equalTo(0)
            make.top.equalTo(0)
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
            make.left.equalTo(leftLabel.snp.right).offset(35)
            make.top.equalTo(line.snp.bottom).offset(18)
            make.height.equalTo(20)
        }
        statusLabel.textColor = ESColor.color(sample: .buttonOrange)
        
        downLeftLabel = customView(title: "预交底时间")
        
        addSubview(downLeftLabel)
        downLeftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(leftLabel.snp.bottom).offset(10)
            make.height.equalTo(20)
        }
        
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(downLeftLabel.snp.right).offset(15)
            make.top.equalTo(statusLabel.snp.bottom).offset(10)
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
    
    //TODO: - model
    func setHeaderDateLabel(){
        statusLabel.text = "定金"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
