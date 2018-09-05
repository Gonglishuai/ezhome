//
//  ESProProjectListCell.swift
//  Consumer
//
//  Created by Jiao on 2018/1/7.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESProProjectListCellDelegate: NSObjectProtocol, ESTableViewCellProtocol {
    func designerDetail(index: Int)
    func contactDesigner(index: Int)
    func payOrderDetail(index: Int)
    func goToPay(index: Int)
    func returnDetail(index: Int)
    func withdrawClick(index: Int)
    func evaluate(index: Int)
}

class ESProProjectListCell: UITableViewCell, ESProDesignerInfoViewDelegate, ESProProjectListPayViewDelegate, ESProProjectListReturnViewDelegate, ESProProjectListWthdrawViewDelegate, ESProProjectListEvaluateViewDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    weak var delegate: ESProProjectListCellDelegate?
    private var itemModel: ESProProjectListViewModel = ESProProjectListViewModel()
    private var index: Int = 0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = ESColor.color(hexColor: 0xFFFFFF, alpha: 1.0)
        
        addSubViews()
        setConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(index: Int, section: Int) {
        self.index = section
        delegate?.getViewModel(index: index, section: section, cellId: "ESProProjectListCell", viewModel: itemModel)
        
        /// 基础信息
        if let type = itemModel.businessType, type != "" {
            typeContent.text = type
        } else {
            typeContent.text = "--"
        }
        
        nameContent.text = itemModel.consumerName ?? "--"
        phoneContent.text = itemModel.phone ?? "--"
        addrContent.text = itemModel.address ?? "--"
        statusLabel.text = itemModel.status.text ?? ""
        statusLabel.textColor = itemModel.status.color ?? UIColor.clear
        
        var views: [UIView] = []
        for view in bottomView.subviews {
            view.removeFromSuperview()
        }
        /// 预约审核
        orderRejectedView.isHidden = !itemModel.bookingFailReason.show
        if itemModel.bookingFailReason.show {
            orderRejectedView.updateView(title: "您的预约装修服务申请未通过，原因如下：")
            orderRejectedView.updateView(reason: itemModel.bookingFailReason.text ?? "--")
            views.append(orderRejectedView)
        }
        
        /// 设计师信息
        designerInfoView.isHidden = !itemModel.designerInfo.show
        if itemModel.designerInfo.show {
            designerInfoView.updateView(header: itemModel.designerInfo.header, name: itemModel.designerInfo.name)
            views.append(designerInfoView)
        }
        
        /// 支付信息
        payInfoView.isHidden = !itemModel.payInfo.show
        if itemModel.payInfo.show {
            payInfoView.updateView(amount: itemModel.payInfo.amount)
            views.append(payInfoView)
        }
        
        /// 退款/退单详情
        returnInfoView.isHidden = !itemModel.returnInfo.show
        if itemModel.returnInfo.show {
            returnInfoView.updateView(title: itemModel.returnInfo.title ?? "",
                                      reason: itemModel.returnInfo.reason ?? "" ,
                                      buttonTitle: itemModel.returnInfo.buttonTitle)
            views.append(returnInfoView)
        }
        
        /// 申请退款(提取余额)
        withdrawInfoView.isHidden = !itemModel.withdrawInfo.show
        if itemModel.withdrawInfo.show {
            withdrawInfoView.updateView(content: itemModel.withdrawInfo.content ?? "",
                                        amount: itemModel.withdrawInfo.amount,
                                        showButton: !itemModel.withdrawInfo.complete)
            views.append(withdrawInfoView)
        }
        
        /// 去评价
        // TODO: evaluate
//        evaluateView.isHidden = !itemModel.evaluateInfo.show
//        if itemModel.evaluateInfo.show {
//            evaluateView.updateView(title: itemModel.evaluateInfo.title ?? "",
//                                      buttonTitle: itemModel.evaluateInfo.buttonTitle)
//            views.append(evaluateView)
//        }
        remakeConstraints(views)
    }
    
    func remakeConstraints(_ views: [UIView]) {
        bottomView.isHidden = views.count <= 0
        topView.snp.remakeConstraints({ (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            if views.count <= 0 {
                make.bottom.equalToSuperview().priority(800)
            }
        })
        
        if views.count > 0 {
            bottomView.snp.remakeConstraints({ (make) in
                make.top.equalTo(topView.snp.bottom)
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.height.greaterThanOrEqualTo(100)
                make.bottom.equalToSuperview().priority(800)
            })
            
            var lastView: UIView?
            for (index, view) in views.enumerated() {
                bottomView.addSubview(view)
                view.snp.remakeConstraints({ (make) in
                    if lastView == nil {//判断是否是第一个视图
                        make.top.equalToSuperview()
                    } else {
                        make.top.equalTo(lastView!.snp.bottom).offset(15)
                    }
                    make.height.greaterThanOrEqualTo(10)
                    make.left.equalToSuperview().offset(15)
                    make.right.equalToSuperview().offset(-15)
                    if index == views.count - 1 {//判断是否是最后一个视图
                        make.bottom.equalToSuperview().offset(-15).priority(800)
                    }
                })
                lastView = view
            }
        } else {
            bottomView.snp.removeConstraints()
        }
    }
    
    // MARK: - ESProDesignerInfoViewDelegate
    func designerDetailInfo() {
        delegate?.designerDetail(index: index)
    }
    
    func contactDesigner() {
        delegate?.contactDesigner(index: index)
    }
    
    // MARK: - ESProProjectListPayViewDelegate
    func payOrderDetail() {
        delegate?.payOrderDetail(index: index)
    }
    
    func goToPay() {
        delegate?.goToPay(index: index)
    }
    
    // MARK: - ESProProjectListReturnViewDelegate
    func returnDetail() {
        delegate?.returnDetail(index: index)
    }
    
    // MARK: - ESProProjectListWthdrawViewDelegate
    func withdrawClick() {
        delegate?.withdrawClick(index: index)
    }
    
    // MARK: - ESProProjectListEvaluateViewDelegate
    func goToEvaluate() {
        delegate?.evaluate(index: index)
    }
    
    // MARK: - Private
    private func addSubViews() {
        contentView.addSubview(topView)
        contentView.addSubview(bottomView)
    }
    
    private func setConstraint() {
        typeTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(16.5)
            make.width.equalTo(53)
            make.height.equalTo(19)
        }
        statusLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15.5)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(19)
            make.width.greaterThanOrEqualTo(50)
        }
        typeContent.snp.makeConstraints { (make) in
            make.left.equalTo(typeTitle.snp.right).offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(typeTitle)
            make.centerY.equalTo(typeTitle)
        }
        nameTitle.snp.makeConstraints { (make) in
            make.left.equalTo(typeTitle)
            make.top.equalTo(typeTitle.snp.bottom).offset(10)
            make.width.equalTo(typeTitle)
            make.height.equalTo(typeTitle)
        }
        nameContent.snp.makeConstraints { (make) in
            make.left.equalTo(nameTitle.snp.right).offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(nameTitle)
            make.height.greaterThanOrEqualTo(18.5)
        }
        phoneTitle.snp.makeConstraints { (make) in
            make.top.equalTo(nameContent.snp.bottom).offset(10)
            make.left.equalTo(typeTitle)
            make.width.equalTo(typeTitle)
            make.height.equalTo(typeTitle)
        }
        phoneContent.snp.makeConstraints { (make) in
            make.left.equalTo(phoneTitle.snp.right).offset(15)
            make.top.equalTo(phoneTitle)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(phoneTitle)
        }
        addrTitle.snp.makeConstraints { (make) in
            make.left.equalTo(typeTitle)
            make.top.equalTo(phoneTitle.snp.bottom).offset(10)
            make.width.equalTo(typeTitle)
            make.height.equalTo(typeTitle)
        }
        addrContent.snp.makeConstraints { (make) in
            make.top.equalTo(addrTitle)
            make.left.equalTo(addrTitle.snp.right).offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.greaterThanOrEqualTo(18.5)
            make.bottom.equalTo(-15).priority(800)
        }
    }
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.addSubview(typeTitle)
        view.addSubview(typeContent)
        view.addSubview(nameTitle)
        view.addSubview(nameContent)
        view.addSubview(phoneTitle)
        view.addSubview(phoneContent)
        view.addSubview(addrTitle)
        view.addSubview(addrContent)
        view.addSubview(statusLabel)
        return view
    }()

    /// 业务类型标题
    private lazy var typeTitle: UILabel = {
        let label = UILabel()
        label.text = "业务类型"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .titleBlack)
        return label
    }()
    
    /// 业务类型内容
    private lazy var typeContent: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = ESFont.font(name: .regular, size: 13.0)
        return label
    }()
    
    
    /// 业主姓名标题
    private lazy var nameTitle: UILabel = {
        let label = UILabel()
        label.text = "业主姓名"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .titleBlack)
        return label
    }()
    
    /// 业务姓名内容
    private lazy var nameContent: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.numberOfLines = 0
        return label
    }()
    
    /// 联系电话标题
    private lazy var phoneTitle: UILabel = {
        let label = UILabel()
        label.text = "联系电话"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .titleBlack)
        return label
    }()
    
    /// 联系电话content
    private lazy var phoneContent: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = ESFont.font(name: .regular, size: 13.0)
        return label
    }()
    
    /// 项目地址标题
    private lazy var addrTitle: UILabel = {
        let label = UILabel()
        label.text = "项目地址"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .titleBlack)
        return label
    }()
    
    /// 项目地址内容
    private lazy var addrContent: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.numberOfLines = 0
        return label
    }()
    
    /// 状态
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .medium, size: 13.0)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 取消预约原因view
    private lazy var orderRejectedView: ESProProjectListRejectedView = {
        let view = ESProProjectListRejectedView()
        return view
    }()
    
    /// 设计师信息view
    private lazy var designerInfoView: ESProDesignerInfoView = {
        let view = ESProDesignerInfoView(delegate: self)
        return view
    }()
    
    /// 支付信息view
    private lazy var payInfoView: ESProProjectListPayView = {
        let view = ESProProjectListPayView(delegate: self)
        return view
    }()
    
    /// 退单信息view
    private lazy var returnInfoView: ESProProjectListReturnView = {
        let view = ESProProjectListReturnView(delegate: self)
        return view
    }()
    
    /// 提取余额view
    private lazy var withdrawInfoView: ESProProjectListWthdrawView = {
        let view = ESProProjectListWthdrawView(delegate: self)
        return view
    }()
    
    /// 去评价
    lazy var evaluateView: ESProProjectListEvaluateView = {
        let view = ESProProjectListEvaluateView(delegate: self)
        return view
    }()
}
