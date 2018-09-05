//
//  ESChargebackDetailViewController.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/26.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

/// 退单/退款详情
class ESChargebackDetailViewController: ESBasicViewController, UITableViewDelegate, UITableViewDataSource {
    
//    private var orderId = ""
    var isOrder:Bool = false
    private var viewManager = ESFreeAppointViewManager()
    private var dataSource = Array<ESChargebackDetailModel>()
    private var orderIds = [String]()
    
    //MARK: - Init
    init(_ orderIds:[String],_ isOrder:Bool) {
        super.init(nibName: nil, bundle: nil)
        self.orderIds = orderIds 
        self.isOrder = isOrder
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Style
    override func viewDidLoad() {
        super.viewDidLoad()
        initilizeUI()
        loadDate()
    }
    
    
    
    
    //MARK: - Init UI
    private func initilizeUI(){
        setupNavigationTitleWithBack(title: "退单/退款详情")
        
        view.addSubview(viewManager.detailTableView)
        viewManager.detailTableView.delegate = self;
        viewManager.detailTableView.dataSource = self;
    }
    
    private func loadDate() {
//        ESProgressHUD.show(in: view)
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "orderQueue", attributes: .concurrent)
        for orderId:String in self.orderIds {
            loadOrderDetail(group, queue, orderId)
        }
        group.notify(queue: DispatchQueue.main) {
//            ESProgressHUD.hide(for: self.view)
            
            self.viewManager.detailTableView.reloadData()

        }
    }
    
    
    //MARK: - Network
    private var errorView = ESErrorViewUtil()
    
    private func loadOrderDetail(_ group:DispatchGroup,_ queue:DispatchQueue,_ orderId:String) {
        queue.async(group: group, execute: DispatchWorkItem.init(block: {
            group.enter()
            ESAppointApi.cancleOrderDetail(orderId, success: { (data) in
                self.errorView.hiddenErrorView()
                let detail = try? JSONDecoder().decode(ESChargebackDetailModel.self, from: data)
                if let model = detail {
                    self.dataSource.append(model)
                }
                group.leave()
            }) { (error) in
                MBProgressHUD.showError(SHRequestTool.getErrorMessage(error), to: self.view)
                group.leave()
            }
            
        }))
        
    }
    
    
    //MARK: -  UITableViewDelegate, UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 140
        }else if indexPath.row == 1 {
            return 150
        }else if indexPath.row == 2 {
            return 230
        }else {
            return 130
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isOrder {
            return 4
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var i = 0
        
        for model:ESChargebackDetailModel in dataSource {
            if indexPath.section == i {
                if indexPath.row  == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ESChargebackDetailFirstTableViewCell", for: indexPath)as!ESChargebackDetailFirstTableViewCell
                    if let data = model.data {
                        cell.setCellElementModel(data)
                    }
                    return cell
                } else if indexPath.row == 1{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ESChargebackDetailSecondTableViewCell", for: indexPath)as!ESChargebackDetailSecondTableViewCell
                    if let data = model.data {
                        cell.setChargebackStatus(data)
                    }
                    return cell
                } else if indexPath.row == 2{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ESChargebackThirdTableViewCell", for: indexPath)as!ESChargebackThirdTableViewCell
                    if let data = model.data {
                        cell.setCellElementModel(data)
                    }
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ESChargebackDetalFourthTableViewCell", for: indexPath)as!ESChargebackDetalFourthTableViewCell
                    if let data = model.data {
                        cell.setCellElementModel(data)
                    }
                    return cell
                }
            }
            i += 1
        }
            
        let cell = UITableViewCell()
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
            return CGFloat.leastNormalMagnitude
//        } else {
//            return 45
//        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        _ = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESChargebackDetailSectionHeader")as!ESChargebackDetailSectionHeader

//        switch section {
//        case 0:
            return nil
//        case 1:
//            view.sectionLeftLabel.text = "退款进度"
//            return view
//        case 2:
//            view.sectionLeftLabel.text = "退款信息"
//            view.sectionRightLabel.isHidden = false
//            let model = dataSource[0]
//            if  let data = model.data {
//                view.sectionRightLabel.text = "发起退单时间：\(data.operateTime ?? "  ")"
//            }
//            return view
//        case 3:
//            view.sectionLeftLabel.text = "退款原因"
//            return view
//        default:
//            return nil
//        }
    }
}
