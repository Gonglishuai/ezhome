//
//  ESPackageButtonView.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/29.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESPackageButtonView: UIView {

    lazy var iconBack = UIImageView()
    lazy var icon = UIImageView()

    lazy var title = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(iconBack)
        iconBack.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.centerX.equalTo(self.snp.centerX)
            make.size.equalTo(CGSize(width: 60.scalValue, height: 60.scalValue))
        }
        iconBack.backgroundColor = ESColor.color(hexColor: 0x6A91FE, alpha: 1)
        iconBack.layer.masksToBounds = true
        iconBack.layer.cornerRadius = 30.scalValue
        
        
        iconBack.addSubview(icon)
        icon.snp.makeConstraints { (make) in
            make.center.equalTo(iconBack.snp.center)
            make.size.equalTo(CGSize(width: 24.scalValue, height: 24.scalValue))
        }
        
        addSubview(title)
        title.textColor = ESColor.color(sample: .mainTitleColorB)
        title.font = ESFont.font(name: .regular, size: 15)
        title.textAlignment = .center
        
        title.snp.makeConstraints { (make) in
            make.top.equalTo(iconBack.snp.bottom).offset(5.scalValue)
            make.centerX.equalTo(self.snp.centerX)
            make.size.equalTo(CGSize(width: 70.scalValue, height: 21.scalValue))
        }
        icon.isUserInteractionEnabled = true
    }
    
    func setViewData(_ image:UIImage, text:String){
        
        icon.image = image
        title.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/// 套餐入口button
class ESPackageButtonViewForMain: UIView {
    
    lazy var title = UILabel()
    lazy var icon = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(title)
        title.textColor = ESColor.color(sample: .mainTitleColorB)
        title.font = ESFont.font(name: .regular, size: 15)
        title.textAlignment = .center
        
        title.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.size.equalTo(21)
        }
        
        
        addSubview(icon)
        icon.snp.makeConstraints { (make) in
            make.left.equalTo(title.snp.right).offset(2)
            make.centerY.equalTo(title.snp.centerY)
            make.size.equalTo(CGSize(width: 3, height: 3))
        }
        icon.image = ESPackageAsserts.bundleImage(named: "arrow_right")
        
    }
    
    func setViewData(_ text:String){
        title.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

