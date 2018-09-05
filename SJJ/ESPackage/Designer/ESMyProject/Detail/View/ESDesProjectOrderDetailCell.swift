//
//  ESDesProjectOrderDetailCell.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/21.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  设计师 - 预约明细

import UIKit

protocol ESDesProjectOrderDetailCellDelegate {
    
    /// 点击电话
    ///
    /// - Parameter phone: 电话号码
    func phoneTextClick(phone: String)
    
    /// 点击参考方案
    func solutionCaseClick()
}

class ESDesProjectOrderDetailCell: UITableViewCell, ESDesProjectDetailCellProtocol {
    
    weak var delegate: ESDesProjectDetailCellDelegate?
    private var itemModel = ESDesProjectOrderDetailViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = ESColor.color(sample: .backgroundView)
        
        addSubviews()
        setConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(index: Int, section: Int) {
        delegate?.getViewModel(index: index, section: section, cellId: "ESDesProjectOrderDetailCell", viewModel: itemModel)
        
        /// 设置标签
        tagLabel.text = itemModel.tag.text ?? ""
        tagLabel.textColor = itemModel.tag.textColor ?? UIColor.clear
        tagBackView.backgroundColor = itemModel.tag.bgColor ?? UIColor.clear
        
        /// 设置项目状态
        statusLabel.text = itemModel.status.text ?? ""
        statusLabel.textColor = itemModel.status.color ?? UIColor.clear
        
        /// 项目编号
        let projectId = ESStringUtil.isEmpty(itemModel.projectId) ? "--" : itemModel.projectId!
        projectIdLabel.text = String.init(format: "项目编号: %@", projectId)
        
        /// 预约时间
        let orderTime = ESStringUtil.isEmpty(itemModel.orderTime) ? "--" : itemModel.orderTime!
        orderTimeLabel.text = String.init(format: "预约时间: %@", orderTime)
        
        /// 业主姓名
        consumerNameContent.text = ESStringUtil.isEmpty(itemModel.consumerName) ? "--" : itemModel.consumerName
        
        /// 联系电话
        if let phone = itemModel.phone {
            phoneContent.textColor = ESColor.color(sample: .buttonBlue)
            phoneContent.text = phone
            phoneContent.isUserInteractionEnabled = true
        }else {
            phoneContent.textColor = ESColor.color(sample: .mainTitleColor)
            phoneContent.text = "--"
            phoneContent.isUserInteractionEnabled = false
        }
        
        /// 项目地址
        addressContent.text = ESStringUtil.isEmpty(itemModel.address) ? "--" : itemModel.address
        
        /// 小区名称
        communityContent.text = ESStringUtil.isEmpty(itemModel.communityName) ? "--" : itemModel.communityName
        
        /// 房屋类型
        houseTypeContent.text = ESStringUtil.isEmpty(itemModel.houseType) ? "--" : itemModel.houseType
        
        /// 建筑面积
        areaContent.text = ESStringUtil.isEmpty(itemModel.area) ? "--" : String(format: "%@㎡", itemModel.area!)
        
        /// 装修预算
        budgetContent.text = ESStringUtil.isEmpty(itemModel.budget) ? "--" : itemModel.budget
        
        /// 装修风格
        styleContent.text = ESStringUtil.isEmpty(itemModel.style) ? "--" : itemModel.style
        
        /// 户型
        roomTypeContent.text = ESStringUtil.isEmpty(itemModel.roomType) ? "--" : itemModel.roomType
        
        /// 参考方案
        if let solution = itemModel.solution, !solution.isEmpty {
            solutionContent.textColor = ESColor.color(sample: .buttonBlue)
            solutionContent.text = solution
            solutionContent.isUserInteractionEnabled = true
        }else {
            solutionContent.textColor = ESColor.color(sample: .subTitleColorA)
            solutionContent.text = "--"
            solutionContent.isUserInteractionEnabled = false
        }
        
        /// 备注说明
        remarkContent.text = ESStringUtil.isEmpty(itemModel.remark) ? "--" : itemModel.remark
    }
    
