//
//  ESSelectDiscountTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/27.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESSelectDiscountTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var discount: UIButton!
    
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    
    private var cellIndex:NSInteger = 0
    private weak var viewController:ESSelectDiscountViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        discount.layer.borderColor = ESColor.color(sample: .buttonRed).cgColor
        
        discount.addTarget(self, action: #selector(selectDiscount(_:)), for: .touchUpInside)
    }
    
    //MARK: - setter
    func setCellIndex(_ index:NSInteger, vc:ESSelectDiscountViewController, model:ESPackagePromotion){
        
        self.cellIndex = index
        self.viewController = vc
        
        discount.setTitle(model.promotionName, for: .normal)
        if let isSelect = model.isSelect, isSelect {
            discount.backgroundColor = ESColor.color(hexColor: 0xEF8779 , alpha: 1)
            discount.setTitleColor(UIColor.white, for: .normal)
        } else {
            discount.backgroundColor = UIColor.white
            discount.setTitleColor(ESColor.color(sample: .buttonRed), for: .normal)
            
        }
        
        if let promotionH5Url = model.promotionH5Url {
            if promotionH5Url == "" {
                checkButton.isHidden = true
                bottomHeight.constant = -10
            } else {
                checkButton.isHidden = false
                bottomHeight.constant = 10
            }
        } else {
            checkButton.isHidden = true
            bottomHeight.constant = -10
        }
        
    }
    
    //MARK: - Action
    @IBAction func checkDetail(_ sender: Any) {
        
        if let viewController = self.viewController {
            viewController.jumpToCouponUseDetail(index: cellIndex)
        }
    }
    
    @objc func selectDiscount(_ button:UIButton){
        
        if let viewController = self.viewController {
            
            if viewController.canChange {
                
                let isSelect = viewController.dataSource[cellIndex].isSelect ?? false
                
                if isSelect {
                    
                    button.backgroundColor = UIColor.white
                    button.setTitleColor(ESColor.color(sample: .buttonRed), for: .normal)
                    viewController.dataSource[cellIndex].isSelect = false
                    
                } else {
                    
                    viewController.dataSource[cellIndex].isSelect = true
                    
                    button.backgroundColor = ESColor.color(hexColor: 0xEF8779 , alpha: 1)
                    button.setTitleColor(UIColor.white, for: .normal)
                }
            }
        }
        
    }
    
}
