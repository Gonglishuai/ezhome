//
//  ESEvaluateThirdCollectionViewCell.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/31.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESEvaluateThirdCollectionViewCellProtocol: NSObjectProtocol {
    func getStarTitle(index: Int) -> String?
    ///评价得分
    func evaluateScore(score:Int, cellIndex:Int)
}

class ESEvaluateThirdCollectionViewCell: UICollectionViewCell {
    
    private lazy var leftLabel: UILabel = {
        
        let label = UILabel()
        
        label.textColor = ESColor.color(hexColor: 0x9B9B9B, alpha: 1)
        label.font = ESFont.font(name: .regular, size: 13)
        
        return label
    }()
    
    private lazy var starView = ESStarView()
    private weak var cellDelegate:ESEvaluateThirdCollectionViewCellProtocol?
    private var cellIndex = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(leftLabel)
        
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(22.5.scalValue)
            make.top.equalTo(20.scalValue)
            make.height.equalTo(18.5.scalValue)
        }
        
        self.addSubview(starView)
        
        starView.snp.makeConstraints { (make) in
            make.left.equalTo(100.scalValue)
            make.centerY.equalTo(leftLabel.snp.centerY)
            make.size.equalTo(CGSize(width: 200.scalValue, height: 15.scalValue))
        }
        starView.tapBlock { (index) in
            if let delegate = self.cellDelegate {
                delegate.evaluateScore(score: index, cellIndex: self.cellIndex)
            }
        }
    }
    
    func setCellDelegate(delegate:ESEvaluateThirdCollectionViewCellProtocol?, cellIndex:Int){
        self.cellDelegate = delegate
        self.cellIndex = cellIndex
        let title = delegate?.getStarTitle(index: cellIndex)
        leftLabel.text = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