    // MARK: - 点击事件
    /// 点击联系电话
    ///
    /// - Parameter button: sender
    @objc private func phoneLabelClick() {
        if ESStringUtil.isEmpty(itemModel.phone) {
            return
        }
        if let text = itemModel.phone {
            
            delegate?.phoneTextClick(phone: text)
        }
    }
    
    /// 点击参考方案
    ///
    /// - Parameter button: sender
    @objc private func solutionLabelClick() {
        
        delegate?.solutionCaseClick()
    }
    
    // MARK: - 添加子View
    private func addSubviews() {
        self.contentView.addSubview(backView)
        
        tagBackView.addSubview(tagLabel)
        backView.addSubview(tagBackView)
        backView.addSubview(statusLabel)
        backView.addSubview(separatorLine)
        backView.addSubview(projectIdLabel)
        backView.addSubview(orderTimeLabel)
        backView.addSubview(consumerInfoBackView)
        backView.addSubview(decoInfoBackView)
        backView.addSubview(extraInfoBackView)
        
        consumerInfoBackView.addSubview(consumerNameTitle)
        consumerInfoBackView.addSubview(consumerNameContent)
        consumerInfoBackView.addSubview(phoneTitle)
        consumerInfoBackView.addSubview(phoneContent)
        consumerInfoBackView.addSubview(addressTitle)
        consumerInfoBackView.addSubview(addressContent)
        consumerInfoBackView.addSubview(communityTitle)
        consumerInfoBackView.addSubview(communityContent)
        
        decoInfoBackView.addSubview(houseTypeTitle)
        decoInfoBackView.addSubview(houseTypeContent)
        decoInfoBackView.addSubview(areaTitle)
        decoInfoBackView.addSubview(areaContent)
        decoInfoBackView.addSubview(budgetTitle)
        decoInfoBackView.addSubview(budgetContent)
        decoInfoBackView.addSubview(styleTitle)
        decoInfoBackView.addSubview(styleContent)
        decoInfoBackView.addSubview(roomTypeTitle)
        decoInfoBackView.addSubview(roomTypeContent)
        
        extraInfoBackView.addSubview(solutionTitle)
        extraInfoBackView.addSubview(solutionContent)
        extraInfoBackView.addSubview(remarkTitle)
        extraInfoBackView.addSubview(remarkContent)
    }
    
