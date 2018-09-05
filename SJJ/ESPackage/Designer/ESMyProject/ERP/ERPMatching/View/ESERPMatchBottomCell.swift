//
//  ESERPMatchBottomCell.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/29.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

protocol ESERPMatchBottomCellDelegate: NSObjectProtocol {
    func tapSearchERP()
    func tapCreateERP()
}

class ESERPMatchBottomCell: UITableViewCell {
    weak var delegate: ESERPMatchBottomCellDelegate?
    
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
    
    private func addSubviews() {
        self.contentView.addSubview(separatorLine1)
        self.contentView.addSubview(searchBackView)
        self.contentView.addSubview(separatorLine2)
        self.contentView.addSubview(createBackView)
        self.contentView.addSubview(separatorLine3)
    }
    
    private func setConstraint() {
        separatorLine1.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        searchBackView.snp.makeConstraints { (make) in
            make.top.equalTo(separatorLine1.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(55)
        }
        searchTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(125)
            make.centerY.equalToSuperview()
        }
        searchImgView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(3.5)
            make.height.equalTo(9)
        }
        searchContent.snp.makeConstraints { (make) in
            make.right.equalTo(searchImgView.snp.left).offset(-9)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(50)
            make.centerY.equalToSuperview()
        }
        
        separatorLine2.snp.makeConstraints { (make) in
            make.top.equalTo(searchBackView.snp.bottom)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        createBackView.snp.makeConstraints { (make) in
            make.top.equalTo(separatorLine2.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(55)
        }
        createTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(125)
            make.centerY.equalToSuperview()
        }
        createImgView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(3.5)
            make.height.equalTo(9)
        }
        createContent.snp.makeConstraints { (make) in
            make.right.equalTo(createImgView.snp.left).offset(-9)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(50)
            make.centerY.equalToSuperview()
        }
        
        separatorLine3.snp.makeConstraints { (make) in
            make.top.equalTo(createBackView.snp.bottom)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview().offset(-80).priority(800)
        }
    }
    
    @objc private func tapERPSearchView(sender: UITapGestureRecognizer) {
        delegate?.tapSearchERP()
    }
    
    @objc private func tapERPCreateView(sender: UITapGestureRecognizer) {
        delegate?.tapCreateERP()
    }
    
    private lazy var separatorLine1: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .separatorLine)
        return view
    }()
    
    private lazy var separatorLine2: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .separatorLine)
        return view
    }()
    
    private lazy var separatorLine3: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .separatorLine)
        return view
    }()
    
    private lazy var searchBackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESERPMatchBottomCell.tapERPSearchView(sender:)))
        view.addGestureRecognizer(tgr)
        view.addSubview(searchTitle)
        view.addSubview(searchContent)
        view.addSubview(searchImgView)
        return view
    }()
    
    private lazy var searchTitle: UILabel = {
        let label = UILabel()
        label.text = "没有查询到ERP编号?"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    private lazy var searchContent: UILabel = {
        let label = UILabel()
        label.text = "手动查询ERP编号"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .buttonBlue)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var searchImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = ESPackageAsserts.bundleImage(named: "arrow_right")
        return imgView
    }()
    
    private lazy var createBackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESERPMatchBottomCell.tapERPCreateView(sender:)))
        view.addGestureRecognizer(tgr)
        view.addSubview(createTitle)
        view.addSubview(createContent)
        view.addSubview(createImgView)
        return view
    }()
    
    private lazy var createTitle: UILabel = {
        let label = UILabel()
        label.text = " ERP中还没有项目信息?"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    private lazy var createContent: UILabel = {
        let label = UILabel()
        label.text = "去创建"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .buttonBlue)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var createImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = ESPackageAsserts.bundleImage(named: "arrow_right")
        return imgView
    }()
}
