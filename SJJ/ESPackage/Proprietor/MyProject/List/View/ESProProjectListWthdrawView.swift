//
//  ESProProjectListWthdrawView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/9.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESProProjectListWthdrawViewDelegate: NSObjectProtocol {
    func withdrawClick()
}

class ESProProjectListWthdrawView: UIView {

    weak var delegate: ESProProjectListWthdrawViewDelegate?
    
    init(delegate: ESProProjectListWthdrawViewDelegate?) {
        super.init(frame: .zero)
        self.delegate = delegate
        setUpView()
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(content: String, amount: Double, showButton: Bool) {
        titleLabel.text = content
        amountLabel.text = String(format: "¥ %.2f", amount)
        
        amountTitle.isHidden = !showButton
        amountLabel.isHidden = !showButton
        withdrawBtn.isHidden = !showButton
    }
    
    private func setUpView() {
        layer.cornerRadius = 3.0
        layer.masksToBounds = true
        backgroundColor = ESColor.color(sample: .backgroundView)
        addSubview(titleLabel)
        addSubview(amountTitle)
        addSubview(amountLabel)
        addSubview(withdrawBtn)
    }
    
    @objc private func withdrawBtnClick() {
        delegate?.withdrawClick()
    }
    
    private func addConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(13)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.height.greaterThanOrEqualTo(10)
        }
        amountTitle.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(19.5)
            make.left.equalTo(titleLabel)
            make.height.equalTo(16.5)
            make.width.equalTo(49)
            make.bottom.equalToSuperview().offset(-18.5)
        }
        amountTitle.setContentHuggingPriority(UILayoutPriority(249), for: .vertical)
        amountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(amountTitle.snp.right).offset(8)
            make.height.equalTo(18.5)
            make.right.equalTo(withdrawBtn.snp.left).offset(-8)
            make.centerY.equalTo(amountTitle)
        }
        withdrawBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-13.5)
            make.width.equalTo(73)
            make.centerY.equalTo(amountTitle)
            make.height.equalTo(24)
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 12.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var amountTitle: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 12.0)
        label.textColor = ESColor.color(sample: .subTitleColorB)
        label.text = "当前余额"
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .medium, size: 13.0)
        label.textColor = ESColor.color(hexColor: 0xFF9A02, alpha: 1.0)
        label.text = "当前余额"
        return label
    }()
    
    private lazy var withdrawBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("申请退款", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = ESColor.color(sample: .buttonBlue)
        btn.titleLabel?.font = ESFont.font(name: .regular, size: 12.0)
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(ESProProjectListWthdrawView.withdrawBtnClick), for: .touchUpInside)
        return btn
    }()

}
