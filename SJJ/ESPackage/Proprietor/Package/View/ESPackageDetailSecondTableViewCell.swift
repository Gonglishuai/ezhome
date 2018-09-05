//
//  ESPackageDetailSecondTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/29.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESPackageDetailSecondTableViewCell: UITableViewCell {

    @IBOutlet weak var introduct: UILabel!
    
    @IBOutlet weak var introductLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        introductLabel.attributedText = ESStringUtil.returnNSMutableAttributedString("地板或地砖地面满铺（含配套踢脚线及扣条）地板或地砖地面满铺", space: 12)
    }
    
    
    func setCellModel(_ title:String){
        introductLabel.text = "地板或地砖地面满铺（含配套踢脚线及扣条）地板或地砖地面满铺（含配套踢脚线及扣条）地板或地砖地面满铺（含配套踢脚线及扣条）地板或地砖地面满铺（含配套踢脚线及扣条）"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
