//
//  ESProProjectListPayView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/9.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//  消费者项目列表 - 支付view

import UIKit

protocol ESProProjectListPayViewDelegate: NSObjectProtocol {
    func payOrderDetail()
    func goToPay()
}

class ESProProjectListPayView: UIView {
    
    weak var delegate: ESProProjectListPayViewDelegate?
    
    init(delegate: ESProProjectListPayViewDelegate?) {
        super.init(frame: .zero)
        self.delegate = delegate
        setUpView()
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(amount: Double) {
        amountLabel.text = String(format: "¥ %.2f", amount)
    }
    
    @objc private func detailBtnClick() {
        delegate?.payOrderDetail()
    }
    
    @objc private func payBtnClick() {
        delegate?.goToPay()
    }
    
    private func setUpView() {
        layer.cornerRadius = 3.0
        layer.masksToBounds = true
        backgroundColor = ESColor.color(sample: .backgroundView)
        addSubview(payTitle)
        addSubview(amountLabel)
        addSubview(detailBtn)
        addSubview(payBtn)
    }
    
    private func addConstraints() {
        payTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(14)
            make.height.equalTo(16.5)
            make.width.greaterThanOrEqualTo(55)
        }
        amountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(payTitle.snp.bottom).offset(11)
            make.left.equalTo(payTitle)
            make.height.equalTo(22.5)
            make.right.equalTo(detailBtn.snp.left).offset(-8)
            make.bottom.equalToSuperview().offset(-15).priority(800)
        }
        payBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-13.5)
            make.height.equalTo(24)
            make.width.equalTo(73)
            make.centerY.equalTo(amountLabel)
        }
        detailBtn.snp.makeConstraints { (make) in
            make.right.equalTo(payBtn.snp.left).offset(-10)
            make.height.equalTo(payBtn)
            make.width.equalTo(payBtn)
            make.centerY.equalTo(payBtn)
        }
    }
    
    private lazy var payTitle: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.font = ESFont.font(name: .regular, size: 12.0)
        label.text = "待支付金额"
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .buttonRed)
        label.font = ESFont.font(name: .medium, size: 16.0)
        return label
    }()
    
    private lazy var detailBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("查看详情", for: .normal)
        btn.setTitleColor(ESColor.color(sample: .subTitleColorA), for: .normal)
        btn.backgroundColor = ESColor.color(sample: .separatorLine)
        btn.titleLabel?.font = ESFont.font(name: .regular, size: 12.0)
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(ESProProjectListPayView.detailBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var payBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("立即支付", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = ESColor.color(sample: .buttonBlue)
        btn.titleLabel?.font = ESFont.font(name: .regular, size: 12.0)
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(ESProProjectListPayView.payBtnClick), for: .touchUpInside)
        return btn
    }()
}
