//
//  ESProProjectRejectedView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/9.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//  消费者项目列表 - 预约审核未通过view

import UIKit

class ESProProjectListRejectedView: UIView {
    
    init() {
        super.init(frame: .zero)
        setUpView()
        addConstraints()
        
    }
    
    func updateView(reason: String) {
        reasonContent.text = reason
    }
    
    func updateView(title: String) {
        reasonTitle.text = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.layer.cornerRadius = 3.0
        self.layer.masksToBounds = true
        self.backgroundColor = ESColor.color(hexColor: 0xFFF5E5, alpha: 1.0)
        self.addSubview(reasonTitle)
        self.addSubview(reasonContent)
    }
    
    private func addConstraints() {
        reasonTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(16.5)
        }
        reasonContent.snp.makeConstraints { (make) in
            make.top.equalTo(reasonTitle.snp.bottom).offset(8)
            make.left.equalTo(reasonTitle)
            make.right.equalTo(reasonTitle)
            make.bottom.equalToSuperview().offset(-13).priority(250)
            make.height.greaterThanOrEqualTo(16)
        }
    }
    
    private lazy var reasonTitle: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(hexColor: 0xFF9A02, alpha: 1.0)
        label.font = ESFont.font(name: .regular, size: 12.0)
        return label
    }()
    
    lazy var reasonContent: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(hexColor: 0xFF9A02, alpha: 1.0)
        label.font = ESFont.font(name: .regular, size: 12.0)
        label.numberOfLines = 0
        return label
    }()
}
