//
//  ESCreateBrandListRecommdReasonSectionHeader.swift
//  Consumer
//
//  Created by zhang dekai on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESCreateBrandListRecommdReasonSectionHeader: UITableViewHeaderFooterView {

    lazy var brandNumber: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(hexColor: 0x9B9B9B, alpha: 1)
        label.font = ESFont.font(name: .regular, size: 12)
        label.textAlignment = .right
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let backView = UIView()
        backView.backgroundColor = UIColor.white
        
        backgroundView = backView
        
        let recommdLabel = UILabel()
        recommdLabel.textColor = ESColor.color(sample: .mainTitleColor)
        recommdLabel.font = ESFont.font(name: .regular, size: 13)
        recommdLabel.text = "推荐品牌"
        self.addSubview(recommdLabel)
        
        recommdLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(15)
            make.height.equalTo(18.5)
        }
        
        self.addSubview(brandNumber)
        brandNumber.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.top.equalTo(16.5)
            make.height.equalTo(16)
        }
        brandNumber.text = "1个品牌"
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
