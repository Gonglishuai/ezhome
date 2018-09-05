//
//  ESPreviewResultDetailTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/20.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESPreviewResultDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var roleLabel: UILabel!
    
    @IBOutlet weak var roleNameLabel: UILabel!
    
    @IBOutlet weak var rolePhoneLabel: UILabel!
    
    @IBOutlet weak var rolePhone: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backView.layer.masksToBounds = true
        backView.layer.borderWidth = 0.5
        backView.layer.cornerRadius = 3
        backView.layer.borderColor = ESColor.color(sample: .separatorLine).cgColor
        
        
        rolePhone.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target:self, action: #selector(tapMethod(tap:)))
        rolePhone.addGestureRecognizer(tap)
        
    }
    
    func setCellModel(_ model:ESPreviewResultRoleListModel){
        
        roleLabel.text = String(format: "%@姓名", model.roleName ?? "")
        roleNameLabel.text = model.userName
        rolePhoneLabel.text = String(format: "%@电话", model.roleName ?? "")
        rolePhone.text = model.userMobile
    }
    
    @objc func tapMethod(tap:UITapGestureRecognizer) {
       ESDeviceUtil.callToSomeone(numberString: rolePhone.text ?? "")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
