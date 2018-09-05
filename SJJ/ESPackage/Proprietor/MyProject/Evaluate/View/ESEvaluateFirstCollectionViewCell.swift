//
//  ESEvaluateFirstCollectionViewCell.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/31.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESEvaluateFirstCollectionViewCellDelegate: NSObjectProtocol {
    func getInfo() -> (String?, String?)
}

class ESEvaluateFirstCollectionViewCell: UICollectionViewCell {
    private weak var delegate: ESEvaluateFirstCollectionViewCellDelegate?
    
    @IBOutlet weak var headerImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCellModel(delegate: ESEvaluateFirstCollectionViewCellDelegate?){
        self.delegate = delegate
        if let (url, name) = delegate?.getInfo() {
            headerImage.imageWith(url ?? "", placeHold: #imageLiteral(resourceName: "headerDeafult"))
            userName.text = name
        }
    }

}
