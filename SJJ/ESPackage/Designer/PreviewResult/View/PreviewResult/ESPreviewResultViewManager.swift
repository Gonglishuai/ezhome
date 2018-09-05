//
//  ESPreviewResultViewManager.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/19.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESPreviewResultViewManager: NSObject {
    
    lazy var tableView: UITableView = {
        
        let tableView:UITableView = ESUIViewFactory.tableView(.grouped)
                
        tableView.frame = CGRect.init(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - 50)
        tableView.estimatedRowHeight = 100
        tableView.sectionHeaderHeight = 45
        tableView.sectionFooterHeight = 0
        
        tableView.register(UINib.init(nibName: "ESDesignerGatheringTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESDesignerGatheringTableViewCell")
        tableView.register(UINib.init(nibName: "ESPreviewResultTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESPreviewResultTableViewCell")
        tableView.register(UINib.init(nibName: "ESPreviewResultSecondTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESPreviewResultSecondTableViewCell")
        
        tableView.register(ESPreviewResultSectionHeader.self, forHeaderFooterViewReuseIdentifier: "ESPreviewResultSectionHeader")
       
        return tableView
    }()
    
    lazy var deatilTableView: UITableView = {
        
        let tableView = ESUIViewFactory.tableView(.grouped)
        tableView.estimatedRowHeight = 150

        tableView.register(UINib.init(nibName: "ESPreviewResultDetailTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESPreviewResultDetailTableViewCell")
        tableView.register(UINib.init(nibName: "ESPreviewResultDetailOwnerMessageCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESPreviewResultDetailOwnerMessageCell")
        tableView.register(ESPreviewResultDetailSectionHeader.self, forHeaderFooterViewReuseIdentifier: "ESPreviewResultDetailSectionHeader")
        tableView.register(ESPreviewResultDetailSceondHeader.self, forHeaderFooterViewReuseIdentifier: "ESPreviewResultDetailSceondHeader")
        tableView.register(ESPreviewResultDetailSceondFooter.self, forHeaderFooterViewReuseIdentifier: "ESPreviewResultDetailSceondFooter")

        return tableView
    }()
    
    lazy var offerDeatilTableView: UITableView = {
        
        let tableView = ESUIViewFactory.tableView(.grouped)
        tableView.estimatedRowHeight = 150
        tableView.sectionFooterHeight = CGFloat.leastNormalMagnitude
        
        tableView.register(UINib.init(nibName: "ESOfferDetailFirstTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESOfferDetailFirstTableViewCell")
        tableView.register(UINib.init(nibName: "ESOfferDetailSecondTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESOfferDetailSecondTableViewCell")
        tableView.register(ESChargebackDetalFourthTableViewCell.self, forCellReuseIdentifier: "ESChargebackDetalFourthTableViewCell")

        tableView.register(ESOfferDetailSectionHeader.self, forHeaderFooterViewReuseIdentifier: "ESOfferDetailSectionHeader")
        tableView.register(ESPreviewResultDetailSceondHeader.self, forHeaderFooterViewReuseIdentifier: "ESPreviewResultDetailSceondHeader")
        tableView.register(ESPreviewResultDetailSceondFooter.self, forHeaderFooterViewReuseIdentifier: "ESPreviewResultDetailSceondFooter")
        tableView.register(ESPreviewResultSectionHeader.self, forHeaderFooterViewReuseIdentifier: "ESPreviewResultSectionHeader")

        
        return tableView
    }()
    
    
    lazy var caseOfferTableView: UITableView = {
        
        let tableView = ESUIViewFactory.tableView(.grouped)
        tableView.backgroundColor = UIColor.white
        
        tableView.estimatedRowHeight = 150
        tableView.sectionFooterHeight = CGFloat.leastNormalMagnitude
        
        tableView.register(UINib.init(nibName: "ESCaseOfferListTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESCaseOfferListTableViewCell")
        tableView.register(ESCaseOfferSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "ESCaseOfferSectionHeaderView")
        
        return tableView
    }()
    
    
    func completeButton(_ target:ESPreviewResultViewController) -> UIButton {
        let button = ESUIViewFactory.button("完成")
        
        button.addTarget(target, action: #selector(target.completeClick), for: .touchUpInside)
        
        return button
    }
    
    func getFreeAppointFirstCell(_ type:String,collectionView:UITableView)-> ESPreviewResultTableViewCell{
        var itemIndex = 4
        if type == "HousingState" {
            itemIndex = 4
        } else if type == "HousingStyle"{
            itemIndex = 5
        }
        let indexPath = IndexPath(item: itemIndex, section: 0)
        let cell = collectionView.cellForRow(at: indexPath)as!ESPreviewResultTableViewCell
        return cell
    }
    
    @discardableResult
    func getPreviewResultCell(_ row:NSInteger, tableView:UITableView)->ESPreviewResultTableViewCell{
        let indexPath = IndexPath(row: row, section: 0)
        let cell = tableView.cellForRow(at: indexPath)
        return cell as! ESPreviewResultTableViewCell
    }

}
