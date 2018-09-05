//
//  ESDesProjectContractCell.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/25.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit
import SnapKit

protocol ESDesProjectContractCellDelegate {
    
    /// 点击"查看详情"
    func contractDetailClick()
    
    /// 点击"录入合同信息"
    func createContractClick()
    
    /// 点击"修改合同信息"
    func editContractClick()
}

class ESDesProjectContractCell: UITableViewCell, ESDesProjectDetailCellProtocol {

    weak var delegate: ESDesProjectDetailCellDelegate?
    private var itemModel = ESDesProjectContractViewModel()
    private var serviceViewBottom: Constraint?
    
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
        delegate?.getViewModel(index: index, section: section, cellId: "ESDesProjectContractCell", viewModel: itemModel)
        
        bottomBtn.isEnabled = itemModel.buttonAble
        switch itemModel.buttonType {
        case .create:
            bottomBtn.isHidden = false
            serviceLine.isHidden = false
            bottomBtn.setTitle("录入合同信息", for: .normal)
            let bottom = -(38.scalValue + 23 * 2)
            self.serviceViewBottom?.update(offset: bottom)
        case .edit:
            bottomBtn.isHidden = false
            serviceLine.isHidden = false
            bottomBtn.setTitle("修改合同信息", for: .normal)
            let bottom = -(38.scalValue + 23 * 2)
            self.serviceViewBottom?.update(offset: bottom)
        case .none:
            bottomBtn.isHidden = true
            serviceLine.isHidden = true
            self.serviceViewBottom?.update(offset: 0)
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
        
        serviceView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(55)
            self.serviceViewBottom = make.bottom.equalToSuperview().priority(700).constraint
        }
        serviceTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(50)
            make.centerY.equalToSuperview()
        }
        serviceImgView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(3.5)
            make.height.equalTo(9)
        }
        serviceContent.snp.makeConstraints { (make) in
            make.right.equalTo(serviceImgView.snp.left).offset(-10)
            make.width.greaterThanOrEqualTo(5)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        serviceLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(serviceView.snp.bottom)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        let height = CGFloat(38)
        bottomBtn.snp.remakeConstraints({ (make) in
            make.top.equalTo(serviceLine.snp.bottom).offset(23)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(height.scalValue)
        })
    }
    
    // MARK: - 点击事件
    /// 点击服务协议
    ///
    /// - Parameter sender: gesture
    @objc private func tapServiceView(sender: UITapGestureRecognizer) {
        delegate?.contractDetailClick()
    }
    
    /// 点击底部按钮
    ///
    /// - Parameter sender: button
    @objc private func buttonClick(sender: UIButton) {
        switch itemModel.buttonType {
        case .create:
            delegate?.createContractClick()
        case .edit:
            delegate?.editContractClick()
        default:
            break
        }
    }
    
    // MARK: - lazy loading
    /// 白色背景底
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.addSubview(self.serviceView)
        view.addSubview(self.serviceLine)
        view.addSubview(self.bottomBtn)
        return view
    }()
    
    // MARK: 服务协议
    /// 服务协议view
    private lazy var serviceView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESDesProjectContractCell.tapServiceView(sender:)))
        view.addGestureRecognizer(tgr)
        view.addSubview(self.serviceTitle)
        view.addSubview(self.serviceContent)
        view.addSubview(self.serviceImgView)
        return view
    }()
    
    /// 服务协议title
    private lazy var serviceTitle: UILabel = {
        let label = UILabel()
        label.text = "服务协议"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    /// 服务协议 content
    private lazy var serviceContent: UILabel = {
        let label = UILabel()
        label.text = "查看详情"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorB)
        return label
    }()
    
    private lazy var serviceImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = ESPackageAsserts.bundleImage(named: "arrow_right")
        return imgView
    }()
    
    private lazy var serviceLine: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .separatorLine)
        return view
    }()
    
    // MARK: 按钮
    private lazy var bottomBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 2.0
        button.titleLabel?.font = ESFont.font(name: .regular, size: 13.0)
        button.setTitleColor(UIColor.white, for: .normal)
        let normal = ESColor.getImage(color: ESColor.color(sample: .buttonBlue))
        let disabled = ESColor.getImage(color: ESColor.color(sample: .buttonDisable))
        button.setBackgroundImage(normal, for: .normal)
        button.setBackgroundImage(normal, for: .highlighted)
        button.setBackgroundImage(disabled, for: .disabled)
        button.addTarget(self, action: #selector(ESDesProjectContractCell.buttonClick(sender:)), for: .touchUpInside)
        return button
    }()
}
