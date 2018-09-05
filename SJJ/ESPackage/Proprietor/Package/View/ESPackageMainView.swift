//
//  ESPackageMainView.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/29.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESPackageMainView: UIView {
    
    private var packageView:ESPackageButtonView!
    private var orderView:ESPackageButtonView!
    private var personalView:ESPackageButtonView!
    private lazy var yellowImageView = UIImageView()
    private weak var containerVC:ESPackageMainViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //居然设计家装修服务指南
        let titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.textColor = ESColor.color(sample: .mainTitleColorB)
        titleLabel.font = ESFont.font(name: .medium, size: 18)
        
        let leftGap = 15.scalValue
        let packageButtonH = 21.scalValue
        let bigLabelH = 25.scalValue
        let littleLabelH = 14.scalValue
        let arrowHW = 6.scalValue

        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(leftGap)
            make.top.equalTo(70.scalValue)
            make.size.equalTo(CGSize(width: ScreenWidth - leftGap * 2, height: bigLabelH))
        }
        titleLabel.text = "居然设计家装修服务指南"
        
        //套餐全流程
        let packageButton = customButton("标准化套餐")
        addSubview(packageButton)
        
        packageButton.snp.makeConstraints { (make) in
            make.left.equalTo(leftGap)
            make.top.equalTo(titleLabel.snp.bottom).offset(bigLabelH)
            make.height.equalTo(packageButtonH)
        }
        
        //箭头
        let packageButtonIcon = UIImageView(image: ESPackageAsserts.bundleImage(named: "package_arrow_little"))
        addSubview(packageButtonIcon)
        
        packageButtonIcon.snp.makeConstraints { (make) in
            make.left.equalTo(packageButton.snp.right).offset(4.5.scalValue)
            make.centerY.equalTo(packageButton.snp.centerY)
            make.size.equalTo(CGSize(width: arrowHW, height: arrowHW))
        }
        
        //所见即所得，海量样板间
        let subPackageLabel = customLabel("所见即所得，海量样板间")
        addSubview(subPackageLabel)
        subPackageLabel.snp.makeConstraints { (make) in
            make.left.equalTo(leftGap)
            make.top.equalTo(packageButton.snp.bottom).offset(5.scalValue)
            make.height.equalTo(littleLabelH)
        }
        
        
        //hot icon
        let hotIcon = UIImageView(image: ESPackageAsserts.bundleImage(named: "package_hot"))
        addSubview(hotIcon)
        
        hotIcon.snp.makeConstraints { (make) in
            make.left.equalTo(packageButtonIcon.snp.right).offset(8.scalValue)
            make.centerY.equalTo(packageButton.snp.centerY)
            make.size.equalTo(CGSize(width: 26.scalValue, height: 16.5.scalValue))
        }
        
        
        let subPackageButton = UIButton()
        addSubview(subPackageButton)
        subPackageButton.snp.makeConstraints { (make) in
            make.left.equalTo(packageButton.snp.left)
            make.top.equalTo(packageButton.snp.top)
            make.right.equalTo(hotIcon.snp.right)
            make.bottom.equalTo(subPackageLabel.snp.bottom)
        }
        subPackageButton.tag = 100
        subPackageButton.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        
        //个性化家装
        let personalButton = customButton("个性化家装")
        addSubview(personalButton)
        
        personalButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(titleLabel.snp.bottom).offset(bigLabelH)
            make.height.equalTo(packageButtonH)
        }
        
        //箭头
        let personalButtonIcon = UIImageView(image: ESPackageAsserts.bundleImage(named: "package_arrow_little"))
        addSubview(personalButtonIcon)
        
        personalButtonIcon.snp.makeConstraints { (make) in
            make.left.equalTo(personalButton.snp.right).offset(4.5.scalValue)
            make.centerY.equalTo(packageButton.snp.centerY)
            make.size.equalTo(CGSize(width: arrowHW, height: arrowHW))
        }
        
        //想你所想装修不愁
        let subPersonalLabel = customLabel("想你所想装修不愁")
        addSubview(subPersonalLabel)
        subPersonalLabel.snp.makeConstraints { (make) in
            make.left.equalTo(personalButton.snp.left)
            make.top.equalTo(personalButton.snp.bottom).offset(5.scalValue)
            make.height.equalTo(littleLabelH)
        }

        let subPackageButton1 = UIButton()
        addSubview(subPackageButton1)
        subPackageButton1.snp.makeConstraints { (make) in
            make.left.equalTo(personalButton.snp.left)
            make.top.equalTo(personalButton.snp.top)
            make.right.equalTo(personalButtonIcon.snp.right)
            make.bottom.equalTo(subPersonalLabel.snp.bottom)
        }
        subPackageButton1.tag = 101
        subPackageButton1.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        
        
        //预约设计家
        let orderButton = customButton("预约设计家")
        addSubview(orderButton)
        
        orderButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-27.5)
            make.top.equalTo(titleLabel.snp.bottom).offset(bigLabelH)
            make.height.equalTo(packageButtonH)
        }
        
        //箭头
        let orderButtonIcon = UIImageView(image: ESPackageAsserts.bundleImage(named: "package_arrow_little"))
        addSubview(orderButtonIcon)
        
        orderButtonIcon.snp.makeConstraints { (make) in
            make.left.equalTo(orderButton.snp.right).offset(4.5.scalValue)
            make.centerY.equalTo(packageButton.snp.centerY)
            make.size.equalTo(CGSize(width: arrowHW, height: arrowHW))
        }
        
        //解决装修疑问
        let subOrderLabel = customLabel("解决装修疑问")
        addSubview(subOrderLabel)
        subOrderLabel.snp.makeConstraints { (make) in
            make.left.equalTo(orderButton.snp.left)
            make.top.equalTo(orderButton.snp.bottom).offset(5.scalValue)
            make.height.equalTo(littleLabelH)
        }

        let subPackageButton2 = UIButton()
        addSubview(subPackageButton2)
        subPackageButton2.snp.makeConstraints { (make) in
            make.left.equalTo(orderButton.snp.left)
            make.top.equalTo(orderButton.snp.top)
            make.right.equalTo(orderButtonIcon.snp.right)
            make.bottom.equalTo(subOrderLabel.snp.bottom)
        }
        subPackageButton2.tag = 102
        subPackageButton2.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        //黄色占位图
        yellowImageView.image = ESPackageAsserts.bundleImage(named: "package_temp_image")
        addSubview(yellowImageView)
        
        yellowImageView.isUserInteractionEnabled = true
        
        yellowImageView.snp.makeConstraints { (make) in
            make.left.equalTo(leftGap)
            make.top.equalTo(subOrderLabel.snp.bottom).offset(leftGap.scalValue)
            make.size.equalTo(CGSize(width: ScreenWidth - 30, height: 45.scalValue))
        }
        yellowImageView.backgroundColor = UIColor.yellow
        
        //gif
        let gifImageView = UIImageView(image: ESPackageAsserts.bundleImage(named: "package_calculate_money"))
        addSubview(gifImageView)
        
        gifImageView.snp.makeConstraints { (make) in
            make.top.equalTo(yellowImageView.snp.bottom).offset(10.scalValue)
            make.centerX.equalTo(self.snp.centerX)
            make.size.equalTo(CGSize(width: 196.scalValue, height: 253.scalValue))
        }
        gifImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMethod(_:)))
        gifImageView.addGestureRecognizer(tap)
        
        
        //套餐
        packageView = setPackageView()
        
        addSubview(packageView)
        
        packageView.snp.makeConstraints { (make) in
            make.top.equalTo(gifImageView.snp.bottom).offset(20.scalValue)
            make.left.equalTo(30.scalValue)
            make.size.equalTo(CGSize(width: 70, height: 90))
        }
        
        //超值全包
        let packageIconSubIcon = UIImageView(image: ESPackageAsserts.bundleImage(named: "package_worth_ball"))
        addSubview(packageIconSubIcon)
        
        packageIconSubIcon.snp.makeConstraints { (make) in
            make.top.equalTo(packageView.snp.top).offset(12)
            make.left.equalTo(packageView.snp.right).offset(-24)
            make.size.equalTo(CGSize(width: 40, height: 19))
        }
        
        //预约
        orderView = setOrderView()
        
        addSubview(orderView)
        
        orderView.snp.makeConstraints { (make) in
            make.top.equalTo(gifImageView.snp.bottom).offset(20)
            make.centerX.equalTo(self.snp.centerX)
            make.size.equalTo(CGSize(width: 70, height: 90))
        }
        
        //个性化
        personalView = setPersonalView()
        
        addSubview(personalView)
        
        personalView.snp.makeConstraints { (make) in
            make.top.equalTo(gifImageView.snp.bottom).offset(20)
            make.right.equalTo(self.snp.right).offset(-30.scalValue)
            make.size.equalTo(CGSize(width: 70.scalValue, height: 90.scalValue))
        }
        
        //底部icon
        let bottomImageView = UIImageView(image: ESPackageAsserts.bundleImage(named: "package_bottom"))
        addSubview(bottomImageView)
        
        if ScreenHeight == 812 {//适配iPhone X
            bottomImageView.snp.makeConstraints { (make) in
                make.bottom.equalTo(self.snp.bottom).offset(-(BOTTOM_SAFEAREA_HEIGHT + 28))
                make.centerX.equalTo(self.snp.centerX)
                make.size.equalTo(CGSize(width: 27.scalValue, height: 27.scalValue))
            }
            
            personalView.snp.remakeConstraints({ (make) in
                make.bottom.equalTo(bottomImageView.snp.top).offset(-22.scalValue)
                make.right.equalTo(self.snp.right).offset(-30.scalValue)
                make.size.equalTo(CGSize(width: 70.scalValue, height: 90.scalValue))
            })
            
            
            orderView.snp.remakeConstraints({ (make) in
                make.bottom.equalTo(bottomImageView.snp.top).offset(-22.scalValue)
                make.centerX.equalTo(self.snp.centerX)
                make.size.equalTo(CGSize(width: 70, height: 90))
            })
            
            packageView.snp.remakeConstraints { (make) in
                make.bottom.equalTo(bottomImageView.snp.top).offset(-22.scalValue)
                make.left.equalTo(30.scalValue)
                make.size.equalTo(CGSize(width: 70, height: 90))
            }
            
            let backView = UIControl()
            self.addSubview(backView)
            
            backView.snp.makeConstraints({ (make) in
                make.top.equalTo(yellowImageView.snp.bottom)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(packageView.snp.top)
            })
            backView.addSubview(gifImageView)
            gifImageView.snp.remakeConstraints { (make) in
                make.center.equalTo(backView.snp.center)
                make.size.equalTo(CGSize(width: 196.scalValue, height: 253.scalValue))
            }
            
        } else {
            bottomImageView.snp.makeConstraints { (make) in
                make.top.equalTo(personalView.snp.bottom).offset(22.scalValue)
                make.centerX.equalTo(self.snp.centerX)
                make.size.equalTo(CGSize(width: 27.scalValue, height: 27.scalValue))
            }
        }
        
        bottomImageView.isHidden = true
    }
    
    @objc func tapMethod(_ tap:UITapGestureRecognizer){
        if let containerVC = self.containerVC {
            containerVC.orderButtonClick()
        }
    }
    
    func setContainerAction(_ target:ESPackageMainViewController){
        
        self.containerVC = target
        
        let tap = UITapGestureRecognizer(target: target, action: #selector(target.orderButtonClick))
        orderView.addGestureRecognizer(tap)
        
        let tap1 = UITapGestureRecognizer(target: target, action: #selector(target.packageButtonClick))
        packageView.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: target, action: #selector(target.personalButtonClick))
        personalView.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: target, action: #selector(target.packageButtonClick))
        yellowImageView.addGestureRecognizer(tap3)
    }
    //MARK: - Action
    @objc func buttonClick(_ button:UIButton){
        
        if let containerVC = self.containerVC {
            
            switch button.tag {
            case 100:
                containerVC.packageButtonClick()
                break
            case 101:
                containerVC.personalButtonClick()
                break
            case 102:
                containerVC.orderButtonClick()
                break
            default:
                break
            }
        }
    }
    
    //MARK: - setter
    private func setOrderView()->ESPackageButtonView {
        let button = ESPackageButtonView()
        button.setViewData(ESPackageAsserts.bundleImage(named: "package_appoint"), text: "预约")
        return button
    }
    
    private func setPackageView()->ESPackageButtonView {
        let button = ESPackageButtonView()
        button.setViewData(ESPackageAsserts.bundleImage(named: "package_package"), text: "套餐")
        return button
    }
    
    private func setPersonalView()->ESPackageButtonView {
        let button = ESPackageButtonView()
        button.setViewData(ESPackageAsserts.bundleImage(named: "package_personal"), text: "个性化")
        return button
    }

    
    private func customButton(_ title:String)->UIButton{
        let button = UIButton()
        button.setTitleColor(ESColor.color(sample: .mainTitleColorB), for: .normal)
        button.titleLabel?.font = ESFont.font(name: .regular, size: 15.scalValue)
        button.setTitle(title, for: .normal)
        
        return button
    }
    
    private func customLabel(_ text:String)->UILabel{
        let label = UILabel()
        label.textColor = ESColor.color(sample: .subTitleColorC)
        label.font = ESFont.font(name: .regular, size: 10.scalValue)
        label.text = text
        
        return label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
