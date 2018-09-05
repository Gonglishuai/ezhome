//
//  ESPersonalAppointCollectionViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/28.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESPersonalAppointCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.attributedText = ESStringUtil.returnNSMutableAttributedString("精准专业海量案例满足您的挑剔品味", space: 5)
    }
    

}
