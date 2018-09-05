//
//  ESProProjectCostInfoCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//  消费者 - 费用信息

import UIKit

protocol ESProProjectCostInfoCellDelegate {
    /// 点击"付款明细"
    func paiedDetailClick()
    
    /// 点击"交易流水"
    func dealDetailClick()
    
    /// 点击 "立即支付"
    func payClick(type: ESCostPayBtnType)
}

class ESProProjectCostInfoCell: UITableViewCell, ESProProjectDetailCellProtocol {

    weak var delegate: ESProProjectDetailCellDelegate?
    private var itemModel = ESProProjectCostInfoViewModel()
    
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
    
    public func updateCell(index: Int, section: Int) {
        delegate?.getViewModel(index: index, section: section, cellId: "ESProProjectCostInfoCell", viewModel: itemModel)
        /// 设置付款明细
        receivablesContentRight.text = itemModel.payDetail.price
        receivablesView.isUserInteractionEnabled = true//itemModel.payDetail.able
        
        /// 设置交易流水
        paiedDetailContentRight.text = itemModel.dealDetail.price
        paiedDetailView.isUserInteractionEnabled = true//itemModel.dealDetail.able
        
        receiptBtn.setTitle(itemModel.payButton.type.rawValue, for: .normal)
        receiptBtn.isEnabled = itemModel.payButton.action
    }
    
    private func addSubviews() {
        self.contentView.addSubview(backView)
    }
    
    private func setConstraint() {
        backView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().priority(800)
        }
        
        receivablesView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(55)
        }
        receivablesTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(50)
            make.centerY.equalToSuperview()
        }
        receivablesImgView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(3.5)
            make.height.equalTo(9)
        }
        receivablesContentRight.snp.makeConstraints { (make) in
            make.right.equalTo(receivablesImgView.snp.left).offset(-10)
            make.width.greaterThanOrEqualTo(5)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        receivablesContentLeft.snp.makeConstraints { (make) in
            make.right.equalTo(receivablesContentRight.snp.left).offset(-5)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(20)
        }
        receivablesLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(receivablesView.snp.bottom)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        paiedDetailView.snp.makeConstraints { (make) in
            make.top.equalTo(receivablesLine.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(55)
        }
        paiedDetailTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(50)
            make.centerY.equalToSuperview()
        }
        paiedDetailImgView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(3.5)
            make.height.equalTo(9)
        }
        paiedDetailContentRight.snp.makeConstraints { (make) in
            make.right.equalTo(paiedDetailImgView.snp.left).offset(-10)
            make.width.greaterThanOrEqualTo(5)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        paiedDetailContentLeft.snp.makeConstraints { (make) in
            make.right.equalTo(paiedDetailContentRight.snp.left).offset(-5)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(20)
        }
        paiedDetailLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(paiedDetailView.snp.bottom)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        receiptBtn.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualTo(paiedDetailLine.snp.bottom).offset(23)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            let height = CGFloat(38.0)
            make.height.equalTo(height.scalValue)
            make.bottom.equalToSuperview().offset(-23).priority(700)
        }
    }
    
    // MARK: - 点击事件
    /// 点击 付款明细
    ///
    /// - Parameter sender: gesture
    @objc private func tapReceivablesView(sender: UITapGestureRecognizer) {
        delegate?.paiedDetailClick()
    }
    
    /// 点击 交易流水
    ///
    /// - Parameter sender: gesture
    @objc private func tapPaiedDetailView(sender: UITapGestureRecognizer) {
        delegate?.dealDetailClick()
    }
    
    /// 点击 立即付款
    ///
    /// - Parameter sender: button
    @objc private func payBtnClick(sender: UIButton) {
        delegate?.payClick(type: itemModel.payButton.type)
    }
    
    // MARK: - lazy loading
    /// 白色背景底
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.addSubview(self.receivablesView)
        view.addSubview(self.receivablesLine)
        view.addSubview(self.paiedDetailView)
        view.addSubview(self.paiedDetailLine)
        view.addSubview(self.receiptBtn)
        return view
    }()
    
    // MARK: 付款明细
    /// 付款明细view
    private lazy var receivablesView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESProProjectCostInfoCell.tapReceivablesView(sender:)))
        view.addGestureRecognizer(tgr)
        view.addSubview(self.receivablesTitle)
        view.addSubview(self.receivablesContentLeft)
        view.addSubview(self.receivablesContentRight)
        view.addSubview(self.receivablesImgView)
        return view
    }()
    
    /// 收款明细title
    private lazy var receivablesTitle: UILabel = {
        let label = UILabel()
        label.text = "付款明细"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    /// 付款明细 "待付"
    private lazy var receivablesContentLeft: UILabel = {
        let label = UILabel()
        label.text = "待付"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    /// 付款明细 金额
    private lazy var receivablesContentRight: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .medium, size: 13.0)
        label.textColor = ESColor.color(hexColor: 0xFF9A02, alpha: 1.0)
        return label
    }()
    
    private lazy var receivablesImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = ESPackageAsserts.bundleImage(named: "arrow_right")
        return imgView
    }()
    
    private lazy var receivablesLine: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .separatorLine)
        return view
    }()
    
    // MARK: 交易流水
    /// 交易流水view
    private lazy var paiedDetailView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESProProjectCostInfoCell.tapPaiedDetailView(sender:)))
        view.addGestureRecognizer(tgr)
        view.addSubview(self.paiedDetailTitle)
        view.addSubview(self.paiedDetailContentLeft)
        view.addSubview(self.paiedDetailContentRight)
        view.addSubview(self.paiedDetailImgView)
        return view
    }()
    
    /// 交易流水title
    private lazy var paiedDetailTitle: UILabel = {
        let label = UILabel()
        label.text = "交易流水"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    /// 交易流水 "已付"
    private lazy var paiedDetailContentLeft: UILabel = {
        let label = UILabel()
        label.text = "已付"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    /// 交易流水 金额
    private lazy var paiedDetailContentRight: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .medium, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    private lazy var paiedDetailImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = ESPackageAsserts.bundleImage(named: "arrow_right")
        return imgView
    }()
    
    private lazy var paiedDetailLine: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .separatorLine)
        return view
    }()
    
    
    // MARK: 立即支付
    /// 立即支付按钮
    lazy var receiptBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setTitle("立即支付", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        let normal = ESColor.getImage(color: ESColor.color(sample: .buttonBlue))
        let disabled = ESColor.getImage(color: ESColor.color(sample: .buttonDisable))
        button.setBackgroundImage(normal, for: .normal)
        button.setBackgroundImage(normal, for: .highlighted)
        button.setBackgroundImage(disabled, for: .disabled)
        button.titleLabel?.font = ESFont.font(name: .regular, size: 13.0)
        button.addTarget(self, action: #selector(ESProProjectCostInfoCell.payBtnClick(sender:)), for: .touchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 2.0
        return button
    }()
}
