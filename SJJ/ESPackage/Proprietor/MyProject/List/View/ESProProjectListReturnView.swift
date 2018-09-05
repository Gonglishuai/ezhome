//
//  ESProProjectListReturnView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/9.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//  消费者列表 - 退单信息view

import UIKit

protocol ESProProjectListReturnViewDelegate: NSObjectProtocol {
    
    /// 退单/退款详情
    func returnDetail()
}

class ESProProjectListReturnView: UIView {

    weak var delegate: ESProProjectListReturnViewDelegate?
    
    init(delegate: ESProProjectListReturnViewDelegate?) {
        super.init(frame: .zero)
        self.delegate = delegate
        setUpView()
        addConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(title: String, reason: String, buttonTitle: String) {
        titleLabel.text = title
        reasonLabel.text = reason
        detailBtn.setTitle(buttonTitle, for: .normal)
    }
    
    private func setUpView() {
        layer.cornerRadius = 3.0
        layer.masksToBounds = true
        backgroundColor = ESColor.color(sample: .backgroundView)
        addSubview(titleLabel)
        addSubview(reasonLabel)
        addSubview(detailBtn)
    }
    
    @objc private func detailBtnClick() {
        delegate?.returnDetail()
    }
    
    private func addConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(16.5)
        }
        detailBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-13.5)
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(24)
            make.width.equalTo(73)
        }
        reasonLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalTo(14)
            make.right.equalTo(detailBtn.snp.left).offset(-22.5)
            make.bottom.equalToSuperview().offset(-11).priority(800)
            make.height.greaterThanOrEqualTo(16.5)
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 12.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    private lazy var reasonLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 12.0)
        label.textColor = ESColor.color(sample: .subTitleColorB)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var detailBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = ESColor.color(sample: .buttonBlue)
        btn.titleLabel?.font = ESFont.font(name: .regular, size: 12.0)
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(ESProProjectListReturnView.detailBtnClick), for: .touchUpInside)
        return btn
    }()
}
