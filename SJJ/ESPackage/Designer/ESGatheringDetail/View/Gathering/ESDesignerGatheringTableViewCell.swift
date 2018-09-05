//
//  ESDesignerGatheringTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/18.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESDesignerGatheringTableViewCell: UITableViewCell {
    @IBOutlet weak var costLeftLabel: UILabel!
    @IBOutlet weak var costNameLabel: UILabel!
    
    @IBOutlet weak var line: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        line.backgroundColor = ESColor.color(sample: .separatorLine)
    }
    
    func setLeftLabelString(title:String){
        costLeftLabel.text = title;
    }
    
   
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
