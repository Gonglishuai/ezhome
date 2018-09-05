//
//  ESProHomePageSampleRoomCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/28.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//  套餐样板间

import UIKit
import Kingfisher

protocol ESProHomePageSampleRoomCellDelegate: NSObjectProtocol {
    func getSampleData(_ index: Int) -> ESProHomePageSample?
}

class ESProHomePageSampleRoomCell: UICollectionViewCell, ESProHomePageCellCommonProtocol {
    var delegate: ESProHomePageCommonCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(_ indexPath: IndexPath) {
        if let model = delegate?.getSampleData(indexPath.item) {
            let options: KingfisherOptionsInfo = [.transition(.fade(1.0))]
            let imgUrl = URL(string: model.sampleroom_image ?? "")
            imageView.kf.setImage(with: imgUrl,
                                  placeholder: UIImage(named: "equal_default"),
                                  options: options,
                                  progressBlock: nil,
                                  completionHandler: nil)
            typeImgView.isHidden = model.case_type != "3d"
            sampleName.text = model.sampleroom_name
            descLabel.text = model.description
            priceLabel.text = model.price
            if ESStringUtil.isEmpty(model.package_name) {
                tagBackView.isHidden = true
            } else {
                tagLabel.text = model.package_name
            }
            let avatarUrl = URL(string: model.designer_image ?? "")
            avatarImg.kf.setImage(with: avatarUrl,
                                  placeholder: UIImage(named: "default_header"),
                                  options: options,
                                  progressBlock: nil,
                                  completionHandler: nil)
            designerNameLabel.text = model.designer_name
        }
    }
    
    func setUpView() {
        contentView.addSubview(imageView)
        imageView.addSubview(typeImgView)
        contentView.addSubview(lineView)
        contentView.addSubview(sampleName)
        contentView.addSubview(descLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(priceRightLabel)
        contentView.addSubview(tagBackView)
        tagBackView.addSubview(tagLabel)
        contentView.addSubview(avatarImg)
        contentView.addSubview(designerNameLabel)
        imageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(7.scalValue)
            make.left.equalToSuperview().offset(15.scalValue)
            make.bottom.equalTo(lineView.snp.top).offset(-15.scalValue)
            make.width.equalTo(162.scalValue)
        }
        typeImgView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.width.equalTo(30)
            make.height.equalTo(12)
        }
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(imageView)
            make.right.equalToSuperview().offset(-15.scalValue)
            make.bottom.equalToSuperview().offset(-8.scalValue)
            make.height.equalTo(1)
        }
        sampleName.snp.makeConstraints { (make) in
            make.left.equalTo(imageView.snp.right).offset(15.scalValue)
            make.top.equalToSuperview().offset(4.scalValue)
            make.right.equalToSuperview().offset(-15.scalValue)
            make.height.equalTo(21.scalValue)
        }
        descLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(sampleName)
            make.top.equalTo(sampleName.snp.bottom).offset(14.scalValue)
            make.height.greaterThanOrEqualTo(10)
//            make.height.lessThanOrEqualTo(50.scalValue)
        }
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(sampleName)
            make.top.equalTo(descLabel.snp.bottom).offset(17.scalValue)
            make.height.equalTo(27.scalValue)
            make.width.greaterThanOrEqualTo(10)
            make.width.lessThanOrEqualTo(111.scalValue)
        }
        priceRightLabel.snp.makeConstraints { (make) in
            make.left.equalTo(priceLabel.snp.right).offset(4.scalValue)
            make.height.equalTo(priceLabel)
            make.width.equalTo(30.scalValue)
            make.centerY.equalTo(priceLabel)
        }
        tagBackView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15.scalValue)
            make.centerY.equalTo(priceLabel)
            make.height.equalTo(14)
        }
        tagLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5).priority(800)
            make.width.greaterThanOrEqualTo(10)
        }
        avatarImg.snp.makeConstraints { (make) in
            make.left.equalTo(sampleName)
            make.bottom.equalTo(imageView)
            make.width.height.equalTo(21.scalValue)
        }
        designerNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImg.snp.right).offset(10.scalValue)
            make.height.equalTo(14)
            make.centerY.equalTo(avatarImg)
            make.right.equalToSuperview().offset(-15.scalValue)
        }
    }
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 2.0
        return view
    }()
    
    private lazy var typeImgView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "home_3d_tag")
        return view
    }()
    
    private lazy var sampleName: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.numberOfLines = 1
        label.font = ESFont.font(name: .regular, size: 15.0)
        label.textColor = ESColor.color(hexColor: 0x222222, alpha: 1.0)
        return label
    }()
    
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.numberOfLines = 3
        label.font = ESFont.font(name: .light, size: 12.0)
        label.textColor = ESColor.color(hexColor: 0x222222, alpha: 1.0)
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = ESColor.color(hexColor: 0xD0021B, alpha: 1.0)
        label.font = ESFont.font(name: .regular, size: 19.0)
        return label
    }()
    
    private lazy var priceRightLabel: UILabel = {
        let label = UILabel()
        label.text = "参考价"
        label.backgroundColor = .white
        label.textColor = ESColor.color(hexColor: 0x4A4A4A, alpha: 1.0)
        label.font = ESFont.font(name: .regular, size: 10.0)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var tagBackView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(hexColor: 0xEEEEEE, alpha: 1.0)
        view.layer.cornerRadius = 7.0
        return view
    }()
    
    private lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = ESColor.color(hexColor: 0x999999, alpha: 1.0)
        label.font = ESFont.font(name: .light, size: 9.0)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var avatarImg: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 21.scalValue / 2.0
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var designerNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(hexColor: 0x4A4A4A, alpha: 1.0)
        label.font = ESFont.font(name: .regular, size: 10.0)
        return label
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(hexColor: 0xCCCCCC, alpha: 1.0)
        return view
    }()
}

