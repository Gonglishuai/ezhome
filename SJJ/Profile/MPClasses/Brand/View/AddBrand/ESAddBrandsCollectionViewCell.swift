//
//  ESAddBrandsCollectionViewCell.swift
//  Consumer
//
//  Created by zhang dekai on 2018/2/27.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESAddBrandsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var brandImageView: UIImageView!
    
    @IBOutlet weak var brandName: UILabel!
    
    @IBOutlet weak var selectrdIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        brandImageView.layer.masksToBounds = true
        brandImageView.layer.cornerRadius = 2
        brandImageView.layer.borderWidth = 0.5
        brandImageView.layer.borderColor = ESColor.color(hexColor: 0xEBECED, alpha: 1).cgColor
        brandImageView.contentMode = .scaleToFill
    
    }
    
    func setCellModel(model:ESBrandGoodsModel){
        
        brandImageView.imageWith(model.logo ?? "", placeHold: #imageLiteral(resourceName: "nodata_datas"))
        brandName.text = model.name ?? "--"
        
        let hasSelected = model.hasSelected  ?? false
        if hasSelected {
            selectrdIcon.isHidden = false
        } else {
            selectrdIcon.isHidden = true
        }
    }

    func showHasAddedBrands(addedBrands:[ESBrandGoodsModel], currentBrand:ESBrandGoodsModel){
        
        for model in addedBrands {
            if currentBrand.cat2Id == model.cat2Id {
                selectrdIcon.isHidden = false
            } else {
                selectrdIcon.isHidden = true
            }
        }
        
    }
}
