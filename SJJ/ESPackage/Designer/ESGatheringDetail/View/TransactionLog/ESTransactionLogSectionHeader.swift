//
//  ESTransactionLogSectionHeader.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/19.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESTransactionLogSectionHeader: UITableViewHeaderFooterView {
    
    lazy var costNameLabel: UILabel = {
        return customView(title: "定金")
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 50)
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 50))
        backView.backgroundColor = UIColor.white
        
        backgroundView = backView
        
        let leftLabel = customView(title: "费用名称")
        
        addSubview(leftLabel)
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(CGSize(width: 70, height: 19))
        }
        
        addSubview(costNameLabel)
        costNameLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-30)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(19)
        }
        
    }
    
    private func customView(title:String)-> UILabel {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = ESFont.font(name: ESFont.ESFontName.regular, size: 13)
        label.text = title
        return label
    }
    
    //TODO: - model
    func setHeaderDateLabel(){
        costNameLabel.text = "定金"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
