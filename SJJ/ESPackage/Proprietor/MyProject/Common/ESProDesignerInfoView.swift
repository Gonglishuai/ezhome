//
//  ESProDesignerInfoView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/8.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit
import Kingfisher

protocol ESProDesignerInfoViewDelegate: NSObjectProtocol {
    func designerDetailInfo()
    func contactDesigner()
}

class ESProDesignerInfoView: UIView {

    weak var delegate: ESProDesignerInfoViewDelegate?
    
    init(delegate: ESProDesignerInfoViewDelegate?) {
        super.init(frame: .zero)
        self.delegate = delegate
        
        setUpView()
        addConstraints()
    }
    
    func updateView(header: String?, name: String?) {
        let url = URL(string: header ?? "")
        let options: KingfisherOptionsInfo = [.transition(.fade(1.0))]
        headerView.kf.setImage(with: url, placeholder: ESPackageAsserts.bundleImage(named: "default_header"), options: options, progressBlock: nil, completionHandler: nil)
        
        nameLabel.text = name ?? "--"
    }
    
    @objc func contactHimBtnClick() {
        delegate?.contactDesigner()
    }
    
    @objc func detailTap() {
        delegate?.designerDetailInfo()
    }
    
    private func setUpView() {
        self.backgroundColor = UIColor.white
        self.addSubview(backView)
        self.addSubview(tagView)
        self.addSubview(headerView)
        self.addSubview(nameLabel)
        self.addSubview(contactHimBtn)
        self.addSubview(homeLabel)
        self.addSubview(rightImgView)
    }
    
    private func addConstraints() {
        backView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalToSuperview()
        }
        tagView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(-0.5)
            make.height.equalTo(21)
            make.width.equalTo(57)
        }
        headerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(50)
            make.bottom.equalToSuperview().offset(-20).priority(800)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        rightImgView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(headerView)
            make.width.equalTo(5)
            make.height.equalTo(10)
        }
        homeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(rightImgView.snp.left).offset(-6)
            make.height.equalTo(18.5)
            make.width.equalTo(65)
            make.centerY.equalTo(headerView)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(headerView.snp.right).offset(10)
            make.right.equalTo(homeLabel.snp.left).offset(-10)
            make.height.equalTo(22.5)
            make.centerY.equalTo(headerView)
        }
        contactHimBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(72)
            make.height.equalTo(48.5)
        }
    }
    
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.shadowOpacity = 1.0
        view.layer.shadowColor = ESColor.color(hexColor: 0x000000, alpha: 0.05).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 6.5
        view.layer.cornerRadius = 3.0
        view.layer.borderColor = ESColor.color(sample: .separatorLine).cgColor
        view.layer.borderWidth = 0.5
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESProDesignerInfoView.detailTap))
        view.addGestureRecognizer(tgr)
        return view
    }()
    
    private lazy var tagView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = ESPackageAsserts.bundleImage(named: "project_designer_tag")
        return imgView
    }()
    
    private lazy var headerView: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = 25.0
        imgView.layer.masksToBounds = true
        return imgView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .medium, size: 16.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    private lazy var contactHimBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("联系TA", for: .normal)
        btn.setTitleColor(ESColor.color(sample: .buttonBlue), for: .normal)
        btn.titleLabel?.font = ESFont.font(name: .regular, size: 13.0)
        btn.addTarget(self, action: #selector(ESProDesignerInfoView.contactHimBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var homeLabel: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.text = "设计师主页"
        label.textAlignment = .right
        return label
    }()
    
    private lazy var rightImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = ESPackageAsserts.bundleImage(named: "arrow_right")
        return imgView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
