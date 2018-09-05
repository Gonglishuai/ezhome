//
//  ESPreviewResultSectionHeader.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/19.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESPreviewResultSectionHeader: UITableViewHeaderFooterView {

    lazy var sectionLeftLabel: UILabel = {
        return customView(title: "")
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let backView = UIView()//frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 50))
        backView.backgroundColor = ESColor.color(sample: .backgroundView)
        
        backgroundView = backView
        
        addSubview(sectionLeftLabel)
        sectionLeftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(CGSize(width: 200, height: 19))
        }
        
    }
    
    func setPackageDetaillayout(){
        sectionLeftLabel.textColor = ESColor.color(sample: .mainTitleColorB)
        sectionLeftLabel.font = ESFont.font(name: .medium, size: 16)
        sectionLeftLabel.snp.remakeConstraints { (make) in
            make.left.equalTo(17.5)
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(CGSize(width: 200, height: 24))
        }
        backgroundView?.backgroundColor = UIColor.white
    }
    
    private func customView(title:String)-> UILabel {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.font = ESFont.font(name: ESFont.ESFontName.regular, size: 13)
        label.text = title
        return label
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
