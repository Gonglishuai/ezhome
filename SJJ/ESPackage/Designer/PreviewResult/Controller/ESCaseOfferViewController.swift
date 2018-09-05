//
//  ESCaseOfferViewController.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/8.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

/// 方案报价
class ESCaseOfferViewController: ESBasicViewController, UITableViewDelegate, UITableViewDataSource {

    private lazy var viewManager = ESPreviewResultViewManager()
    private var dataSource:[ESCaseOfferModel]?
    private var assetId = ""
    
    //MARK: - Init
    init(assetId: String) {
        super.init(nibName: nil, bundle: nil)
        self.assetId = assetId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Style
    override func viewDidLoad() {
        super.viewDidLoad()

        initilizaUI()
        getCaseOffer()
    }
    
    //MARK: - Init UI
    func initilizaUI() {
        
        setupNavigationTitleWithBack(title: "方案报价")
        
        view.addSubview(viewManager.caseOfferTableView)
        viewManager.caseOfferTableView.delegate = self;
        viewManager.caseOfferTableView.dataSource = self;
    }
    
    //MARK: - Network
    private var errorView = ESErrorViewUtil()
    private func getCaseOffer(){
        
        ESProgressHUD.show(in: view)
        ESAppointApi.caseOffer(assetId, success: { (data) in
            
            ESProgressHUD.hide(for: self.view)
            self.errorView.hiddenErrorView()
            
            let listModel = try?JSONDecoder().decode([ESCaseOfferModel].self, from: data)
           
            if let model = listModel{
                self.dataSource = model
                self.viewManager.caseOfferTableView.reloadData()
            } else {
                self.errorView.showNoDataView(in:self.view)
            }
        }) { (error) in
            ESProgressHUD.hide(for: self.view)
            MBProgressHUD.showError(SHRequestTool.getErrorMessage(error), to: self.view)
        }
    }
    
    //MARK: - UITableViewDelegate, UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let model = dataSource {
            return model.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ESCaseOfferListTableViewCell", for: indexPath)as!ESCaseOfferListTableViewCell
        
        if let model = dataSource {
            cell.setCellModel(indexPath.row, model: model[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESCaseOfferSectionHeaderView")as!ESCaseOfferSectionHeaderView
        return view
    }

}
