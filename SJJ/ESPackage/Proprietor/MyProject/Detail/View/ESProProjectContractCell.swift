//
//  ESProProjectContractCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//  消费者 - 费用信息

import UIKit

protocol ESProProjectContractCellDelegate {
    func contractDetail()
}

class ESProProjectContractCell: UITableViewCell, ESProProjectDetailCellProtocol {

    weak var delegate: ESProProjectDetailCellDelegate?
    private var itemModel = ESProProjectContractViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.white
        
        addSubviews()
        setConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(index: Int, section: Int) {
        delegate?.getViewModel(index: index, section: section, cellId: "ESProProjectContractCell", viewModel: itemModel)
        signTimeContent.text  = itemModel.signTime
        startTimeContent.text = itemModel.startTime
        finishTimeContent.text = itemModel.finishTime
        timeLimitContent.text = itemModel.tiemLimit
        amountContent.text = itemModel.amount
        promotionContent.text = itemModel.promotion
    }
    
    @objc private func detailTap() {
        delegate?.contractDetail()
    }
    
    private func addSubviews() {
        contentView.addSubview(backView)
        contentView.addSubview(lineView)
        contentView.addSubview(detailLabel)
    }
    
    private func setConstraint() {
        backView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.greaterThanOrEqualTo(30)
        }
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(backView.snp.bottom).offset(18)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(50.5)
            make.bottom.equalToSuperview().priority(800)
        }
     
        signTimeTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(13.5)
            make.width.equalTo(53)
            make.height.equalTo(19)
        }
        signTimeContent.snp.makeConstraints { (make) in
            make.left.equalTo(signTimeTitle.snp.right).offset(13.5)
            make.right.equalToSuperview().offset(-13.5)
            make.centerY.equalTo(signTimeTitle)
            make.height.equalTo(signTimeTitle)
        }
        startTimeTitle.snp.makeConstraints { (make) in
            make.top.equalTo(signTimeTitle.snp.bottom).offset(6)
            make.left.equalTo(signTimeTitle)
            make.width.equalTo(signTimeTitle)
            make.height.equalTo(signTimeTitle)
        }
        startTimeContent.snp.makeConstraints { (make) in
            make.left.equalTo(signTimeContent)
            make.right.equalTo(signTimeContent)
            make.height.equalTo(signTimeTitle)
            make.centerY.equalTo(startTimeTitle)
        }
        finishTimeTitle.snp.makeConstraints { (make) in
            make.top.equalTo(startTimeTitle.snp.bottom).offset(6)
            make.left.equalTo(signTimeTitle)
            make.height.equalTo(signTimeTitle)
            make.width.equalTo(signTimeTitle)
        }
        finishTimeContent.snp.makeConstraints { (make) in
            make.left.equalTo(signTimeContent)
            make.right.equalTo(signTimeContent)
            make.height.equalTo(signTimeTitle)
            make.centerY.equalTo(finishTimeTitle)
        }
        timeLimitTitle.snp.makeConstraints { (make) in
            make.top.equalTo(finishTimeTitle.snp.bottom).offset(6)
            make.left.equalTo(signTimeTitle)
            make.height.equalTo(signTimeTitle)
            make.width.equalTo(signTimeTitle)
        }
        timeLimitContent.snp.makeConstraints { (make) in
            make.left.equalTo(signTimeContent)
            make.right.equalTo(signTimeContent)
            make.height.equalTo(signTimeTitle)
            make.centerY.equalTo(timeLimitTitle)
        }
        amountTitle.snp.makeConstraints { (make) in
            make.top.equalTo(timeLimitTitle.snp.bottom).offset(6)
            make.left.equalTo(signTimeTitle)
            make.height.equalTo(signTimeTitle)
            make.width.equalTo(signTimeTitle)
        }
        amountContent.snp.makeConstraints { (make) in
            make.left.equalTo(signTimeContent)
            make.right.equalTo(signTimeContent)
            make.height.equalTo(signTimeTitle)
            make.centerY.equalTo(amountTitle)
        }
        promotionTitle.snp.makeConstraints { (make) in
            make.top.equalTo(amountTitle.snp.bottom).offset(6)
            make.left.equalTo(signTimeTitle)
            make.height.equalTo(signTimeTitle)
            make.width.equalTo(signTimeTitle)
        }
        promotionContent.snp.makeConstraints { (make) in
            make.left.equalTo(signTimeContent)
            make.right.equalTo(signTimeContent)
            make.height.greaterThanOrEqualTo(18)
            make.top.equalTo(promotionTitle)
            make.bottom.equalToSuperview().offset(-12).priority(800)

        }
    }
    
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        view.addSubview(signTimeTitle)
        view.addSubview(signTimeContent)
        view.addSubview(startTimeTitle)
        view.addSubview(startTimeContent)
        view.addSubview(finishTimeTitle)
        view.addSubview(finishTimeContent)
        view.addSubview(timeLimitTitle)
        view.addSubview(timeLimitContent)
        view.addSubview(amountTitle)
        view.addSubview(amountContent)
        view.addSubview(promotionTitle)
        view.addSubview(promotionContent)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 3.0
        return view
    }()
    
    /// 签约时间title
    private lazy var signTimeTitle: UILabel  = {
        let label = getLabel()
        label.text = "签约时间"
        return label
    }()
    
    /// 签约时间content
    private lazy var signTimeContent: UILabel  = {
        return getLabel()
    }()
    
    /// 开工时间title
    private lazy var startTimeTitle: UILabel  = {
        let label = getLabel()
        label.text = "开工时间"
        return label
    }()
    
    /// 开工时间content
    private lazy var startTimeContent: UILabel  = {
        return getLabel()
    }()
    
    /// 竣工时间title
    private lazy var finishTimeTitle: UILabel  = {
        let label = getLabel()
        label.text = "竣工时间"
        return label
    }()
    
    /// 竣工时间content
    private lazy var finishTimeContent: UILabel  = {
        return getLabel()
    }()
    
    /// 工期title
    private lazy var timeLimitTitle: UILabel  = {
        let label = getLabel()
        label.text = "工期天数"
        return label
    }()
    
    /// 工期content
    private lazy var timeLimitContent: UILabel  = {
        return getLabel()
    }()
    
    /// 合同金额title
    private lazy var amountTitle: UILabel  = {
        let label = getLabel()
        label.text = "合同金额"
        return label
    }()
    
    /// 合同金额content
    private lazy var amountContent: UILabel  = {
        return getLabel()
    }()
    
    /// 促销活动title
    private lazy var promotionTitle: UILabel  = {
        let label = getLabel()
        label.text = "促销活动"
        return label
    }()
    
    /// 促销活动content
    private lazy var promotionContent: UILabel  = {
        return getLabel()
    }()
    
    /// 分割线
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .separatorLine)
        return view
    }()
    
    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .buttonBlue)
        label.font = ESFont.font(name: .regular, size: 14.0)
        label.text = "查看合同详情"
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESProProjectContractCell.detailTap))
        label.addGestureRecognizer(tgr)
        return label
    }()
    
    private func getLabel() -> UILabel {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.font = ESFont.font(name: .regular, size: 13.0)
        return label
    }
}
