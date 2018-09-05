//
//  PackViewManager.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/28.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import Foundation

class ESPackageViewManager: NSObject {
    
    lazy var tableView: UITableView = {
        
        let tableView:UITableView = ESUIViewFactory.tableView(.plain)
        
        tableView.estimatedRowHeight = 200
        
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0//CGFloat.leastNormalMagnitude
        
        tableView.register(UINib.init(nibName: "ESPackageListTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESPackageListTableViewCell")
        
        
        return tableView
    }()
    
    lazy var detailTableView: UITableView = {
        
        let tableView:UITableView = ESUIViewFactory.tableView(.grouped)
        
        tableView.estimatedRowHeight = 200
        
        tableView.register(UINib.init(nibName: "ESPackageDetailFirstTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESPackageDetailFirstTableViewCell")
        tableView.register(ESPreviewResultSectionHeader.self, forHeaderFooterViewReuseIdentifier: "ESPreviewResultSectionHeader")
        tableView.register(UINib.init(nibName: "ESPackageDetailSecondTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESPackageDetailSecondTableViewCell")
        tableView.register(UINib.init(nibName: "ESPackageThirdTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESPackageThirdTableViewCell")
        
        return tableView
    }()
    
    func orderButton(_ target:ESPackageListViewController)->ESPackageButtonView {
        
        let button = ESPackageButtonView(frame: CGRect(x: ScreenWidth - 100.scalValue, y: ScreenHeight - 308.scalValue, width: 70.scalValue, height: 90.scalValue))
        
        button.setViewData(ESPackageAsserts.bundleImage(named: "package_appoint"), text: "预约")
        
        let tap = UITapGestureRecognizer(target: target, action: #selector(target.orderButtonClick))
        button.addGestureRecognizer(tap)
        
        return button
    }
    
    func personalButton(_ target:ESPackageListViewController)->ESPackageButtonView {
        let button = ESPackageButtonView(frame: CGRect(x: ScreenWidth - 100.scalValue, y: ScreenHeight - 193.scalValue, width: 70.scalValue, height: 90.scalValue))
        button.setViewData(ESPackageAsserts.bundleImage(named: "package_personal"), text: "个性化")
        let tap1 = UITapGestureRecognizer(target: target, action: #selector(target.personalButtonClick))
        button.addGestureRecognizer(tap1)
        return button
    }
   
}

