//
//  ESCreateProjectFailView.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/15.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

public class ESAlertView: UIView {
    
    private lazy var backHUD = UIView()
    private var knowBlock:(()->Void)?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        self.backgroundColor = UIColor.clear
        
        backHUD.backgroundColor = UIColor.black
        backHUD.alpha = 0
        backHUD.frame = bounds
        self.addSubview(backHUD)
        self.addSubview(self.messageView)
        self.addSubview(self.closeBtn)
        messageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(190)
            make.size.equalTo(CGSize(width: 242, height: 290))
        }
        closeBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(messageView.snp.bottom).offset(8)
            make.width.height.equalTo(50)
        }
    }
    
    
    private lazy var icon = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var subTitleLabel = UILabel()
    private lazy var knowButton = UIButton()
    
    private lazy var messageView: UIView = {
        
        var containView = UIView()
        containView.backgroundColor = UIColor.white
        
        icon.image  = ESPackageAsserts.bundleImage(named: "create_project_fail")
        
        containView.addSubview(icon)
        icon.snp.makeConstraints { (make) in
            make.top.equalTo(45)
            make.centerX.equalTo(containView.snp.centerX)
            make.size.equalTo(CGSize(width: 96, height: 69))
        }
        
        containView.addSubview(titleLabel)
        titleLabel.textColor = ESColor.color(sample: .mainTitleColor)
        titleLabel.font = ESFont.font(name: ESFont.ESFontName.medium, size: 16)
        titleLabel.text = "创建失败"
        titleLabel.textAlignment = .center
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(icon.snp.bottom).offset(18)
            make.centerX.equalTo(containView.snp.centerX)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        containView.addSubview(subTitleLabel)
        subTitleLabel.textColor = ESColor.color(sample: .textGray)
        subTitleLabel.font = ESFont.font(name: ESFont.ESFontName.regular, size: 12)
        subTitleLabel.text = "建议核对信息是否正确或再次创建"
        subTitleLabel.textAlignment = .center
        subTitleLabel.numberOfLines = 0
        subTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalTo(containView.snp.centerX)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        containView.addSubview(knowButton)
        knowButton.backgroundColor = ESColor.color(sample: .buttonBlue)
        knowButton.setTitleColor(UIColor.white, for: .normal)
        knowButton.setTitle("知道了", for: .normal)
        knowButton.titleLabel?.font = ESFont.font(name: ESFont.ESFontName.regular, size: 16)
        knowButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(-28)
            make.centerX.equalTo(containView.snp.centerX)
            make.size.equalTo(CGSize(width: 200, height: 40))
        }
        
        knowButton.addTarget(self, action: #selector(knownButtonClick), for: UIControlEvents.touchUpInside)
        
        knowButton.layer.cornerRadius = 20
        knowButton.layer.masksToBounds = true
        
        containView.layer.cornerRadius = 5
        containView.layer.masksToBounds = true
        return containView
    }()
    
    private lazy var closeBtn: UIButton = {
        let btn = UIButton()
        let img = ESPackageAsserts.bundleImage(named: "personal_qr_close")
        btn.isHidden = true
        btn.setImage(img, for: .normal)
        btn.addTarget(self, action: #selector(ESAlertView.closeBtnClick), for: .touchUpInside)
        return btn
    }()
    
    @objc func closeBtnClick() {
        hiddenViewForCreatProjectFail()
    }
    
    func knownButtonClickBlock(_ konw: @escaping (()->Void)){
        self.knowBlock = konw
        
    }
    
    @objc func knownButtonClick() {
        hiddenViewForCreatProjectFail()
        if let block = knowBlock {
            block()
        }
        print("知道了")
    }
    
    
    /// 设置errorView的元素值
    ///
    /// - Parameters:
    ///   - image: UIImage
    ///   - mainTitle: String
    ///   - subTitle: String
    ///   - buttonTitle: String  defaultValue = "知道了"
    public  func setShowingElement(_ image:UIImage, mainTitle:String="", subTitle:String="", buttonTitle:String = "知道了", showClose: Bool = false){
        icon.image = image
        titleLabel.text = mainTitle
        subTitleLabel.text = subTitle
        subTitleLabel.sizeToFit()

        knowButton.setTitle(buttonTitle, for: .normal)
        closeBtn.isHidden = !showClose
    }
    
   public func showViewAlterView() {
        let window = UIApplication.shared.keyWindow
        self.frame = (window?.bounds)!
        window?.addSubview(self)
        
        messageView.alpha = 0
        closeBtn.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.backHUD.alpha = 0.3
            self.messageView.alpha = 1
            self.closeBtn.alpha = 0.8
        }) { (sucess) in
        }
    
        let animation = ESSpringAnimation(fromValue: NSNumber(value:1.4), toValue: NSNumber(value: 1.0), keyPath: "transform.scale")
        animation.damping = 30
        animation.stiffness = 14
        animation.mass = 1
        messageView.layer.add(animation, forKey: animation.keyPath)
        messageView.transform = CGAffineTransform(translationX: 1.0, y: 1.0)
        closeBtn.layer.add(animation, forKey: animation.keyPath)
        closeBtn.transform = CGAffineTransform(translationX: 1.0, y: 1.0)
    }
    
  public  func hiddenViewForCreatProjectFail() {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
            self.backHUD.alpha = 0
            self.messageView.alpha = 0
            self.closeBtn.alpha = 0
        }) { (sucess) in
        }
    
        let animation = ESSpringAnimation(fromValue: NSNumber(value:1.0), toValue: NSNumber(value: 0.7), keyPath: "transform.scale")
        animation.damping = 11
        animation.stiffness = 11
        animation.mass = 1
        messageView.layer.add(animation, forKey: animation.keyPath)
        messageView.transform = CGAffineTransform(translationX: 0.7, y: 0.7)
        closeBtn.layer.add(animation, forKey: animation.keyPath)
        closeBtn.transform = CGAffineTransform(translationX: 0.7, y: 0.7)
        self.perform(#selector(removeFromSuperview), with: nil, afterDelay: 0.2)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
