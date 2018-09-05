//
//  ESCaseOfferListTableViewCell.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/8.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESCaseOfferListTableViewCell: UITableViewCell {

    @IBOutlet weak var number: UILabel!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var expression: UILabel!
    
    @IBOutlet weak var rightLabelLeftGap: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.white//ESColor.color(sample: .backgroundView)
        
        rightLabelLeftGap.constant = 270.scalValue
    }
    
    func setCellModel(_ index:Int , model:ESCaseOfferModel){
        number.text = "\(index + 1)"
        title.text = model.projectName ?? "--"
        if let amount = model.amount, amount > 0.0 {
            price.text = String(format: "￥%.2f", amount)
        } else {
            price.text = "--"
        }
        expression.text = model.projectDesc ?? "--"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
