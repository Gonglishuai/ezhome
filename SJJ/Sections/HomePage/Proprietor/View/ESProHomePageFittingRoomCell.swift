//
//  ESProHomePageFittingRoomCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/28.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//  推荐的家装试衣间

import UIKit
import Kingfisher


class ESProHomePageFittingRoomCell: UICollectionViewCell {
    
    var caseImg: String? {
        didSet {
            let options: KingfisherOptionsInfo = [.transition(.fade(1.0))]
            let imgUrl = URL(string: ESStringUtil.getAlyImage(.Large_WW, caseImg))
            imgView.kf.setImage(with: imgUrl,
                                placeholder: UIImage(named: "equal_default"),
                                options: options,
                                progressBlock: nil,
                                completionHandler: nil)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imgView)
        contentView.backgroundColor = .white
        imgView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(7.5.scalValue)
            make.right.bottom.equalToSuperview().offset(-7.5.scalValue)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var imgView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .white
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 2.0
        view.layer.masksToBounds = true
        return view
    }()
}

