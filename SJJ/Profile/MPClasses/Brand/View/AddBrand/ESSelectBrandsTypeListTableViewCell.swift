//
//  ESSelectBrandsTypeListTableViewCell.swift
//  Consumer
//
//  Created by zhang dekai on 2018/2/27.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESSelectBrandsTypeListTableViewCell: UITableViewCell {
    @IBOutlet weak var brandCatagoryName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCellModel(name:String){
        brandCatagoryName.text = name
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
