//
//  ESProHomePageOtherADCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/28.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit
import Kingfisher

class ESProHomePageOtherADCell: UICollectionViewCell, ESProHomePageCellCommonProtocol {
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
        view.backgroundColor = ESColor.color(hexColor: 0x999999, alpha: 1.0)
        view.addSubview(imgTagLabel)
        return view
    }()
    
    private lazy var imgTagLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .light, size: 10.0)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "广告"
        return label
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(hexColor: 0xEEEEEE, alpha: 1.0)
        return view
    }()
}

