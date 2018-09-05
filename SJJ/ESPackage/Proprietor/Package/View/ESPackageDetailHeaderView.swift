//
//  ESPackageDetailHeaderView.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/4.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESPackageDetailHeaderView: UIView, ESNibloadable {
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var packageTitle: UILabel!
    
    @IBOutlet weak var packagePrice: UILabel!
    
    @IBOutlet weak var goodNumber: UILabel!
    
    @IBOutlet weak var orderImmediately: UIButton!
    
    
    private var viewController:ESPackageDetailViewController?
    
    
    //MARK: - setter
    func setViewContainer(_ vc:ESPackageDetailViewController){
        self.viewController = vc
        
    }
    
    @IBAction func closeDetail(_ sender: Any) {
        
        viewController?.closeViewController()
        
    }
    
    @IBAction func orderimmediately(_ sender: Any) {
        viewController?.orderButtonClick()
        print("四渡赤水多吃蔬菜")
    }

   

}
