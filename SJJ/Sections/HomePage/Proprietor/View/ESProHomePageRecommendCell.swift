//
//  ESProHomePageRecommendCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/28.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//  推荐栏位

import UIKit
import SnapKit
import Kingfisher

protocol ESProHomePageRecommendCellDelegate: NSObjectProtocol {
    func didSelectRecommend(_ index: Int)
    func getRecommend() -> [ESProHomePageCommon]?
    func needReload() -> Bool
}

class ESProHomePageRecommendCell: UICollectionViewCell, ESProHomePageCellCommonProtocol {
    var delegate: ESProHomePageCommonCellDelegate?
    var topConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(_ indexPath: IndexPath) {
        if let refresh = delegate?.needReload(), refresh {
            if let recommandArr = delegate?.getRecommend() {
                for (index, recommand) in recommandArr.enumerated() {
                    let options: KingfisherOptionsInfo = [.transition(.fade(1.0))]
                    switch index {
                    case 0:
                        let imgUrl = URL(string: recommand.extend_dic?.image ?? "")
                        imgView1.kf.setImage(with: imgUrl,
                                             placeholder: UIImage(named: "home_page_recommend_design_degault"),
                                             options: options,
                                             progressBlock: nil,
                                             completionHandler: nil)
                        if recommand.operation_type == "DESIGN_DETAIL" {
                            title1.text = "我的装修项目"
                            subTitle1.text = recommand.extend_dic?.title
                            topConstraint?.update(offset: 13.scalValue)
                            statusLable.isHidden = false
                            statusLable.text = recommand.extend_dic?.status
                            avatarView.isHidden = false
                            let url = URL(string: recommand.extend_dic?.designerAvatar ?? "")
                            avatarView.kf.setImage(with: url,
                                                   placeholder: ESPackageAsserts.bundleImage(named: "default_header"),
                                                   options: options,
                                                   progressBlock: nil,
                                                   completionHandler: nil)
                            
                        } else {
                            title1.text = recommand.title
                            subTitle1.text = recommand.subTitle
                            topConstraint?.update(offset: 44.scalValue)
                            statusLable.isHidden = true
                            avatarView.isHidden = true
                        }
                    case 1:
                        let imgUrl = URL(string: recommand.extend_dic?.image ?? "")
                        imgView2.kf.setImage(with: imgUrl,
                                             placeholder: UIImage(named: "home_page_recommend_design_degault"),
                                             options: options,
                                             progressBlock: nil,
                                             completionHandler: nil)
                        title2.text = recommand.title
                        subTitle2.text = recommand.subTitle
                    case 2:
                        let imgUrl = URL(string: recommand.extend_dic?.image ?? "")
                        imgView3.kf.setImage(with: imgUrl,
                                             placeholder: UIImage(named: "home_page_recommend_design_degault"),
                                             options: options,
                                             progressBlock: nil,
                                             completionHandler: nil)
                        title3.text = recommand.title
                        subTitle3.text = recommand.subTitle
                    case 3:
                        let imgUrl = URL(string: recommand.extend_dic?.image ?? "")
                        imgView4.kf.setImage(with: imgUrl,
                                             placeholder: UIImage(named: "home_page_recommend_design_degault"),
                                             options: options,
                                             progressBlock: nil,
                                             completionHandler: nil)
                        title4.text = recommand.title
                        subTitle4.text = recommand.subTitle
                    default:
                        break
                    }
                }
            }
        }
    }
    
    @objc private func tapView(_ sender: UITapGestureRecognizer) {
        if let tag = sender.view?.tag {
            let index = tag - 500
            delegate?.didSelectRecommend(index)
        }
    }
    
    private func setUpView() {
        contentView.backgroundColor = ESColor.color(hexColor: 0xCCCCCC, alpha: 1.0)
        contentView.addSubview(view1)
        setView1Constraint()
        contentView.addSubview(view2)
        setView2Constraint()
        contentView.addSubview(view3)
        setView3Constraint()
        contentView.addSubview(view4)
        setView4Constraint()
    }
    
