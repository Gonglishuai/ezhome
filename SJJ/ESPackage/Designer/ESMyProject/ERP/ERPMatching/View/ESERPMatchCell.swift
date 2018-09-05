//
//  ESERPMatchCell.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/28.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

protocol ESERPMatchCellDelegate: ESTableViewCellProtocol, NSObjectProtocol {
    func selectItem(index: Int)
}

class ESERPMatchCell: UITableViewCell {

    weak var delegate: ESERPMatchCellDelegate?
    private var itemModel = ESERPMatchViewModel()
    private var index: Int = 0
    
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
        self.index = index
        delegate?.getViewModel(index: index, section: section, cellId: "ESERPMatchCell", viewModel: itemModel)
        
        leftTopLabel.text = String(format: "%02ld", index + 1)
        
        nameContent.text = itemModel.consumerName ?? "--"
        addressContent.text = itemModel.projectAddr ?? "--"
        designerContent.text = itemModel.designerName ?? "--"
        storeContent.text = itemModel.serviceStore ?? "--"
        
        backView.layer.borderColor = itemModel.isSelected ? ESColor.color(sample: .buttonBlue).cgColor : ESColor.color(sample: .separatorLine).cgColor
        leftTopView.image = itemModel.isSelected ? ESPackageAsserts.bundleImage(named: "erp_leftTop_sel") : ESPackageAsserts.bundleImage(named: "erp_leftTop")
        selectImgView.image = itemModel.isSelected ? ESPackageAsserts.bundleImage(named: "erp_btn_sel") : ESPackageAsserts.bundleImage(named: "erp_btn")
    }
    
    private func addSubviews() {
        self.contentView.addSubview(backView)
    }
    
    private func setConstraint() {
        backView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-15).priority(800)
        }
        leftTopView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(35)
            make.height.equalTo(35)
        }
        leftTopLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(3.5)
            make.top.equalToSuperview().offset(1.5)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(10)
        }
        nameTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(13)
            make.top.equalToSuperview().offset(18)
            make.width.equalTo(53)
            make.height.equalTo(18)
        }
        nameContent.snp.makeConstraints { (make) in
            make.left.equalTo(nameTitle.snp.right).offset(15)
            make.right.equalToSuperview().offset(-44)
            make.top.equalTo(nameTitle)
            make.height.greaterThanOrEqualTo(18)
        }
        addressTitle.snp.makeConstraints { (make) in
            make.top.equalTo(nameContent.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(13)
            make.width.equalTo(nameTitle)
            make.height.equalTo(nameTitle)
        }
        addressContent.snp.makeConstraints { (make) in
            make.left.equalTo(addressTitle.snp.right).offset(15)
            make.right.equalToSuperview().offset(-44)
            make.top.equalTo(addressTitle)
            make.height.greaterThanOrEqualTo(18)
        }
        designerTitle.snp.makeConstraints { (make) in
            make.top.equalTo(addressContent.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(13)
            make.width.equalTo(nameTitle)
            make.height.equalTo(nameTitle)
        }
        designerContent.snp.makeConstraints { (make) in
            make.left.equalTo(designerTitle.snp.right).offset(15)
            make.right.equalToSuperview().offset(-44)
            make.top.equalTo(designerTitle)
            make.height.greaterThanOrEqualTo(18)
        }
        storeTitle.snp.makeConstraints { (make) in
            make.top.equalTo(designerContent.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(13)
            make.width.equalTo(nameTitle)
            make.height.equalTo(nameTitle)
        }
        storeContent.snp.makeConstraints { (make) in
            make.left.equalTo(storeTitle.snp.right).offset(15)
            make.right.equalToSuperview().offset(-44)
            make.top.equalTo(storeTitle)
            make.height.greaterThanOrEqualTo(18)
            make.bottom.equalToSuperview().offset(-18).priority(800)
        }
        selectImgView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
    }
    
    @objc private func selectItem(sender: UITapGestureRecognizer) {
        delegate?.selectItem(index: self.index)
    }
    
    lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 3.0
        view.layer.masksToBounds = true
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESERPMatchCell.selectItem(sender:)))
        view.addGestureRecognizer(tgr)
        view.addSubview(leftTopView)
        view.addSubview(nameTitle)
        view.addSubview(nameContent)
        view.addSubview(addressTitle)
        view.addSubview(addressContent)
        view.addSubview(designerTitle)
        view.addSubview(designerContent)
        view.addSubview(storeTitle)
        view.addSubview(storeContent)
        view.addSubview(selectImgView)
        return view
    }()
    
    /// 左上角三角
    lazy var leftTopView: UIImageView = {
        let imgView = UIImageView()
        imgView.addSubview(leftTopLabel)
        return imgView
    }()
    
    /// 左上角编号
    lazy var leftTopLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .medium, size: 13.0)
        label.textColor = UIColor.white
        return label
    }()
    
    /// 业主姓名
    lazy var nameTitle: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.text = "业主姓名"
        return label
    }()
    
    lazy var nameContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.numberOfLines = 0
        return label
    }()
    
    /// 项目地址
    lazy var addressTitle: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.text = "项目地址"
        return label
    }()
    
    lazy var addressContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.numberOfLines = 0
        return label
    }()
    
    /// 设计师
    lazy var designerTitle: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.text = "设计师"
        return label
    }()
    
    lazy var designerContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.numberOfLines = 0
        return label
    }()
    
    /// 服务门店
    lazy var storeTitle: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.text = "服务门店"
        return label
    }()
    
    lazy var storeContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var selectImgView: UIImageView = {
        let imgView = UIImageView()
        return imgView
    }()
}
