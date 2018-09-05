//
//  ESProHomePageCaseCell.swift
//  Consumer
//
//  Created by Jiao on 2018/3/3.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//  推荐的案例

import UIKit
import Kingfisher

class ESProHomePageCaseCell: UICollectionViewCell {
    var caseModel: ESProHomePageCase = ESProHomePageCase() {
        didSet {
            let options: KingfisherOptionsInfo = [.transition(.fade(1.0))]
            let imgUrl = URL(string:  ESStringUtil.getAlyImage(.Large_WW, caseModel.cover))
            caseImgView.kf.setImage(with: imgUrl,
                                    placeholder: UIImage(named: "equal_default"),
                                    options: options,
                                    progressBlock: nil,
                                    completionHandler: nil)
            caseName.text = caseModel.case_name
            let avatarUrl = URL(string: ESStringUtil.getAlyImage(.Large_WW, caseModel.designer_image))
            avatarImgView.kf.setImage(with: avatarUrl,
                                      placeholder: UIImage(named: "default_header"),
                                      options: options,
                                      progressBlock: nil,
                                      completionHandler: nil)
            designerName.text = caseModel.designer_name
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    private func setUpView() {
        contentView.backgroundColor = .white
        contentView.addSubview(caseImgView)
        contentView.addSubview(caseName)
        contentView.addSubview(avatarImgView)
        contentView.addSubview(designerName)
        
        caseImgView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(115.scalValue)
        }
        caseName.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(caseImgView.snp.bottom).offset(4.scalValue)
            make.height.equalTo(20.scalValue)
        }
        avatarImgView.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.width.height.equalTo(21.scalValue)
        }
        designerName.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImgView.snp.right).offset(10.scalValue)
            make.height.equalTo(14)
            make.right.equalToSuperview().offset(-10.scalValue)
            make.centerY.equalTo(avatarImgView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var caseImgView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .white
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 2.0
        return view
    }()
    
    private lazy var caseName: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.isOpaque = true
        label.textColor = ESColor.color(hexColor: 0x2D2D34, alpha: 1.0)
        label.font = ESFont.font(name: .medium, size: 14.0)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    private lazy var avatarImgView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 21.scalValue / 2.0
        return view
    }()
    
    private lazy var designerName: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = ESColor.color(hexColor: 0x4A4A4A, alpha: 1.0)
        label.font = ESFont.font(name: .regular, size: 10.0)
        return label
    }()
}