    private func setView1Constraint() {
        view1.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(1)
            make.bottom.equalToSuperview().offset(-1)
            make.width.equalTo(152.scalValue)
        }
        title1.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(13.scalValue)
            make.left.equalToSuperview().offset(15.scalValue)
            make.right.equalToSuperview().offset(-15.scalValue)
            make.height.equalTo(25.scalValue)
        }
        subTitle1.snp.makeConstraints { (make) in
            make.top.equalTo(title1.snp.bottom).offset(5.scalValue)
            make.left.equalTo(title1)
            make.right.equalTo(title1)
            make.height.equalTo(19.scalValue)
        }
        imgView1.snp.makeConstraints { (make) in
            topConstraint =  make.top.equalTo(subTitle1.snp.bottom).offset(13.scalValue).constraint
            make.left.equalTo(title1)
            make.width.equalTo(80.scalValue)
            make.height.equalTo(50.scalValue)
        }
        statusLable.snp.makeConstraints { (make) in
            make.top.equalTo(imgView1.snp.bottom).offset(11.scalValue)
            make.left.equalTo(title1)
            make.right.equalTo(avatarView.snp.left).offset(-5.scalValue)
            make.bottom.equalToSuperview().offset(-10.scalValue).priority(800)
        }
        avatarView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15.scalValue)
            make.width.height.equalTo(21.scalValue)
            make.centerY.equalTo(statusLable)
        }
    }
    
    private func setView2Constraint() {
        view2.snp.makeConstraints { (make) in
            make.left.equalTo(view1.snp.right).offset(1)
            make.top.equalToSuperview().offset(1)
            make.right.equalToSuperview()
            make.bottom.equalTo(view1.snp.centerY).offset(-0.5)
        }
        imgView2.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(10.scalValue)
            make.bottom.equalToSuperview().offset(-10.scalValue)
            make.width.equalTo(102.scalValue)
        }
        title2.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10.scalValue)
            make.top.equalToSuperview().offset(6.scalValue)
            make.left.equalToSuperview().offset(10.scalValue)
            make.height.equalTo(21.scalValue)
        }
        subTitle2.snp.makeConstraints { (make) in
            make.top.equalTo(title2.snp.bottom)
            make.left.right.equalTo(title2)
            make.height.equalTo(17.scalValue)
        }
    }
    
    private func setView3Constraint() {
        view3.snp.makeConstraints { (make) in
            make.left.equalTo(view1.snp.right).offset(1)
            make.top.equalTo(view2.snp.bottom).offset(1)
            make.right.equalTo(view2.snp.centerX).offset(-0.5)
            make.bottom.equalToSuperview().offset(-1)
        }
        title3.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(6.scalValue)
            make.right.equalToSuperview().offset(-10.scalValue)
            make.left.equalToSuperview().offset(10.scalValue)
            make.height.equalTo(17.scalValue)
        }
        subTitle3.snp.makeConstraints { (make) in
            make.top.equalTo(title3.snp.bottom)
            make.left.right.equalTo(title3)
            make.height.equalTo(14.scalValue)
        }
        imgView3.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10.scalValue)
            make.top.equalTo(subTitle3.snp.bottom).offset(5.scalValue)
            make.bottom.equalToSuperview().offset(-5.scalValue)
            make.width.equalTo(65.scalValue)
        }
    }
    
    private func setView4Constraint() {
        view4.snp.makeConstraints { (make) in
            make.left.equalTo(view3.snp.right).offset(1)
            make.top.equalTo(view3)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-1)
        }
        title4.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(6.scalValue)
            make.right.equalToSuperview().offset(-10.scalValue)
            make.left.equalToSuperview().offset(10.scalValue)
            make.height.equalTo(17.scalValue)
        }
        subTitle4.snp.makeConstraints { (make) in
            make.top.equalTo(title4.snp.bottom)
            make.left.right.equalTo(title4)
            make.height.equalTo(14.scalValue)
        }
        imgView4.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10.scalValue)
            make.top.equalTo(subTitle4.snp.bottom).offset(5.scalValue)
            make.bottom.equalToSuperview().offset(-5.scalValue)
            make.width.equalTo(65.scalValue)
        }
    }
    
    /// view1
    private lazy var view1: UIView = {
        let view = UIView()
        view.tag = 500
        view.backgroundColor = .white
        view.addSubview(title1)
        view.addSubview(subTitle1)
        view.addSubview(imgView1)
        view.addSubview(statusLable)
        view.addSubview(avatarView)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(tapView(_:)))
        view.addGestureRecognizer(tgr)
        return view
    }()
    
    private lazy var title1: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = ESColor.color(hexColor: 0x222222, alpha: 1.0)
        label.font = ESFont.font(name: .medium, size: 18)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var subTitle1: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = ESColor.color(hexColor: 0x7A7B87, alpha: 1.0)
        label.font = ESFont.font(name: .regular, size: 13)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var imgView1: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var statusLable: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = ESColor.color(hexColor: 0x999999, alpha: 1.0)
        label.font = ESFont.font(name: .medium, size: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var avatarView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 21.scalValue / 2.0
        return view
    }()
    
    /// view2
    private lazy var view2: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.tag = 501
        view.addSubview(imgView2)
        view.addSubview(title2)
        view.addSubview(subTitle2)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(tapView(_:)))
        view.addGestureRecognizer(tgr)
        return view
    }()
    
    private lazy var imgView2: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var title2: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(hexColor: 0x222222, alpha: 1.0)
        label.font = ESFont.font(name: .regular, size: 15)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var subTitle2: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(hexColor: 0x999999, alpha: 1.0)
        label.font = ESFont.font(name: .regular, size: 12)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    /// view3
    private lazy var view3: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.tag = 502
        view.addSubview(imgView3)
        view.addSubview(title3)
        view.addSubview(subTitle3)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(tapView(_:)))
        view.addGestureRecognizer(tgr)
        return view
    }()
    
    private lazy var imgView3: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var title3: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = ESColor.color(hexColor: 0x222222, alpha: 1.0)
        label.font = ESFont.font(name: .regular, size: 12)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var subTitle3: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = ESColor.color(hexColor: 0x999999, alpha: 1.0)
        label.font = ESFont.font(name: .regular, size: 10)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    /// view2
    private lazy var view4: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.tag = 503
        view.addSubview(imgView4)
        view.addSubview(title4)
        view.addSubview(subTitle4)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(tapView(_:)))
        view.addGestureRecognizer(tgr)
        return view
    }()
    
    private lazy var imgView4: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var title4: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = ESColor.color(hexColor: 0x222222, alpha: 1.0)
        label.font = ESFont.font(name: .regular, size: 12)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var subTitle4: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = ESColor.color(hexColor: 0x999999, alpha: 1.0)
        label.font = ESFont.font(name: .regular, size: 10)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
}

