//
//  ESDesProjectDeliveryView.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/27.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

protocol ESProjectDeliveryDelegate: NSObjectProtocol {
    func detailClick(index: Int)
    func quoteClick(index: Int)
}

class ESProjectDeliveryView: UIView {

    private var index: Int = 0
    private weak var delegate: ESProjectDeliveryDelegate?
    private var detailSeparRight: Constraint?
    private var detailSuperRight: Constraint?
    
    init(delegate: ESProjectDeliveryDelegate?) {
        super.init(frame: CGRect.zero)
        self.delegate = delegate
        addSubViews()
        setConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(index: Int, title: String?, imgUrl: String?, showQuote: Bool, pkgName: String?, isFinally: Bool) {
        self.index = index
        
        let num = ESStringUtil.getChineseNum(number: index + 1)
        let text = String(format: "%@", title ?? "")
        deliveryName.text = "方案\(num): \(text)"
        
        let url = URL(string: imgUrl ?? "")
        let options: KingfisherOptionsInfo = [.transition(.fade(1.0))]
        deliveryImgView.kf.setImage(with: url, placeholder: ESPackageAsserts.bundleImage(named: "default_case"), options: options, progressBlock: nil, completionHandler: nil)
        finallyAlert.isHidden = !isFinally
        
        quoteBtn.isHidden = !showQuote
        quoteBtn.isEnabled = showQuote
        if showQuote {
            detailSeparRight?.activate()
        } else {
            detailSeparRight?.deactivate()
        }
        
        if let name = pkgName, !name.isEmpty {
            pkgNameView.isHidden = false
            pkgNameLabel.text = name
        } else {
            pkgNameView.isHidden = true
            pkgNameLabel.text = ""
        }
    }
    
    private func addSubViews() {
        addSubview(deliveryName)
        addSubview(pkgNameView)
        addSubview(backView)
    }
    
    private func setConstraint() {
        deliveryName.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20).priority(800)
            make.right.equalTo(pkgNameView.snp.left).offset(-8)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(18)
        }
        pkgNameView.snp.makeConstraints { (make) in
            make.centerY.equalTo(deliveryName)
            make.right.equalToSuperview().offset(-20)
        }
        pkgNameLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.height.equalTo(17)
        }
        pkgNameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        backView.snp.makeConstraints { (make) in
            make.top.equalTo(deliveryName.snp.bottom).offset(13)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-18)
        }
        
        let scale = 670 / 376.6
        deliveryImgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(deliveryImgView.snp.height).multipliedBy(scale)
        }
        finallyAlert.snp.makeConstraints { (make) in
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.center.equalToSuperview()
        }
        finallyAlertLable.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        separatorLine.snp.makeConstraints { (make) in
            make.centerY.equalTo(detailBtn)
            make.height.equalTo(9)
            make.width.equalTo(1.5)
            make.centerX.equalToSuperview()
        }
        
        let height = CGFloat(50)
        detailBtn.snp.makeConstraints { (make) in
            make.top.equalTo(deliveryImgView.snp.bottom)
            make.left.equalToSuperview()
            self.detailSeparRight = make.right.equalTo(separatorLine.snp.left).constraint
            self.detailSuperRight = make.right.greaterThanOrEqualToSuperview().priority(700).constraint
            make.bottom.equalToSuperview().priority(800)
            make.height.equalTo(height.scalValue)
        }
        quoteBtn.snp.makeConstraints { (make) in
            make.top.equalTo(deliveryImgView.snp.bottom)
            make.left.equalTo(separatorLine.snp.right)
            make.right.equalToSuperview()
            make.height.equalTo(detailBtn)
        }
    }
    
    @objc private func detailBtnClick(sender: UIButton) {
        delegate?.detailClick(index: self.index)
    }
    
    @objc private func quoteBtnClick(sender: UIButton) {
        delegate?.quoteClick(index: self.index)
    }
    
    private lazy var deliveryName: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = ESFont.font(name: .medium, size: 14.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    private lazy var pkgNameView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 9
        view.layer.borderWidth = 1
        view.layer.borderColor = ESColor.color(sample: .buttonBlue).cgColor
        view.addSubview(pkgNameLabel)
        return view
    }()
    
    private lazy var pkgNameLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .medium, size: 11.0)
        label.textColor = ESColor.color(sample: .buttonBlue)
        return label
    }()
    
    private lazy var backView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.5
        view.layer.borderColor = ESColor.color(sample: .separatorLine).cgColor
        view.backgroundColor = UIColor.white
        view.addSubview(deliveryImgView)
        view.addSubview(separatorLine)
        view.addSubview(detailBtn)
        view.addSubview(quoteBtn)
        return view
    }()
    
    private lazy var deliveryImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.addSubview(finallyAlert)
        return imgView
    }()
    
    private lazy var detailBtn: UIButton = {
        let button = UIButton()
        button.setTitle("查看详情", for: .normal)
        button.setTitleColor(ESColor.color(sample: .buttonBlue), for: .normal)
        button.backgroundColor = UIColor.white
        button.titleLabel?.font = ESFont.font(name: .medium, size: 13.0)
        button.addTarget(self, action: #selector(ESProjectDeliveryView.detailBtnClick(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .separatorLine)
        return view
    }()
    
    private lazy var quoteBtn: UIButton = {
        let button = UIButton()
        button.setTitle("查看方案报价", for: .normal)
        button.setTitleColor(ESColor.color(sample: .buttonBlue), for: .normal)
        button.backgroundColor = UIColor.white
        button.titleLabel?.font = ESFont.font(name: .medium, size: 13.0)
        button.addTarget(self, action: #selector(ESProjectDeliveryView.quoteBtnClick(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var finallyAlert: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = ESColor.color(hexColor: 0x000000, alpha: 0.5)
        view.layer.cornerRadius = 4
        view.addSubview(finallyAlertLable)
        return view
    }()
    
    private lazy var finallyAlertLable: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = ESFont.font(name: .medium, size: 13.0)
        label.textAlignment = .center
        label.text = "最终方案"
        return label
    }()
}
