//
//  ESDiscountViewManager.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/27.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESDiscountViewManager: NSObject {

    lazy var tableView: UITableView = {
        
        let tableView:UITableView = ESUIViewFactory.tableView(.plain)

        tableView.estimatedRowHeight = 60
        
        tableView.register(UINib.init(nibName: "ESSelectDiscountTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESSelectDiscountTableViewCell")
        
        return tableView
    }()
    
    func completeButton(_ target:ESSelectDiscountViewController) -> UIButton {
        let button = ESUIViewFactory.button()
        
        button.addTarget(target, action: #selector(target.conformDiscount), for: UIControlEvents.touchUpInside)
        return button
    }
    
}
