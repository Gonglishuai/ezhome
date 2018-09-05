//
//  ESTransactionViewController.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/19.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

/// 交易流水
class ESTransactionViewController: ESBasicViewController {
    
    var comeFromDetail = true
    private lazy var viewManager = ESDesignerGathringViewManager()
    private var datasource:ESTransactionModel?
    private var assetId = ""
    private var orderId = ""
    private var role:ESRole = .designer
    
    //MARK: - Init
    init(assetId: String, orderId: String, role: ESRole) {
        super.init(nibName: nil, bundle: nil)
        self.assetId = assetId
        self.orderId = orderId
        self.role = role
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life style
    override func viewDidLoad() {
        super.viewDidLoad()
        initilizeNavigationBar()
        initilizaUI()
        gatheringDetail()
    }
    
    //MARK: - Init UI
    private func initilizeNavigationBar() {
        setupNavigationTitleWithBack(title: "交易流水")
        var rightTitle = "收款明细"
        switch role {
        case .proprietor( _):
            rightTitle = "付款明细"
        default:
            break
        }
        setupCustomRightItemWithTitle(title: rightTitle, color: ESColor.color(sample: .buttonBlue), font: ESFont.font(name: ESFont.ESFontName.regular, size: 13))
    }
    
    private func initilizaUI() {
        view.addSubview(viewManager.transactionTableView)
        viewManager.transactionTableView.delegate = self;
        viewManager.transactionTableView.dataSource = self;
    }
    
    //MARK: - Network
    private var  errorView = ESErrorViewUtil()

    private func gatheringDetail(){
        
        ESProgressHUD.show(in: self.view)
        
        ESAppointApi.getTaransaction(orderId, success: { (data) in
            
            ESProgressHUD.hide(for: self.view)
            self.errorView.hiddenErrorView()

            let detailmodel = try?JSONDecoder().decode(ESTransactionModel.self, from: data)
            
            if let model = detailmodel {
                self.datasource = model
                self.viewManager.transactionTableHeader.setupTransactionHeaderModel(model,role: self.role)
                self.viewManager.transactionTableView.reloadData()
            } else {
                self.errorView.showNoDataView(in: self.view)
            }
        }) { (error) in
            ESProgressHUD.hide(for: self.view)
            MBProgressHUD.showError(SHRequestTool.getErrorMessage(error), to:      self.view)
        }
    }
    //MARK: - Actoins
    override func navigationBarRightAction() {
        print("收款明细")
        if comeFromDetail {
            let vc =  ESGatheringDetailViewController(assetId: assetId, orderId: orderId, role: role)
            vc.comeFromDetail = false
            navigationController?.pushViewController(vc, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension ESTransactionViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let model = datasource, let list = model.detailList {
            return list.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ESTransactionLogTableViewCell")as!ESTransactionLogTableViewCell
        if let model = datasource, let list = model.detailList {
            cell.setCellModel(list[indexPath.row])
        }
        return cell
    }
}
