//
//  ESPackageDetailFirstTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/29.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESPackageDetailFirstTableViewCell: UITableViewCell {

    @IBOutlet weak var packageExpression: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        packageExpression.attributedText = ESStringUtil.returnNSMutableAttributedString("Norfortable · 北舒，是一种经典魅力与当代设计的碰撞，高雅内敛的气质中有着丰富的经典美学细节。整体产品设计旨在将高雅与居住者个性，现代与经典的各个美学元素糅合于空间，重新定义现代奢华内涵，深邃系的空间感知与高品质进口家具完美结合，营造出强烈的当代奢华与时尚简约的空间氛围，凸显居住者克制的高雅品味。", space: 12)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
