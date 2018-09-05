//
//  ESChargebackDetailSectionHeader.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/26.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESChargebackDetailSectionHeader: UITableViewHeaderFooterView {

    lazy var sectionLeftLabel: UILabel = {
        return customView(title: "")
    }()
    
    lazy var sectionRightLabel: UILabel = {
        return customView(title: "")
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 45)
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 50))
        backView.backgroundColor = ESColor.color(sample: .backgroundView)
        
        backgroundView = backView
        
        addSubview(sectionLeftLabel)
        sectionLeftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(18)
            make.size.equalTo(CGSize(width: 200, height: 18.5))
        }
        
        addSubview(sectionRightLabel)
        sectionRightLabel.textColor = ESColor.color(sample: .subTitleColor)
        sectionRightLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.top.equalTo(18)
            make.height.equalTo(18.5)
        }
        
        sectionRightLabel.isHidden = true
        
    }
    
    private func customView(title:String)-> UILabel {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = ESFont.font(name: ESFont.ESFontName.regular, size: 13)
        label.text = title
        return label
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
