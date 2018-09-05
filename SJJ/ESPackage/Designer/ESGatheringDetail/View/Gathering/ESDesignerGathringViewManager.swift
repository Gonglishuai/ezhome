//
//  ESDesignerGathringViewManager.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/18.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESDesignerGathringViewManager: NSObject {
    var role:ESRole = .designer
    
    lazy var tableView: UITableView = {
        
        let tableView = ESUIViewFactory.tableView(.grouped)
        tableView.sectionHeaderHeight = 0
        tableView.backgroundColor = UIColor.white
        tableView.register(UINib.init(nibName: "ESDesignerGatheringTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESDesignerGatheringTableViewCell")
        tableView.register(UINib.init(nibName: "ESGatheringExpressionTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESGatheringExpressionTableViewCell")
        tableView.register(UINib.init(nibName: "ESGatheringCouponTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESGatheringCouponTableViewCell")
        tableView.register(ESGathringSectionFooterView.self, forHeaderFooterViewReuseIdentifier: "ESGathringSectionFooterView")
        
        tableView.tableHeaderView = gathringTableHeader
        
        return tableView
    }()
    
    lazy var gathringTableHeader = ESDesignerGathringViewForTableHeader()
    
    weak var designerGathringViewManagerDelegate : ESGatheringExpressionDelegate?
    
    func payImmediately(_ target:ESGatheringDetailViewController)-> UIButton{
        let button = ESUIViewFactory.button("立即支付")
        button.addTarget(target, action: #selector(target.payImmediately), for: .touchUpInside)
        return button
    }
    
    lazy var transactionTableView: UITableView = {
        
        let tableView = ESUIViewFactory.tableView(.grouped)
        tableView.estimatedRowHeight = 185
        tableView.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        
        tableView.register(UINib.init(nibName: "ESTransactionLogTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESTransactionLogTableViewCell")
        tableView.register(ESTransactionLogSectionHeader.self, forHeaderFooterViewReuseIdentifier: "ESTransactionLogSectionHeader")
        tableView.register(ESGathringSectionFooterView.self, forHeaderFooterViewReuseIdentifier: "ESGathringSectionFooterView")
        
        tableView.tableHeaderView = transactionTableHeader
        
        return tableView
    }()
    
    lazy var transactionTableHeader = ESDesignerGathringViewForTableHeader()
    
    
    /// 返回收款明细Cell
    func returnDesignerGatheringDetailCell(tableView: UITableView, cellForRowAt indexPath: IndexPath, cellTitle:[String], listModel:ESGatheringDetailsSubSubModel)-> UITableViewCell {
        if indexPath.row == cellTitle.count {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESGatheringExpressionTableViewCell", for: indexPath) as!ESGatheringExpressionTableViewCell
            
            var hideDelBtn = false
            
            switch role {
            case .proprietor(_, _, _):
                hideDelBtn = true
            case .designer:
                if let paidAmount = listModel.paidAmount, paidAmount > 0 {
                    hideDelBtn = true
                }
            }
            
            cell.setupCostExpression(tableView, expression: listModel.remark ?? "", hiddenDelBtn: hideDelBtn, orderId: listModel.orderId)
            
            cell.gatheringCellDelegate = self.designerGathringViewManagerDelegate
            
            return cell
            
        } else {
            if 2 == indexPath.row {//优惠金额
                let cell = ESPackageAsserts.hostBundle.loadNibNamed("ESGatheringCouponTableViewCell", owner: self, options: nil)?.first as!ESGatheringCouponTableViewCell
                
                cell.showCoupon(tableView: tableView,model: listModel)
                
                return cell
                
            } else if 3 == indexPath.row {//返现金额
                let cell = ESPackageAsserts.hostBundle.loadNibNamed("ESGatheringCouponTableViewCell", owner: self, options: nil)?.first as!ESGatheringCouponTableViewCell
                
                cell.showManJian(tableView: tableView, model: listModel)
                
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ESDesignerGatheringTableViewCell", for: indexPath) as!ESDesignerGatheringTableViewCell
                
                cell.costNameLabel.textColor = ESColor.color(sample: .mainTitleColor)
                
                tableView.rowHeight = 51
                
                if 0 == indexPath.row {//费用名称
                    cell.costNameLabel.text = listModel.type ?? "--"
                    
                } else if 1 == indexPath.row {//费用金额
                    
                    if let amount = listModel.amount, amount > 0.0{
                        cell.costNameLabel.text = String(format: "￥%.2f", amount)
                    } else {
                        cell.costNameLabel.text = "--"
                    }
                } else if 4 == indexPath.row {//应付金额
                    
                    cell.costNameLabel.textColor = ESColor.color(sample: .buttonRed)
                    
                    if let amount = listModel.amount, amount > 0.0 {
                        cell.costNameLabel.text = String(format: "￥%.2f", amount)
                    } else {
                        cell.costNameLabel.text = "--"
                    }
                } else if 5 == indexPath.row {//已付金额
                    
                    cell.costNameLabel.textColor = ESColor.color(sample: .buttonGreen)
                    
                    if let amount = listModel.paidAmount, amount > 0.0 {
                        cell.costNameLabel.text = String(format: "￥%.2f", amount)
                    } else {
                        cell.costNameLabel.text = "--"
                    }
                }
                
                cell.setLeftLabelString(title: cellTitle[indexPath.row])
                
                return cell
            }
        }
    }
}
