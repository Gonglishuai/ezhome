//
//  ESProProjectPreviewInfoCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//  消费者 - 预交底信息

import UIKit
import SnapKit

protocol ESProProjectPreviewInfoCellDelegate {
    /// 打电话
    func phoneTextClick(phone: String)
}

class ESProProjectPreviewInfoCell: UITableViewCell, ESProProjectDetailCellProtocol {

    weak var delegate:ESProProjectDetailCellDelegate?
    private var itemModel = ESProProjectPreviewViewModel()
    private var backViewTop: Constraint?
    private var backViewBottom: Constraint?
    
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
    
    public func updateCell(index: Int, section: Int) {
        delegate?.getViewModel(index: index, section: section, cellId: "ESProProjectPreviewInfoCell", viewModel: itemModel)
        
        if itemModel.empty {
            backView.isHidden = true
            backViewBottom?.deactivate()
            return
        }
        
        backView.isHidden = false
        backViewBottom?.activate()
        
        nameTitle.text = itemModel.name.title
        nameContent.text = itemModel.name.content ?? "--"
        phoneTitle.text = itemModel.phone.title
        
        if let phone = itemModel.phone.content {
            phoneContent.text = phone
            phoneContent.textColor = ESColor.color(sample: .buttonBlue)
            phoneContent.isUserInteractionEnabled = true
        } else {
            phoneContent.text = "--"
            phoneContent.textColor = ESColor.color(sample: .mainTitleColor)
            phoneContent.isUserInteractionEnabled = false
        }
        
        let top = index == 0 ? 15.0 : 0.1
        self.backViewTop?.update(offset: top)
    }
    
    @objc private func phoneContentTap() {
        if ESStringUtil.isEmpty(itemModel.phone.content) {
            return
        }
        if let text = itemModel.phone.content {
            
            delegate?.phoneTextClick(phone: text)
        }
    }
    
    private func addSubviews() {
        contentView.addSubview(noDataLabel)
        contentView.addSubview(backView)
    }
    
    private func setConstraint() {
        noDataLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(60)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-60).priority(800)
            make.height.equalTo(19)
        }
        backView.snp.makeConstraints { (make) in
            self.backViewTop = make.top.equalToSuperview().constraint
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-15).priority(900)
        }
        nameImgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(23.5)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(12)
            make.height.equalTo(12)
        }
        nameTitle.snp.makeConstraints { (make) in
            make.left.equalTo(nameImgView.snp.right).offset(10)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(50)
            make.centerY.equalTo(nameImgView)
        }
        nameContent.snp.makeConstraints { (make) in
            make.left.equalTo(nameTitle.snp.right).offset(31.5)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(20)
            make.centerY.equalTo(nameImgView)
        }
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(nameImgView.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(0.5)
        }
        phoneImgView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(lineView.snp.bottom).offset(24)
            make.height.equalTo(12.5)
            make.width.equalTo(12.5)
            make.bottom.equalToSuperview().offset(-29)
        }
        phoneTitle.snp.makeConstraints { (make) in
            make.left.equalTo(nameTitle)
            make.width.equalTo(nameTitle)
            make.height.equalTo(nameTitle)
            make.centerY.equalTo(phoneImgView)
        }
        phoneContent.snp.makeConstraints { (make) in
            make.left.equalTo(nameContent.snp.left)
            make.width.greaterThanOrEqualTo(20)
            make.height.equalTo(60)
            make.centerY.equalTo(phoneImgView)
        }
    }

    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.shadowOpacity = 1.0
        view.layer.shadowColor = ESColor.color(hexColor: 0x000000, alpha: 0.03).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 5
        view.layer.cornerRadius = 3.0
        view.layer.borderColor = ESColor.color(sample: .separatorLine).cgColor
        view.layer.borderWidth = 0.5
        view.addSubview(nameImgView)
        view.addSubview(nameTitle)
        view.addSubview(nameContent)
        view.addSubview(lineView)
        view.addSubview(phoneImgView)
        view.addSubview(phoneTitle)
        view.addSubview(phoneContent)
        return view
    }()
    
    private lazy var nameImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = ESPackageAsserts.bundleImage(named: "owner_name_black")
        return imgView
    }()
    
    private lazy var nameTitle: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(hexColor: 0x4A4A4A, alpha: 1.0)
        label.font = ESFont.font(name: .regular, size: 14.0)
        return label
    }()
    
    private lazy var nameContent: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = ESFont.font(name: .regular, size: 14.0)
        return label
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .separatorLine)
        return view
    }()
    
    private lazy var phoneImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = ESPackageAsserts.bundleImage(named: "phone_black")
        return imgView
    }()
    
    private lazy var phoneTitle: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(hexColor: 0x4A4A4A, alpha: 1.0)
        label.font = ESFont.font(name: .regular, size: 14.0)
        return label
    }()
    
    private lazy var phoneContent: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .buttonBlue)
        label.font = ESFont.font(name: .medium, size: 16.0)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESProProjectPreviewInfoCell.phoneContentTap))
        label.addGestureRecognizer(tgr)
        return label
    }()
    
    private lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无预交底信息"
        label.textColor = ESColor.color(sample: .subTitleColorB)
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textAlignment = .center
        return label
    }()
}
