//
//  ESDesignerGathringView.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/18.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

@objc protocol ESDesignerGathringViewForTableHeaderDelegate:NSObjectProtocol {
    func openTipsView()
}
/// 收款明细TableHeader
class ESDesignerGathringViewForTableHeader: UIView {
    
    var headerDelegate : ESDesignerGathringViewForTableHeaderDelegate?
    
    lazy var backgroundView: UIImageView = {//已收 or 待收
        var imageView = UIImageView()
        return imageView
    }()
    
    lazy var dueIn: UILabel = {//已收 or 待收
        var label = UILabel()
        label.textColor = UIColor.white
        label.font = ESFont.font(name: ESFont.ESFontName.medium, size: 14)
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    lazy var moneyLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.font = ESFont.font(name: ESFont.ESFontName.smedium, size: 23)
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    lazy var hasMoneyLabel: UILabel = {//已发起
        var label = UILabel()
        label.textColor = UIColor.white
        label.font = ESFont.font(name: ESFont.ESFontName.regular, size: 11)
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    lazy var tipBtn: UIButton = {//优惠时效性说明
        var tipBtn = UIButton()
        tipBtn.setTitle("优惠时效性说明", for: UIControlState.normal)
        tipBtn.setTitleColor(ESColor.color(sample: .buttonBlue), for: UIControlState.normal)
        tipBtn.addTarget(self, action:#selector(tapClick), for:.touchUpInside)
        tipBtn.titleLabel?.font = ESFont.font(name: ESFont.ESFontName.medium, size: 14)
        return tipBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = ESColor.color(sample: .backgroundView)
        self.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 50 + CGFloat(125).scalValue)

        //待收 ￥10000
        self.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(10)
            make.left.equalTo(self.snp.left).offset(20)
            make.size.equalTo(CGSize(width: ScreenWidth - 40, height: CGFloat(125.0).scalValue))
        }
        
        //待收￥
        backgroundView.addSubview(dueIn)
        dueIn.snp.makeConstraints { (make) in
            make.top.equalTo(CGFloat(38.0).scalValue)
            make.left.equalTo(CGFloat(110).scalValue)
            make.size.equalTo(CGSize(width: 45, height: 20))
        }
        
        backgroundView.addSubview(moneyLabel)
        moneyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dueIn.snp.right).offset(5)
            make.centerY.equalTo(self.dueIn.snp.centerY)
            make.height.equalTo(32.5)
        }

        backgroundView.addSubview(hasMoneyLabel)
        hasMoneyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(132.5)
            make.top.equalTo(self.dueIn.snp.bottom).offset(7)
            make.height.equalTo(15)
        }
        
        self.addSubview(tipBtn)
        tipBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-16)
            make.bottom.equalTo(self.snp.bottom).offset(-4)
            make.height.equalTo(30)
        }
    }
    
    func setupGathringDetailHeaderModel(_ model:ESGatheringDetailsSubModel, role:ESRole) {
        backgroundView.image = ESPackageAsserts.bundleImage(named: "gathering_getting")
        dueIn.text = "待收￥"
        
        if let unPaidAmount = model.unPaidAmount,unPaidAmount > 0.0 {
            moneyLabel.text = String(format: "%.2f", unPaidAmount)
        } else {
            moneyLabel.text = String(format: "0.00")
        }
        if let amount = model.amount,amount > 0.0 {
            hasMoneyLabel.text = String(format: "已发起￥ %.2f", amount)
        } else {
            hasMoneyLabel.text = String(format: "已发起￥ 0.00")
        }
        
        switch role {
        case .proprietor(_):
            dueIn.text = "待付￥"
            hasMoneyLabel.isHidden = true
            
            dueIn.snp.remakeConstraints { (make) in
                make.centerY.equalTo(self.backgroundView.snp.centerY)
                make.left.equalTo(CGFloat(110).scalValue)
                make.size.equalTo(CGSize(width: 45, height: 20))
            }
            
            moneyLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(dueIn.snp.right).offset(5)
                make.centerY.equalTo(self.dueIn.snp.centerY)
                make.height.equalTo(32.5)
            }
        default:
            break
        }
       
    }
    
    func setupTransactionHeaderModel(_ model:ESTransactionModel, role:ESRole) {
        backgroundView.image = ESPackageAsserts.bundleImage(named: "gathering_got")
        dueIn.text = "已收￥"
        if let paidAmount = model.paidAmount,paidAmount > 0.0 {
            moneyLabel.text = String(format: "%.2f", paidAmount)
        } else {
            moneyLabel.text = String(format: "0.00")
        }
        if let payAmount = model.payAmount,payAmount > 0.0 {
            hasMoneyLabel.text = String(format: "已发起￥ %.2f", payAmount)
        } else {
            hasMoneyLabel.text = String(format: "已发起￥ 0.00")
        }
        
        switch role {
        case .proprietor(_):
            dueIn.text = "已付￥"
            hasMoneyLabel.isHidden = true
            
            dueIn.snp.remakeConstraints { (make) in
                make.centerY.equalTo(self.backgroundView.snp.centerY)
                make.left.equalTo(CGFloat(110).scalValue)
                make.size.equalTo(CGSize(width: 45, height: 20))
            }
            
            moneyLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(dueIn.snp.right).offset(5)
                make.centerY.equalTo(self.dueIn.snp.centerY)
                make.height.equalTo(32.5)
            }
        default:
            hasMoneyLabel.isHidden = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapClick(){
        self.headerDelegate?.openTipsView()
    }
}
