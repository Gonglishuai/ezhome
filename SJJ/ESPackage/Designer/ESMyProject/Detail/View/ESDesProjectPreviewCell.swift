//
//  ESDesProjectPreviewCell.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/26.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//

import UIKit
import SnapKit

protocol ESDesProjectPreviewCellDelegate {
    
    /// 点击"查看详情"
    func previewDetailClick()
    
    /// 点击"发起预交底"
    func createPreviewClick()
    
    /// 点击"取消预交底申请"
    func cancelPreviewClick()
}

class ESDesProjectPreviewCell: UITableViewCell, ESDesProjectDetailCellProtocol {

    weak var delegate: ESDesProjectDetailCellDelegate?
    private var itemModel = ESDesProjectPreviewViewModel()
    private var previewViewBottom: Constraint?
    
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
        delegate?.getViewModel(index: index, section: section, cellId: "ESDesProjectPreviewCell", viewModel: itemModel)
        
        bottomBtn.isEnabled = itemModel.buttonAble
        switch itemModel.buttonType {
        case .create:
            bottomBtn.isHidden = false
            previewLine.isHidden = false
            bottomBtn.setTitle("发起预交底", for: .normal)
            
            let bottom = -(38.scalValue + 23 * 2)
            self.previewViewBottom?.update(offset: bottom)
        case .cancel:
            bottomBtn.isHidden = false
            previewLine.isHidden = false
            bottomBtn.setTitle("取消预交底申请", for: .normal)
            let bottom = -(38.scalValue + 23 * 2)
            self.previewViewBottom?.update(offset: bottom)
        case .none:
            bottomBtn.isHidden = true
            previewLine.isHidden = true
            self.previewViewBottom?.update(offset: 0)
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
        
        previewView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(55)
            self.previewViewBottom = make.bottom.equalToSuperview().priority(700).constraint
        }
        previewTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(50)
            make.centerY.equalToSuperview()
        }
        previewImgView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(3.5)
            make.height.equalTo(9)
        }
        previewContent.snp.makeConstraints { (make) in
            make.right.equalTo(previewImgView.snp.left).offset(-10)
            make.width.greaterThanOrEqualTo(5)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        previewLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(previewView.snp.bottom)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        let height = CGFloat(38)
        bottomBtn.snp.remakeConstraints({ (make) in
            make.top.equalTo(previewLine.snp.bottom).offset(23)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(height.scalValue)
        })
    }
    
    // MARK: - 点击事件
    /// 点击预交底信息
    ///
    /// - Parameter sender: gesture
    @objc private func tapPreviewView(sender: UITapGestureRecognizer) {
        delegate?.previewDetailClick()
    }
    
    /// 点击底部按钮
    ///
    /// - Parameter sender: button
    @objc private func buttonClick(sender: UIButton) {
        switch itemModel.buttonType {
        case .create:
            delegate?.createPreviewClick()
        case .cancel:
            delegate?.cancelPreviewClick()
        default:
            break
        }
    }
    
    // MARK: - lazy loading
    /// 预交底信息 title
    private lazy var title: UILabel = {
        let label = UILabel()
        label.text = "预交底信息"
        label.font = ESFont.font(name: .medium, size: 15.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    /// 预交底信息状态
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .medium, size: 13.0)
        return label
    }()
    
    /// 白色背景底
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.addSubview(self.previewView)
        view.addSubview(self.previewLine)
        view.addSubview(self.bottomBtn)
        return view
    }()
    
    // MARK: 预交底信息
    /// 预交底信息view
    private lazy var previewView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESDesProjectPreviewCell.tapPreviewView(sender:)))
        view.addGestureRecognizer(tgr)
        view.addSubview(self.previewTitle)
        view.addSubview(self.previewContent)
        view.addSubview(self.previewImgView)
        return view
    }()
    
    /// 预交底信息title
    private lazy var previewTitle: UILabel = {
        let label = UILabel()
        label.text = "预交底信息"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    /// 预交底信息 content
    private lazy var previewContent: UILabel = {
        let label = UILabel()
        label.text = "查看详情"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorB)
        return label
    }()
    
    private lazy var previewImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = ESPackageAsserts.bundleImage(named: "arrow_right")
        return imgView
    }()
    
    private lazy var previewLine: UIView = {
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
        button.setTitleColor(UIColor.white, for: .normal)
        let normal = ESColor.getImage(color: ESColor.color(sample: .buttonBlue))
        let disabled = ESColor.getImage(color: ESColor.color(sample: .buttonDisable))
        button.setBackgroundImage(normal, for: .normal)
        button.setBackgroundImage(normal, for: .highlighted)
        button.setBackgroundImage(disabled, for: .disabled)
        button.titleLabel?.font = ESFont.font(name: .regular, size: 13.0)
        button.addTarget(self, action: #selector(ESDesProjectPreviewCell.buttonClick(sender:)), for: .touchUpInside)
        return button
    }()

}
