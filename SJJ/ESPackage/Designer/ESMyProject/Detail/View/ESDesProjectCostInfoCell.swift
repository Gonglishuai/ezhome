//
//  ESDesProjectCostInfoCell.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/22.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  费用信息

import UIKit
import SnapKit

protocol ESDesProjectCostInfoCellDelegate {
    /// 点击"收款明细"
    func receivablesDetailClick()
    
    /// 点击"交易流水"
    func paiedDetailClick()
    
    /// 点击"选择优惠"
    func discountsChoiceClick()
    
    /// 点击 "面对面收款"
    func faceToFaceClick()
    
    /// 点击 "发起收款"
    func receiptClick()
}

class ESDesProjectCostInfoCell: UITableViewCell, ESDesProjectDetailCellProtocol {

    weak var delegate: ESDesProjectDetailCellDelegate?
    private var itemModel = ESDesProjectCostInfoViewModel()
    private var receiptBtnTop: Constraint?
    
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
        delegate?.getViewModel(index: index, section: section, cellId: "ESDesProjectCostInfoCell", viewModel: itemModel)
        /// 设置收款明细
        receivablesContentRight.text = itemModel.receivables.price
        receivablesView.isUserInteractionEnabled = true//itemModel.receivables.able
        
        /// 设置交易流水
        paiedDetailContentRight.text = itemModel.paiedDetail.price
        paiedDetailView.isUserInteractionEnabled = true//itemModel.paiedDetail.able
        
        /// 设置选择优惠
        discountsContent.text = itemModel.discounts.info
        discountsContent.textColor = itemModel.discounts.infoColor
        discountsView.isUserInteractionEnabled = itemModel.discounts.able
        
        faceToFaceView.isHidden = !itemModel.faceToFace
        self.receiptBtnTop?.update(offset: itemModel.faceToFace ? 59 : 23)
        
        receiptBtn.isEnabled = itemModel.canReceipt
        
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
        
        discountsView.snp.makeConstraints { (make) in
            make.top.equalTo(paiedDetailLine.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(55)
        }
        discountsTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(50)
            make.centerY.equalToSuperview()
        }
        discountsImgView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(3.5)
            make.height.equalTo(9)
        }
        discountsContent.snp.makeConstraints { (make) in
            make.right.equalTo(discountsImgView.snp.left).offset(-10)
            make.width.greaterThanOrEqualTo(5)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        discountsLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(discountsView.snp.bottom)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        faceToFaceView.snp.makeConstraints { (make) in
            make.top.equalTo(discountsLine.snp.bottom).offset(18)
            make.width.greaterThanOrEqualTo(150)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        faceToFaceBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.greaterThanOrEqualTo(50)
        }
        faceToFaceLeft.snp.makeConstraints { (make) in
            make.left.equalToSuperview().priority(800)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalTo(faceToFaceBtn.snp.left)
            make.width.greaterThanOrEqualTo(50)
        }
        
        receiptBtn.snp.makeConstraints { (make) in
            self.receiptBtnTop = make.top.greaterThanOrEqualTo(discountsLine.snp.bottom).offset(23).constraint
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            let height = CGFloat(38.0)
            make.height.equalTo(height.scalValue)
            make.bottom.equalToSuperview().offset(-23).priority(700)
        }
    }
    
    // MARK: - 点击事件
    /// 点击 收款明细
    ///
    /// - Parameter sender: gesture
    @objc private func tapReceivablesView(sender: UITapGestureRecognizer) {
        delegate?.receivablesDetailClick()
    }
    
    /// 点击 交易流水
    ///
    /// - Parameter sender: gesture
    @objc private func tapPaiedDetailView(sender: UITapGestureRecognizer) {
        delegate?.paiedDetailClick()
    }
    
    /// 点击 选择优惠
    ///
    /// - Parameter sender: gesture
    @objc private func tapDiscountsView(sender: UITapGestureRecognizer) {
        delegate?.discountsChoiceClick()
    }
    
    /// 点击 面对面收款
    ///
    /// - Parameter sender: button
    @objc private func faceToFaceBtnClick(sender: UIButton) {
        delegate?.faceToFaceClick()
    }
    
    /// 点击 发起收款
    ///
    /// - Parameter sender: button
    @objc private func receiptBtnClick(sender: UIButton) {
        delegate?.receiptClick()
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
        view.addSubview(self.discountsView)
        view.addSubview(self.discountsLine)
        view.addSubview(self.faceToFaceView)
        view.addSubview(self.receiptBtn)
        return view
    }()
    
    // MARK: 收款明细
    /// 收款明细view
    private lazy var receivablesView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESDesProjectCostInfoCell.tapReceivablesView(sender:)))
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
        label.text = "收款明细"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    /// 收款明细 "待收"
    private lazy var receivablesContentLeft: UILabel = {
        let label = UILabel()
        label.text = "待收"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    /// 收款明细 金额
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
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESDesProjectCostInfoCell.tapPaiedDetailView(sender:)))
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
    
    /// 交易流水 "已收"
    private lazy var paiedDetailContentLeft: UILabel = {
        let label = UILabel()
        label.text = "已收"
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
    
    // MARK: 选择优惠
    /// 选择优惠view
    private lazy var discountsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESDesProjectCostInfoCell.tapDiscountsView(sender:)))
        view.addGestureRecognizer(tgr)
        view.addSubview(self.discountsTitle)
        view.addSubview(self.discountsContent)
        view.addSubview(self.discountsImgView)
        return view
    }()
    
    /// 选择优惠title
    private lazy var discountsTitle: UILabel = {
        let label = UILabel()
        label.text = "选择优惠"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    /// 选择优惠content
    private lazy var discountsContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    private lazy var discountsImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = ESPackageAsserts.bundleImage(named: "arrow_right")
        return imgView
    }()

    private lazy var discountsLine: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .separatorLine)
        return view
    }()
    
    // MARK: 面对面
    /// 面对面view
    lazy var faceToFaceView: UIView = {
        let view = UIView()
        view.addSubview(self.faceToFaceLeft)
        view.addSubview(self.faceToFaceBtn)
        return view
    }()
    
    private lazy var faceToFaceLeft: UILabel = {
        let label = UILabel()
        label.text = "业主在身边，发起"
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = ESFont.font(name: .regular, size: 13.0)
        return label
    }()
    
    private lazy var faceToFaceBtn: UIButton = {
        let button = UIButton()
        button.setTitle("面对面收款", for: .normal)
        button.setTitleColor(ESColor.color(sample: .buttonBlue), for: .normal)
        button.titleLabel?.font = ESFont.font(name: .regular, size: 13.0)
        button.addTarget(self, action: #selector(ESDesProjectCostInfoCell.faceToFaceBtnClick(sender:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: 发起收款
    /// 发起收款按钮
    lazy var receiptBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setTitle("发起收款", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        let normal = ESColor.getImage(color: ESColor.color(sample: .buttonBlue))
        let disabled = ESColor.getImage(color: ESColor.color(sample: .buttonDisable))
        button.setBackgroundImage(normal, for: .normal)
        button.setBackgroundImage(normal, for: .highlighted)
        button.setBackgroundImage(disabled, for: .disabled)
        button.titleLabel?.font = ESFont.font(name: .regular, size: 13.0)
        button.addTarget(self, action: #selector(ESDesProjectCostInfoCell.receiptBtnClick(sender:)), for: .touchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 2.0
        return button
    }()
}
