//
//  ESCancleAppointTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/25.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit


class ESCancleAppointTableViewCell: UITableViewCell {
    
    @IBOutlet weak var selectIcon: UIImageView!
    @IBOutlet weak var reasonLabel: UILabel!
    
    private var cellIndex:NSInteger = 0
    private var viewController:ESCancleAppointViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectIcon.isUserInteractionEnabled = true
        reasonLabel.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMethod(tap:)))
        selectIcon.addGestureRecognizer(tap)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(tapMethod(tap:)))
        reasonLabel.addGestureRecognizer(tap1)
        
    }
    
    
    //MARK: - setter
    func setCellIndex(index:NSInteger, vc:ESCancleAppointViewController){
        self.cellIndex = index
        self.viewController = vc
    }
    
    func setIconImage(_ open:Bool){
        if open {
            selectIcon.image = ESPackageAsserts.bundleImage(named: "appoint_cancle_right_blue")
            if let viewController = self.viewController {
                viewController.uploadDic[ESCancleAppointUploadDic.CancleSelected.rawValue] = reasonLabel.text ?? ""
            }
        } else {
            selectIcon.image = ESPackageAsserts.bundleImage(named: "appoint_cancle_right_gray")
        }
    }
    
    
    func setCancleReason(_ reason:String){
        reasonLabel.text = reason
    }
    
    //MARK: - Action
    
    @objc func tapMethod(tap:UITapGestureRecognizer) {
        if let viewController = self.viewController {
            
            for i in 0..<viewController.selectedIcon.count {
                viewController.selectedIcon[i] = false
            }
            viewController.selectedIcon[cellIndex] = true
            viewController.reloadView()
            viewController.uploadDic[ESCancleAppointUploadDic.CancleSelected.rawValue] = reasonLabel.text ?? ""
        }
        //TODO: - model
        print("\(cellIndex) \(reasonLabel.text ?? "")")
    }
}
