//
//  ESDesProjectQuoteInfoCell.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/27.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit
import SnapKit

protocol ESDesProjectQuoteInfoCellDelegate {
    
    /// 点击"查看详情"
    func quoteInfoDetailClick()
}

class ESDesProjectQuoteInfoCell: UITableViewCell, ESDesProjectDetailCellProtocol {

    weak var delegate: ESDesProjectDetailCellDelegate?
    private var itemModel = ESDesProjectQuoteInfoViewModel()
    private var quoteInfoViewBottom: Constraint?
    
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
        delegate?.getViewModel(index: index, section: section, cellId: "ESDesProjectQuoteInfoCell", viewModel: itemModel)
        
        if let info = itemModel.alertInfo.text {
            alertImgView.isHidden = false
            alertInfo.isHidden = false
            quoteInfoLine.isHidden = false
            alertInfo.text = info
            alertInfo.textColor = itemModel.alertInfo.color
            self.quoteInfoViewBottom?.update(offset: -50)
        } else {
            alertImgView.isHidden = true
            alertInfo.isHidden = true
            quoteInfoLine.isHidden = true
            self.quoteInfoViewBottom?.update(offset: 0)
        }
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
        
        quoteInfoView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(55)
            self.quoteInfoViewBottom = make.bottom.equalToSuperview().priority(700).constraint
        }
        quoteInfoTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(50)
            make.centerY.equalToSuperview()
        }
        quoteInfoImgView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(3.5)
            make.height.equalTo(9)
        }
        quoteInfoContent.snp.makeConstraints { (make) in
            make.right.equalTo(quoteInfoImgView.snp.left).offset(-10)
            make.width.greaterThanOrEqualTo(5)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        quoteInfoLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(quoteInfoView.snp.bottom)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        alertImgView.snp.makeConstraints { (make) in
            make.top.equalTo(quoteInfoLine.snp.bottom).offset(11)
            make.left.equalToSuperview().offset(22)
            make.height.equalTo(15)
            make.width.equalTo(15)
        }
        alertInfo.snp.makeConstraints { (make) in
            make.left.equalTo(alertImgView.snp.right).offset(6)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(16)
            make.centerY.equalTo(alertImgView)
        }
    }
    
    // MARK: - 点击事件
    /// 点击图纸报价审核信息
    ///
    /// - Parameter sender: gesture
    @objc private func tapQuoteInfoView(sender: UITapGestureRecognizer) {
        delegate?.quoteInfoDetailClick()
    }
    
    // MARK: - lazy loading
    /// 白色背景底
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.addSubview(self.quoteInfoView)
        view.addSubview(self.quoteInfoLine)
        view.addSubview(self.alertImgView)
        view.addSubview(self.alertInfo)
        return view
    }()
    
    // MARK: 图纸报价审核信息
    /// 图纸报价审核信息view
    private lazy var quoteInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESDesProjectQuoteInfoCell.tapQuoteInfoView(sender:)))
        view.addGestureRecognizer(tgr)
        view.addSubview(self.quoteInfoTitle)
        view.addSubview(self.quoteInfoContent)
        view.addSubview(self.quoteInfoImgView)
        return view
    }()
    
    /// 图纸报价审核信息title
    private lazy var quoteInfoTitle: UILabel = {
        let label = UILabel()
        label.text = "图纸报价审核信息"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    /// 图纸报价审核信息 content
    private lazy var quoteInfoContent: UILabel = {
        let label = UILabel()
        label.text = "查看详情"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorB)
        return label
    }()
    
    private lazy var quoteInfoImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = ESPackageAsserts.bundleImage(named: "arrow_right")
        return imgView
    }()
    
    private lazy var quoteInfoLine: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .separatorLine)
        return view
    }()
    
    // MARK: 提示信息
    private lazy var alertImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = ESPackageAsserts.bundleImage(named: "alter_mark")
        return imgView
    }()
    
    private lazy var alertInfo: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 12.0)
        return label
    }()
}
