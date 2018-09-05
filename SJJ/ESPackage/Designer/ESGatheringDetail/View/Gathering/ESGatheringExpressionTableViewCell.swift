//
//  ESGatheringExpressionTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/18.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

@objc protocol ESGatheringExpressionDelegate:NSObjectProtocol {
    func cancelPay(_ orderId: String)
}

class ESGatheringExpressionTableViewCell: UITableViewCell {

    weak var gatheringCellDelegate : ESGatheringExpressionDelegate?
    
    var currentOrderId: String?
    
    @IBOutlet weak var costExpressionLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCostExpression(_ tableView:UITableView, expression:String, hiddenDelBtn: Bool, orderId: String?) {
        
        var freeDetail = "--"
        if expression.trimmingCharacters(in: CharacterSet.whitespaces).count > 0 {
            freeDetail = expression
        }
//        cancelBtn.isHidden = expression.trimmingCharacters(in: CharacterSet.whitespaces).count > 0
        
        costExpressionLabel.attributedText = ESStringUtil.returnNSMutableAttributedString(freeDetail, space: 5)
        let height = ESStringUtil.returnStringHeight(freeDetail, font: UIFont.systemFont(ofSize: 13), width: ScreenWidth - 121, space: 5)

        self.currentOrderId = orderId
        cancelBtn.isHidden = hiddenDelBtn
        
        tableView.rowHeight = height + (hiddenDelBtn ? 35  : 78)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnClick(_ sender: UIButton) {
        if let orderId = self.currentOrderId, orderId.count > 0 {
            
            self.gatheringCellDelegate?.cancelPay(orderId)
        }
    }
}
