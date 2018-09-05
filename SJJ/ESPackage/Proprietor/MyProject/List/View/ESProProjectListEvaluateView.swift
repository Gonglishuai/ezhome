//
//  ESProProjectListEvaluateView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/1.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESProProjectListEvaluateViewDelegate: NSObjectProtocol {
    func goToEvaluate()
}

class ESProProjectListEvaluateView: UIView {
    weak var delegate: ESProProjectListEvaluateViewDelegate?
    
    init(delegate: ESProProjectListEvaluateViewDelegate?) {
        super.init(frame: .zero)
        self.delegate = delegate
        setUpView()
        addConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(title: String, buttonTitle: String) {
        titleLabel.text = title
        evaluateBtn.setTitle(buttonTitle, for: .normal)
    }
    
    private func setUpView() {
        layer.cornerRadius = 3.0
        layer.masksToBounds = true
        backgroundColor = ESColor.color(sample: .backgroundView)
        addSubview(titleLabel)
        addSubview(evaluateBtn)
    }
    
    @objc private func evaluateClick() {
        delegate?.goToEvaluate()
    }
    
    private func addConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(16.5)
        }
        evaluateBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-13.5)
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(24)
            make.width.equalTo(73)
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 12.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.text = "您的装修项目已完成，快去评价一下吧~"
        return label
    }()
    
    private lazy var evaluateBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = ESColor.color(sample: .buttonBlue)
        btn.titleLabel?.font = ESFont.font(name: .regular, size: 12.0)
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.setTitle("去评价", for: .normal)
        btn.addTarget(self, action: #selector(evaluateClick), for: .touchUpInside)
        return btn
    }()
}
