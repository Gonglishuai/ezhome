//
//  ESPackageListTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/28.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESPackageListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var packageTitle: UILabel!
    
    @IBOutlet weak var packageBackground: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCell(_ model:ESPackageListModel){
       
        packageTitle.text = ""

        packageBackground.imageWith(model.pkgImageUrl ?? "")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
