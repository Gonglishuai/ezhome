//
//  ESFaceToFaceView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/14.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESFaceToFaceViewDelegate: NSObjectProtocol {
    func completeBtnClick()
    func refreshBtnClick()
}
class ESFaceToFaceView: UIView {
    private weak var delegate: ESFaceToFaceViewDelegate?
    
    init(delegate: ESFaceToFaceViewDelegate?) {
        super.init(frame: .zero)
        self.delegate = delegate
        self.backgroundColor = ESColor.color(sample: .buttonBlue)
        addSubviews()
        setConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(_ qrImg: UIImage?, _ amount: Double, _ payImg: UIImage?, _ payText: String?) {
        qrImageView.image = qrImg
        let amountStr = String(format: "¥ %.2f", amount)
        amountLabel.text = amountStr
        paywayImgView.image = payImg
        paywayLabel.text = (payText != nil) ? payText! + "支付" : ""
    }
    
    @objc private func donBtnClick() {
        delegate?.completeBtnClick()
    }
    
    @objc private func freshBtnClick() {
        delegate?.refreshBtnClick()
    }
    
    private func addSubviews() {
        addSubview(topView)
        addSubview(doneBtn)
    }
    
    private func setConstraints() {
        topView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(17)
            make.right.equalToSuperview().offset(-17)
            make.height.greaterThanOrEqualTo(300)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
        qrImageView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(219)
            make.width.equalTo(qrImageView.snp.height).multipliedBy(1.0)
            make.centerX.equalToSuperview()
        }
        amountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(qrImageView.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(48.5)
        }
        refreshBtn.snp.makeConstraints { (make) in
            make.top.equalTo(amountLabel.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(98)
            make.height.equalTo(41)
        }
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(refreshBtn.snp.bottom)
            make.height.equalTo(0.5)
        }
        bottomTitle.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom)
            make.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().priority(800)
            make.height.equalTo(59)
        }
        paywayLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(bottomTitle)
            make.height.equalTo(bottomTitle)
            make.width.greaterThanOrEqualTo(20)
        }
        paywayImgView.snp.makeConstraints { (make) in
            make.right.equalTo(paywayLabel.snp.left).offset(-8)
            make.width.height.equalTo(33)
            make.centerY.equalTo(paywayLabel)
        }
        doneBtn.snp.makeConstraints { (make) in
            make.height.equalTo(44.scalValue)
            make.top.equalTo(topView.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(17)
            make.right.equalToSuperview().offset(-17)
        }
    }
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        view.addSubview(titleLabel)
        view.addSubview(qrImageView)
        view.addSubview(amountLabel)
        view.addSubview(refreshBtn)
        view.addSubview(lineView)
        view.addSubview(bottomTitle)
        view.addSubview(paywayImgView)
        view.addSubview(paywayLabel)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "扫二维码，向我付款"
        label.font = ESFont.font(name: .regular, size: 16.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var qrImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        let qr_error = ESPackageAsserts.bundleImage(named: "qrcode_error")
        imgView.image = qr_error
        return imgView
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .medium, size: 18.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var refreshBtn: UIButton = {
        let btn = UIButton()
        let img = ESPackageAsserts.bundleImage(named: "package_face_refresh")
        btn.setImage(img, for: .normal)
        btn.setTitle("  刷新二维码", for: .normal)
        btn.setTitleColor(ESColor.color(sample: .buttonBlue), for: .normal)
        btn.titleLabel?.font = ESFont.font(name: .regular, size: 14.0)
        btn.addTarget(self, action: #selector(ESFaceToFaceView.freshBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .separatorLine)
        return view
    }()
    
    private lazy var bottomTitle: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = ESFont.font(name: .regular, size: 14.0)
        label.text = "收款方式"
        return label
    }()
    
    private lazy var paywayImgView: UIImageView = {
        let imgView = UIImageView()
        return imgView
    }()
    
    private lazy var paywayLabel: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = ESFont.font(name: .regular, size: 14.0)
        label.textAlignment = .right
        return label
    }()
    
    lazy var doneBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.white
        btn.isEnabled = false
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 8.0
        btn.setTitle("完成", for: .normal)
        btn.setTitleColor(ESColor.color(sample: .buttonBlue), for: .normal)
        btn.setTitleColor(ESColor.color(sample: .separatorLine), for: .disabled)
        btn.titleLabel?.font = ESFont.font(name: .regular, size: 17.0)
        btn.addTarget(self, action: #selector(ESFaceToFaceView.donBtnClick), for: .touchUpInside)
        return btn
    }()
}
