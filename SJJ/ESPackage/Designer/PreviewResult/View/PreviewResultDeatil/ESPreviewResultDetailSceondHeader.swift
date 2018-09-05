//
//  ESPreviewResultDetailSceondHeader.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/21.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESPreviewResultDetailSceondHeader: UITableViewHeaderFooterView {
    lazy var statusLabel: UILabel = {
        return customView(title: "业主信息")
    }()
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let backView = UIView()
        backView.backgroundColor = UIColor.white
        
        backgroundView = backView
        
        addSubview(statusLabel)
        statusLabel.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(19)
        }
        
    }
    
    func resetConstrantsForOffer(){
        statusLabel.textColor = ESColor.color(sample: .mainTitleColor)
        statusLabel.snp.remakeConstraints { (make) in
            make.left.equalTo(20)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(19)
        }
        
    }
    
    private func customView(title:String)-> UILabel {
        
        let label = UILabel()
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.font = ESFont.font(name: ESFont.ESFontName.medium, size: 13)
        label.text = title
        label.numberOfLines = 1
        label.sizeToFit()
        
        return label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ESPreviewResultDetailSceondFooter: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let backView = UIView()
        backView.backgroundColor = UIColor.white
        
        backgroundView = backView
//
//        let line = UIView()
//        line.backgroundColor = ESColor.color(sample: .separatorLine)
//        addSubview(line)
//
//        line.snp.makeConstraints { (make) in
//            make.left.equalTo(38)
//            make.top.equalTo(self.snp.top).offset(22)
//            make.size.equalTo(CGSize(width: ScreenWidth - 38 * 2, height: 1))
//        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

