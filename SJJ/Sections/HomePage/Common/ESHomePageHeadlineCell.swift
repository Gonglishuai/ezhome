//
//  ESHomePageHeadlineCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/3/2.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESHomePageHeadlineCellDelegate: NSObjectProtocol {
    func getText(_ indexPath: IndexPath) -> [String]
    func needReload() -> Bool
    func headlineSelect(_ index: Int)
}

class ESHomePageHeadlineCell: UICollectionViewCell {
    weak var delegate: ESHomePageHeadlineCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.addSubview(headerImg)
        headerImg.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.width.equalTo(45)
            make.height.equalTo(18)
        }
        
        contentView.addSubview(loopView)
        loopView.snp.makeConstraints { (make) in
            make.left.equalTo(headerImg.snp.right).offset(6)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(25)
        }
    }
    
    func updateCell(_ indexPath: IndexPath) {
        if let reload = delegate?.needReload(), reload {
            if let texts = delegate?.getText(indexPath) {
                let dataArray = texts.map({(content) -> ESCycleText in
                    let text = ESCycleText(text: content, font: ESFont.font(name: .regular, size: 13.0), alignment: .left)
                    return text
                })
                
                
                loopView.dataArray = dataArray
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var headerImg: UIImageView = {
        let view = UIImageView(image: UIImage(named: "home_page_headline"))
        return view
    }()
    
    fileprivate lazy var loopView: ESCycleScrollView = {
        let w = ESDeviceUtil.screen_w - (15 + 45 + 6 + 15)
        let h = CGFloat(25.0)
        let viewaF = CGRect(x: 0, y: 0, width: w, height: h)
        var view = ESCycleScrollView(delegate: self, type: .Text, frame: viewaF)
        view.direction = .vertical
        view.isAutoScroll = true
        view.autoScrollInterval = 4.5
        view.panGestureEnable = false
        return view
    }()
}

extension ESHomePageHeadlineCell: ESCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: ESCycleScrollView, didSelectItemAt indexPath: IndexPath) {
        delegate?.headlineSelect(indexPath.item)
    }
}
