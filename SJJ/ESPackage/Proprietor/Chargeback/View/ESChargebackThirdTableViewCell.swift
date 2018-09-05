//
//  ESChargebackThirdTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/26.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESChargebackThirdTableViewCell: UITableViewCell {
    @IBOutlet weak var orderNumber: UILabel!
    
    @IBOutlet weak var orderType: UILabel!
    
    @IBOutlet weak var ownerName: UILabel!
    
    @IBOutlet weak var linkPhone: UILabel!
    
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var sponsorTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        linkPhone.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMethod(tap:)))
        linkPhone.addGestureRecognizer(tap)        
    }
    
    func setCellElementModel(_ model:ESChargebackDetailsModel){
        sponsorTimeLabel.text = "发起退单时间：\(model.operateTime ?? "  ")"
        orderNumber.text = model.orderId ?? "--"
        orderType.text = model.projectTypeName ?? "--"
        ownerName.text = model.consumerName ?? "--"
        linkPhone.text = model.consumerMobile ?? "--"
        address.text = model.address ?? "--"
    }
    
    
    @objc func tapMethod(tap:UITapGestureRecognizer){
        ESDeviceUtil.callToSomeone(numberString: linkPhone.text ?? "")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
