//
//  ESAddBrandSelectBrandsView.swift
//  Consumer
//
//  Created by zhang dekai on 2018/2/27.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESAddBrandSelectBrandsView: UIView {

    var selectBrandsBlock:((_ left:Bool)->Void)?

    private lazy var leftButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(ESColor.color(sample: .mainTitleColor), for: .normal)
        button.titleLabel?.font = ESFont.font(name: .regular, size: 13)
        return button
    }()
    
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(ESColor.color(sample: .mainTitleColor), for: .normal)
        button.titleLabel?.font = ESFont.font(name: .regular, size: 13)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(leftButton)
        leftButton.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
            make.size.equalTo(CGSize(width: (ScreenWidth / 2) - 0.5 , height: 43.5.scalValue))
        }
        
        addSubview(rightButton)
        rightButton.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.size.equalTo(CGSize(width: (ScreenWidth / 2) - 0.5 , height: 43.5.scalValue))
        }
        
        let line = UIView()
        line.backgroundColor = ESColor.color(hexColor: 0xECECEB, alpha: 1)
        addSubview(line)
        
        line.snp.makeConstraints { (make) in
            make.left.equalTo(leftButton.snp.right)
            make.top.equalTo(self.snp.top).offset(15.scalValue)
            make.size.equalTo(CGSize(width: 0.5 , height: 15.scalValue))
        }
        
        let line1 = UIView()
        line1.backgroundColor = ESColor.color(hexColor: 0xECECEB, alpha: 1)
        addSubview(line1)
        
        line1.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        leftButton.addTarget(self, action: #selector(leftButtonClick), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)

    }
    
    func setViewModel(){
        leftButton.setTitle("全部", for: .normal)
        rightButton.setTitle("类型", for: .normal)
    }
    
    func setRightButtonTitle(title:String){
        rightButton.setTitle(title, for: .normal)
    }
    func setleftButtonTitle(title:String){
        leftButton.setTitle(title, for: .normal)
    }
    
    //MARK: - Actions
    @objc func leftButtonClick(){
        if let block = selectBrandsBlock {
            block(true)
        }
    }
    
    @objc func rightButtonClick(){
        if let block = selectBrandsBlock {
            block(false)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
