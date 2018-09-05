
//  ESOfferDetailSecondTableViewCell.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/8.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESOfferDetailSecondTableViewCell: UITableViewCell {

    @IBOutlet weak var filesLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCellModel(_ model:ESOfferDetailSubModel){
        filesLabel.text = model.name
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
