//
//  ESProHomePageNaviSectionView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/3/1.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESProHomePageNaviSectionView: UICollectionReusableView {
    var lineViewColor: UIColor = .white {
        didSet {
            lineView.backgroundColor = lineViewColor
        }
    }
    var height: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView() {
        self.addSubview(lineView)
        lineView.backgroundColor = lineViewColor
        lineView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
    
    lazy var lineView: UIView = {
        let view = UIView()
        return view
    }()
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let w = ESDeviceUtil.screen_w
        let h = height.scalValue
        attributes.size = CGSize(width: w, height: h)
        return attributes
    }
}
