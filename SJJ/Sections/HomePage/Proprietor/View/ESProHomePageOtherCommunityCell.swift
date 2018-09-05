//
//  ESProHomePageOtherCommunityCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/28.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit
import Kingfisher

class ESProHomePageOtherCommunityCell: UICollectionViewCell, ESProHomePageCellCommonProtocol {
    var delegate: ESProHomePageCommonCellDelegate?
    
    func updateCell(_ indexPath: IndexPath) {
        let options: KingfisherOptionsInfo = [.transition(.fade(1.0))]
        if let model = delegate?.getOtherData(indexPath.item) {
            let imgUrl = URL(string: ESStringUtil.getAlyImage(.Large_WW, model.extend_dic?.image))
            imgView.kf.setImage(with: imgUrl,
                                placeholder: UIImage(named: "defaultPlaceholder"),
                                options: options,
                                progressBlock: nil,
                                completionHandler: nil)
            
            let avatarUrl = URL(string: ESStringUtil.getAlyImage(.Large_WW, model.extend_dic?.author_avatar))
            avatarImgView.kf.setImage(with: avatarUrl,
                                      placeholder: UIImage(named: "default_header"),
                                      options: options,
                                      progressBlock: nil,
                                      completionHandler: nil)
            
            designerName.text = model.title
            likeLabel.text = String(model.likeCount ?? 0)
            commentLabel.text = String(model.commentCount ?? 0)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        contentView.addSubview(imgView)
        imgView.addSubview(imgTagView)
        contentView.addSubview(avatarImgView)
        contentView.addSubview(designerName)
        contentView.addSubview(commentLabel)
        contentView.addSubview(commentImgView)
        contentView.addSubview(likeLabel)
        contentView.addSubview(likeImgView)
        contentView.addSubview(lineView)
        
        imgView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(15.scalValue)
            make.right.equalToSuperview().offset(-15.scalValue)
            make.height.equalTo(123.scalValue)
        }
        imgTagView.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.height.equalTo(15)
        }
        imgTagLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5).priority(800)
            make.width.greaterThanOrEqualTo(10)
        }
        avatarImgView.snp.makeConstraints { (make) in
            make.width.height.equalTo(36.scalValue)
            make.top.equalTo(imgView.snp.bottom).offset(17.scalValue)
            make.left.equalTo(imgView)
        }
        designerName.snp.makeConstraints { (make) in
            make.centerY.equalTo(avatarImgView)
            make.left.equalTo(avatarImgView.snp.right).offset(10.scalValue)
            make.height.equalTo(21.scalValue)
            make.right.equalTo(likeImgView.snp.left).offset(-10.scalValue)
        }
        designerName.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
        commentLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(avatarImgView)
            make.right.equalTo(imgView)
            make.width.greaterThanOrEqualTo(10)
            make.height.equalTo(17)
        }
        commentImgView.snp.makeConstraints { (make) in
            make.right.equalTo(commentLabel.snp.left).offset(-10.scalValue)
            make.width.height.equalTo(17)
            make.centerY.equalTo(commentLabel)
        }
        likeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(commentImgView.snp.left).offset(-21.scalValue)
            make.height.equalTo(commentLabel)
            make.width.greaterThanOrEqualTo(10)
            make.centerY.equalTo(commentLabel)
        }
        likeImgView.snp.makeConstraints { (make) in
            make.right.equalTo(likeLabel.snp.left).offset(-10.scalValue)
            make.centerY.equalTo(commentLabel)
            make.width.height.equalTo(17)
        }
        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(10)
        }
    }
    
    private lazy var imgView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 2.0
        return view
    }()
    
    private lazy var imgTagView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2.0
        view.backgroundColor = ESColor.color(hexColor: 0xFFAD90, alpha: 1.0)
        view.addSubview(imgTagLabel)
        return view
    }()
    
    private lazy var imgTagLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .light, size: 10.0)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "社区"
        return label
    }()
    
    private lazy var avatarImgView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 36.scalValue / 2.0
        return view
    }()
    
    private lazy var designerName: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .medium, size: 15.0)
        label.textColor = ESColor.color(hexColor: 0x222222, alpha: 1.0)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    private lazy var likeImgView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "home_like")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var likeLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .light, size: 12.0)
        label.textColor = ESColor.color(hexColor: 0x999999, alpha: 1.0)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var commentImgView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "home_comment")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .light, size: 12.0)
        label.textColor = ESColor.color(hexColor: 0x999999, alpha: 1.0)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(hexColor: 0xEEEEEE, alpha: 1.0)
        return view
    }()
}

