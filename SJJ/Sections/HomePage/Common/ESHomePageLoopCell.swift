//
//  ESHomePageLoopCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/27.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESHomePageLoopCellDelegate: NSObjectProtocol {
    func getImages(_ indexPath: IndexPath) -> [String]
    func needReload() -> Bool
    func cycleViewDidSelect(_ index: Int)
}

class ESHomePageLoopCell: UICollectionViewCell {
    
    weak var delegate: ESHomePageLoopCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.addSubview(loopView)
        loopView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
    
    func updateCell(_ indexPath: IndexPath) {
        if let reload = delegate?.needReload(), reload {
            if let images = delegate?.getImages(indexPath) {
                let dataArray = images.map({(url) -> ESCycleImage in
                    let image = ESCycleImage(type: .Net(url: url), placeHolder: "default_banner")
                    return image
                })
                
                
                loopView.dataArray = dataArray
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var loopView: ESCycleScrollView = {
        let w = ESDeviceUtil.screen_w
        let h = 125.0 * w / 375.0
        let viewaF = CGRect(x: 0, y: 0, width: w, height: h)
        var view = ESCycleScrollView(delegate: self, type: .Image, frame: viewaF)
        view.isAutoScroll = true
        view.showPageControl = true
        view.currentDotColor = ESColor.color(hexColor: 0x6A91FE, alpha: 1.0)
        view.otherDotColor = ESColor.color(hexColor: 0xFFFFFF, alpha: 1.0)
        view.pageControl?.pointSpace = 30
        view.autoScrollInterval = 6.0
        return view
    }()
}

extension ESHomePageLoopCell: ESCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: ESCycleScrollView, didSelectItemAt indexPath: IndexPath) {
        delegate?.cycleViewDidSelect(indexPath.item)
    }
}
