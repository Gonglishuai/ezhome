//
//  ESEvaluateSecondCollectionViewCell.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/31.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESEvaluateSecondCollectionViewCellProtocol:NSObjectProtocol {
    func getTagTitle(index: Int) -> String?
    ///选中了评价？
    func selectedEvaluate(selected:Bool, cellIndex:Int)
}

class ESEvaluateSecondCollectionViewCell: UICollectionViewCell {
    
    private lazy var evaluateButton: UIButton = {
        
        let button = UIButton()
        
        button.setTitleColor(ESColor.color(sample: .subTitleColorB), for: .normal)
        button.titleLabel?.font = ESFont.font(name: .regular, size: 12)
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 2
        button.layer.borderColor = ESColor.color(hexColor: 0xDCDFE6, alpha: 1).cgColor
        button.layer.borderWidth = 0.5
        
        return button
    }()
    private var hasSelected = false
    
    private weak var cellDelegate:ESEvaluateSecondCollectionViewCellProtocol?
    
    private var cellIndex = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(evaluateButton)
        
        evaluateButton.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        evaluateButton.addTarget(self, action: #selector(selectEvaluate), for: .touchUpInside)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCellDelegate(delegate:ESEvaluateSecondCollectionViewCellProtocol?, cellIndex:Int){
        self.cellDelegate = delegate
        self.cellIndex = cellIndex
        let title = delegate?.getTagTitle(index: cellIndex)
        evaluateButton.setTitle(title, for: .normal)
    }
    
    @objc func selectEvaluate(){
        
        if let delegate = self.cellDelegate {
            
            if hasSelected {
                
                evaluateButton.setTitleColor(ESColor.color(sample: .subTitleColorB), for: .normal)
                evaluateButton.backgroundColor = UIColor.white
                evaluateButton.layer.borderColor = ESColor.color(hexColor: 0xDCDFE6, alpha: 1).cgColor
                delegate.selectedEvaluate(selected: false, cellIndex: cellIndex)
                
            } else {
                
                evaluateButton.setTitleColor(ESColor.color(hexColor: 0x36B6E4, alpha: 1), for: .normal)
                evaluateButton.backgroundColor = ESColor.color(hexColor: 0xEEFBFF, alpha: 1)
                evaluateButton.layer.borderColor = ESColor.color(hexColor: 0x36B6E4, alpha: 1).cgColor
                delegate.selectedEvaluate(selected: true, cellIndex: cellIndex)
                
            }
            hasSelected = !hasSelected
        }
        
    }
    
}