    // MARK: - 设置约束
    private func setConstraint() {
        backView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().priority(500)
            make.height.greaterThanOrEqualTo(100)
        }
        tagBackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(20)
            make.width.greaterThanOrEqualTo(42)
            make.height.equalTo(18)
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
            make.top.equalTo(tagLabel.snp.bottom).offset(15)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        projectIdLabel.snp.makeConstraints { (make) in
            make.top.equalTo(separatorLine.snp.bottom).offset(13)
            make.left.equalToSuperview().offset(15)
            make.width.greaterThanOrEqualTo(100)
            make.height.equalTo(17)
        }
        orderTimeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(projectIdLabel)
            make.centerY.equalTo(projectIdLabel)
            make.width.greaterThanOrEqualTo(100)
        }
        
        consumerInfoBackView.snp.makeConstraints { (make) in
            make.top.equalTo(projectIdLabel.snp.bottom).offset(23)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.greaterThanOrEqualTo(100)
        }
        consumerInfoBackView.setContentHuggingPriority(UILayoutPriority(249), for: .vertical)
        consumerNameTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(14)
            make.width.equalTo(53)
            make.height.equalTo(19)
        }
        consumerNameContent.snp.makeConstraints { (make) in
            make.left.equalTo(consumerNameTitle.snp.right).offset(14)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(consumerNameTitle)
            make.height.equalTo(consumerNameTitle)
        }
        phoneTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.top.equalTo(consumerNameTitle.snp.bottom).offset(6)
            make.width.equalTo(53)
            make.height.equalTo(19)
        }
        phoneContent.snp.makeConstraints { (make) in
            make.left.equalTo(phoneTitle.snp.right).offset(14)
            make.width.greaterThanOrEqualTo(30)
            make.height.equalTo(phoneTitle.snp.height)
            make.centerY.equalTo(phoneTitle.snp.centerY)
        }
        addressTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.top.equalTo(phoneTitle.snp.bottom).offset(6)
            make.width.equalTo(53)
            make.height.equalTo(19)
        }
        addressContent.snp.makeConstraints { (make) in
            make.left.equalTo(addressTitle.snp.right).offset(14)
            make.right.equalToSuperview().offset(-15)
            make.height.greaterThanOrEqualTo(19)
            make.top.equalTo(addressTitle)
        }
        communityTitle.snp.makeConstraints { (make) in
            make.top.equalTo(communityContent)
            make.left.equalToSuperview().offset(14)
            make.width.equalTo(53)
            make.height.equalTo(19)
        }
        communityContent.snp.makeConstraints { (make) in
            make.left.equalTo(communityTitle.snp.right).offset(14)
            make.right.equalToSuperview().offset(-15)
            make.height.greaterThanOrEqualTo(19)
            make.top.equalTo(addressContent.snp.bottom).offset(6)
            make.bottom.equalToSuperview().offset(-12).priority(900)
        }
        communityContent.setContentHuggingPriority(UILayoutPriority(249), for: .vertical)
        
        decoInfoBackView.snp.makeConstraints { (make) in
            make.top.equalTo(consumerInfoBackView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.greaterThanOrEqualTo(100)
        }
        decoInfoBackView.setContentHuggingPriority(UILayoutPriority(248), for: .vertical)
        houseTypeTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(14)
            make.width.equalTo(53)
            make.height.equalTo(19)
        }
        houseTypeContent.snp.makeConstraints { (make) in
            make.height.equalTo(houseTypeTitle)
            make.left.equalTo(houseTypeTitle.snp.right).offset(14)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(houseTypeTitle)
        }
        areaTitle.snp.makeConstraints { (make) in
            make.top.equalTo(houseTypeTitle.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(14)
            make.width.equalTo(53)
            make.height.equalTo(19)
        }
        areaContent.snp.makeConstraints { (make) in
            make.left.equalTo(areaTitle.snp.right).offset(14)
            make.height.equalTo(areaTitle)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(areaTitle)
        }
        budgetTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.top.equalTo(areaTitle.snp.bottom).offset(6)
            make.width.equalTo(53)
            make.height.equalTo(19)
        }
        budgetContent.snp.makeConstraints { (make) in
            make.left.equalTo(budgetTitle.snp.right).offset(14)
            make.height.equalTo(budgetTitle)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(budgetTitle)
        }
        styleTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.top.equalTo(budgetTitle.snp.bottom).offset(6)
            make.width.equalTo(53)
            make.height.equalTo(19)
        }
        styleContent.snp.makeConstraints { (make) in
            make.left.equalTo(styleTitle.snp.right).offset(14)
            make.height.equalTo(styleTitle)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(styleTitle)
        }
        roomTypeTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.top.equalTo(styleTitle.snp.bottom).offset(6)
            make.width.equalTo(53)
            make.height.equalTo(19)
        }
        roomTypeContent.snp.makeConstraints { (make) in
            make.left.equalTo(roomTypeTitle.snp.right).offset(14)
            make.height.equalTo(styleTitle)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(roomTypeTitle)
            make.bottom.equalToSuperview().offset(-12).priority(800)
        }
        
        extraInfoBackView.snp.makeConstraints { (make) in
            make.top.equalTo(decoInfoBackView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.greaterThanOrEqualTo(50)
            make.bottom.equalToSuperview().offset(-20).priority(600)
        }
        extraInfoBackView.setContentHuggingPriority(UILayoutPriority(247), for: .vertical)
        solutionTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(12)
            make.width.equalTo(53)
            make.height.equalTo(19)
        }
        solutionContent.snp.makeConstraints { (make) in
            make.left.equalTo(solutionTitle.snp.right).offset(14)
            make.width.greaterThanOrEqualTo(10)
            make.height.equalTo(solutionTitle.snp.height)
            make.centerY.equalTo(solutionTitle.snp.centerY)
        }
        remarkTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.top.equalTo(solutionTitle.snp.bottom).offset(6)
            make.width.equalTo(53)
            make.height.equalTo(19)
        }
        remarkContent.snp.makeConstraints { (make) in
            make.left.equalTo(remarkTitle.snp.right).offset(14)
            make.height.greaterThanOrEqualTo(19)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(remarkTitle)
            make.bottom.equalToSuperview().offset(-12).priority(700)
        }
    }
    
    // MARK: - lazy loading
    /// 白色背景view
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
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
    private lazy var tagBackView: UIView = {
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
    
    // MARK: - 业主信息
    /// 用户信息灰色背景
    private lazy var consumerInfoBackView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(hexColor: 0xF9F9F9, alpha: 1.0)
        return view
    }()
    
    /// 业主姓名title
    private lazy var consumerNameTitle: UILabel = {
        let label = UILabel()
        label.text = "业主姓名"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    /// 业主姓名content
    private lazy var consumerNameContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    /// 联系电话title
    private lazy var phoneTitle: UILabel = {
        let label = UILabel()
        label.text = "联系电话"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    /// 联系电话content
    private lazy var phoneContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .buttonBlue)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESDesProjectOrderDetailCell.phoneLabelClick))
        label.addGestureRecognizer(tgr)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    /// 项目地址title
    private lazy var addressTitle: UILabel = {
        let label = UILabel()
        label.text = "项目地址"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    /// 项目地址content
    private lazy var addressContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.numberOfLines = 0
        return label
    }()
    
    /// 小区名称title
    private lazy var communityTitle: UILabel = {
        let label = UILabel()
        label.text = "小区名称"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    /// 小区名称content
    private lazy var communityContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - 装修信息
    /// 装修信息灰色背景
    private lazy var decoInfoBackView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(hexColor: 0xF9F9F9, alpha: 1.0)
        return view
    }()
    
    /// 房屋类型title
    private lazy var houseTypeTitle: UILabel = {
        let label = UILabel()
        label.text = "房屋类型"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    /// 房屋类型content
    private lazy var houseTypeContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    /// 建筑面积title
    private lazy var areaTitle: UILabel = {
        let label = UILabel()
        label.text = "套内建筑面积"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    /// 建筑面积content
    private lazy var areaContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    /// 装修预算title
    lazy var budgetTitle: UILabel = {
        let label = UILabel()
        label.text = "装修预算"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    /// 装修预算content
    private lazy var budgetContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    /// 装修风格title
    lazy var styleTitle: UILabel = {
        let label = UILabel()
        label.text = "装修风格"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    /// 装修风格content
    private lazy var styleContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    /// 户型title
    lazy var roomTypeTitle: UILabel = {
        let label = UILabel()
        label.text = "户      型"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    /// 户型content
    private lazy var roomTypeContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    // MARK: - 其他信息
    /// 其他信息灰色背景
    private lazy var extraInfoBackView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(hexColor: 0xF9F9F9, alpha: 1.0)
        return view
    }()
    
    /// 参考方案title
    lazy var solutionTitle: UILabel = {
        let label = UILabel()
        label.text = "参考方案"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    /// 参考方案content
    private lazy var solutionContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .buttonBlue)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESDesProjectOrderDetailCell.solutionLabelClick))
        label.addGestureRecognizer(tgr)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    /// 备注说明title
    lazy var remarkTitle: UILabel = {
        let label = UILabel()
        label.text = "备注说明"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    /// 备注说明content
    private lazy var remarkContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.numberOfLines = 0
        return label
    }()
}
