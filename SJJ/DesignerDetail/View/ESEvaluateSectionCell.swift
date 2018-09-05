//
//  ESEvaluateSectionCell.swift
//  EZHome
//
//  Created by shiyawei on 4/8/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESEvaluateSectionCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1
        self.layer.borderColor = ESColor.color(hexColor: 0xDCDFE6, alpha: 1.0).cgColor
        self.clipsToBounds = true
    }

    func contentString(text:String) {
        self.titleLabel.text = text
    }
    
}
