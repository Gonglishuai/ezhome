//
//  ESPackageThirdTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/29.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESPackageThirdTableViewCell: UITableViewCell {
    @IBOutlet weak var backgroundImageview: UIImageView!
    
    @IBOutlet weak var headerIcon: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var packageType: UILabel!
    
    @IBOutlet weak var goodNumber: UILabel!
    
    @IBOutlet weak var commentNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.layer.cornerRadius
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
