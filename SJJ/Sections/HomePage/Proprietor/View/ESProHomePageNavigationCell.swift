//
//  ESProHomePageNavigationCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/28.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//  导航类目

import UIKit
import Kingfisher

protocol ESProHomePageNavigationCellDelegate: NSObjectProtocol {
    func getNavigaionData(_ indexPath: IndexPath) -> (img: String?, title: String?)
}

class ESProHomePageNavigationCell: UICollectionViewCell, ESProHomePageCellCommonProtocol {
    var delegate: ESProHomePageCommonCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(_ indexPath: IndexPath) {
        if let navi = delegate?.getNavigaionData(indexPath) {
            let url = URL(string: navi.img ?? "")
            let placeHolder = UIImage(named: "home_page_item_default")
            let options: KingfisherOptionsInfo = [.transition(.fade(1.0))]
            imgView.kf.setImage(with: url,
                                placeholder: placeHolder,
                                options: options,
                                progressBlock: nil,
                                completionHandler: nil)
            
            textLabel.text = navi.title
        }
    }
    
    private func setUpView() {
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15.scalValue)
            let w = 21.scalValue
            make.width.height.equalTo(w)
            make.centerX.equalToSuperview()
        }
        contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(-5)
            make.left.right.equalToSuperview()
            make.height.equalTo(14)
        }
    }
    
    private lazy var imgView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textAlignment = .center
        label.font = ESFont.font(name: .regular, size: 9.0)
        label.textColor = ESColor.color(hexColor: 0x222222, alpha: 1.0)
        return label
    }()
    
}
