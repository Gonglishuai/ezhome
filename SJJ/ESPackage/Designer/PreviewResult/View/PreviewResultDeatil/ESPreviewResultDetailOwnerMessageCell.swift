//
//  ESPreviewResultDetailOwnerMessageCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/21.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESPreviewResultDetailOwnerMessageCell: UITableViewCell {
    
    var cellIndex:NSInteger = 0
    @IBOutlet weak var leftTitleLabel: UILabel!
    
    @IBOutlet weak var rightMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        rightMessageLabel.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMethod(tap:)))
        rightMessageLabel.addGestureRecognizer(tap)
        
    }
    
    func setCellModel(_ model:ESPreviewResultDetailModel){
        var message = ""
        switch cellIndex {
        case 0:
            message = model.name ?? " "
            break
        case 1:
            message = model.mobile ?? " "
            break
        case 2:
            message = model.address ?? ""
            break
        case 3:
            message = model.community ?? ""
            break
        default:
            break
        }
        rightMessageLabel.text = message
    }

    @objc func tapMethod(tap:UITapGestureRecognizer){
        if cellIndex == 1 {
            ESDeviceUtil.callToSomeone(numberString: rightMessageLabel.text ?? "")
        }
    }
    
}
