//
//  ESDesProjectCell.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

protocol ESDesProjectCellDelegate: ESTableViewCellProtocol, NSObjectProtocol {
    
    /// 点击电话
    ///
    /// - Parameter phone: 电话号码
    func phoneTextClick(phone: String)
}

class ESDesProjectCell: UITableViewCell {
    
    weak var delegate: ESDesProjectCellDelegate?
    private var itemModel: ESDesProjectListViewModel = ESDesProjectListViewModel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = ESColor.color(hexColor: 0xFFFFFF, alpha: 1.0)
        self.contentView.addSubview(topView)
        tagBackView.addSubview(tagLabel)
        self.contentView.addSubview(tagBackView)
        self.contentView.addSubview(statusLabel)
        self.contentView.addSubview(separatorLine)
        self.contentView.addSubview(consumerNameTitle)
        self.contentView.addSubview(consumerNameContent)
        self.contentView.addSubview(phoneTitle)
        self.contentView.addSubview(phoneContent)
        self.contentView.addSubview(addressTitle)
        self.contentView.addSubview(addressContent)
        self.contentView.addSubview(projectIdLabel)
        self.contentView.addSubview(orderTimeLabel)
        
        setConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(index: Int) {
        delegate?.getViewModel(index: index, section: 0, cellId: "ESDesProjectCell", viewModel: itemModel)
        
        /// 设置标签
        tagLabel.text = itemModel.tagText ?? ""
        tagLabel.textColor = itemModel.tagTextColor ?? UIColor.clear
        tagBackView.backgroundColor = itemModel.tagBgColor ?? UIColor.clear
        
        /// 设置项目状态
        statusLabel.text = itemModel.statusText ?? ""
        statusLabel.textColor = itemModel.statusColor ?? UIColor.clear
        
        /// 业主姓名
        consumerNameContent.text = itemModel.consumerName ?? "--"
        
        /// 联系电话
        if let phone = itemModel.phone {
            phoneContent.setTitleColor(ESColor.color(sample: .buttonBlue), for: .normal)
            phoneContent.setTitle(phone, for: .normal)
            phoneContent.isEnabled = true
        }else {
            phoneContent.setTitleColor(ESColor.color(sample: .mainTitleColor), for: .normal)
            phoneContent.setTitle("--", for: .normal)
            phoneContent.isEnabled = false
        }
        
        /// 项目地址
        addressContent.text = itemModel.address ?? "--"
        
        /// 项目编号
        let projectId = itemModel.projectId ?? "--"
        projectIdLabel.text = String.init(format: "项目编号: %@", projectId)
        
        /// 预约时间
        let orderTime = itemModel.orderTime ?? "--"
        orderTimeLabel.text = String.init(format: "预约时间: %@", orderTime)
    }

    @objc private func phoneLabelClick(button: UIButton) {
        if ESStringUtil.isEmpty(itemModel.phone) {
            return
        }
        if let text = itemModel.phone {
            
            delegate?.phoneTextClick(phone: text)
        }
    }
    
    /// 设置约束
    private func setConstraint() {
        topView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(10)
        }
        tagBackView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(topView.snp.bottom).offset(12)
            make.width.greaterThanOrEqualTo(50)
            let height = CGFloat(23.0)
            make.height.equalTo(height.scalValue)
        }
        tagLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(10)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.height.equalToSuperview()
        }
        statusLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(50)
            make.centerY.equalTo(tagLabel.snp.centerY)
        }
        separatorLine.snp.makeConstraints { (make) in
            make.top.equalTo(tagLabel.snp.bottom).offset(12)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        consumerNameTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(separatorLine.snp.bottom).offset(18)
            make.width.equalTo(53)
            make.height.equalTo(19)
        }
        consumerNameContent.snp.makeConstraints { (make) in
            make.left.equalTo(consumerNameTitle.snp.right).offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(consumerNameTitle)
            make.centerY.equalTo(consumerNameTitle)
        }
        phoneTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(consumerNameTitle.snp.bottom).offset(10)
            make.width.equalTo(53)
            make.height.equalTo(19)
        }
        phoneContent.snp.makeConstraints { (make) in
            make.left.equalTo(phoneTitle.snp.right).offset(15)
            make.width.greaterThanOrEqualTo(30)
            make.height.equalTo(phoneTitle.snp.height)
            make.centerY.equalTo(phoneTitle.snp.centerY)
        }
        addressTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(phoneTitle.snp.bottom).offset(10)
            make.width.equalTo(53)
            make.height.equalTo(19)
        }
        addressContent.snp.makeConstraints { (make) in
            make.left.equalTo(addressTitle.snp.right).offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(addressTitle)
            make.centerY.equalTo(addressTitle)
        }
        projectIdLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(addressTitle.snp.bottom).offset(18)
            make.width.greaterThanOrEqualTo(100)
            make.height.equalTo(17)
            make.bottom.equalToSuperview().offset(-13).priority(500)
        }
        orderTimeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(projectIdLabel)
            make.centerY.equalTo(projectIdLabel)
            make.width.greaterThanOrEqualTo(100)
        }
    }
    
    /// 空白view
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        return view
    }()
    
    /// 项目标签
    private lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .medium, size: 12)
        label.textAlignment = .center
        return label
    }()
    
    /// 项目标签背景
    lazy var tagBackView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2.0
        view.layer.masksToBounds = true
        return view
    }()
    
    /// 项目状态
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .medium, size: 13.0)
        label.textAlignment = .right
        return label
    }()
    
    /// 分界线
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .separatorLine)
        return view
    }()
    
    /// 业主姓名title
    private lazy var consumerNameTitle: UILabel = {
        let label = UILabel()
        label.text = "业主姓名"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .titleBlack)
        return label
    }()
    
    /// 业主姓名content
    private lazy var consumerNameContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    /// 联系电话title
    private lazy var phoneTitle: UILabel = {
        let label = UILabel()
        label.text = "联系电话"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .titleBlack)
        return label
    }()
    
    /// 联系电话content
    private lazy var phoneContent: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = ESFont.font(name: .regular, size: 13.0)
        button.titleLabel?.textColor = ESColor.color(sample: .buttonBlue)
        button.addTarget(self, action: #selector(ESDesProjectCell.phoneLabelClick(button:)), for: .touchUpInside)
        return button
    }()
    
    /// 项目地址title
    private lazy var addressTitle: UILabel = {
        let label = UILabel()
        label.text = "项目地址"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .titleBlack)
        return label
    }()
    
    /// 项目地址content
    private lazy var addressContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    /// 项目编号
    private lazy var projectIdLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 12.0)
        label.textColor = ESColor.color(sample: .textGray)
        return label
    }()
    
    /// 预约时间
    private lazy var orderTimeLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 12.0)
        label.textColor = ESColor.color(sample: .textGray)
        label.textAlignment = .right
        return label
    }()
}
