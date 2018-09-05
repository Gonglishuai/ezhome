//
//  ESTransactionLogTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/19.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESTransactionLogTableViewCell: UITableViewCell {

    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var createTime: UILabel!
    
    @IBOutlet weak var orderNo: UILabel!
    
    @IBOutlet weak var payway: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCellModel(_ model:ESTransactionSubModel) {
        
        price.text = String(format: "￥%.2f", model.payAmount ?? 0.00)
        createTime.text = model.payTime
        orderNo.text = model.payNo ?? ""
        payway.text = model.payMethodName ?? ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
