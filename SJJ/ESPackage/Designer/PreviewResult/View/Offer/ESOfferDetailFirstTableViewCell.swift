//
//  ESOfferDetailFirstTableViewCell.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/8.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESOfferDetailFirstTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var offerImageVIew: UIImageView!
    @IBOutlet weak var checkOfferView: UIView!

    @IBOutlet weak var pkgName: UIButton!
    
    
    private weak var viewController:ESOfferDetailViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMethod(_:)))
        checkOfferView.addGestureRecognizer(tap)
        
        offerImageVIew.clipsToBounds = true
        offerImageVIew.contentMode = .scaleAspectFill
        
        pkgName.layer.masksToBounds = true
        pkgName.layer.cornerRadius = 9
        pkgName.layer.borderWidth = 1
        pkgName.layer.borderColor = ESColor.color(sample: .buttonBlue).cgColor
        pkgName.setTitleColor(ESColor.color(sample: .buttonBlue), for: .normal)
    }

    func setVC(_ viewController:ESOfferDetailViewController){
        self.viewController = viewController
    }
    
    
    func setCellModel(_ model:ESOfferDetailModel){
        titleLabel.text = model.designName ?? "--"
        offerImageVIew.imageWith(model.designCoverImg ?? "")
        if let pkgName = model.pkgName {
            self.pkgName.setTitle(pkgName, for: .normal)
        } else {
            self.pkgName.setTitle("--", for: .normal)
        }
    }
    
    @objc func tapMethod(_ tap:UITapGestureRecognizer){
        if let viewController = self.viewController{
            viewController.checkCaseOffer()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
