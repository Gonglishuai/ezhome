//
//  ESCreatBrandListThirdCell.swift
//  Consumer
//
//  Created by zhang dekai on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESCreatBrandListThirdCellProtocol:NSObjectProtocol {
    func addBrand()
}

/// 添加品牌
class ESCreatBrandListThirdCell: UITableViewCell {

    @IBOutlet weak var addBrandImageView: UIImageView!
    
    private weak var cellDelegate:ESCreatBrandListThirdCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(addBrand(tap:)))
        addBrandImageView.addGestureRecognizer(tap)
    }
    
    func setCellDelegate(delegate:ESCreatBrandListThirdCellProtocol){
        self.cellDelegate = delegate
    }
    
    @objc func addBrand(tap:UITapGestureRecognizer){
        
        if let delegate = cellDelegate {
            delegate.addBrand()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
