//
//  ESOfferDetailViewController.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/8.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

/// 图纸报价详情
class ESOfferDetailViewController: ESBasicViewController {
    
    private lazy var viewManager = ESPreviewResultViewManager()
    private var dataSource:ESOfferDetailModel?
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
        imageOfferDetail()
    }
    
    //MARK: - Init UI
    func initilizaUI() {
        setupNavigationTitleWithBack(title: "图纸报价详情")
        
        view.addSubview(viewManager.offerDeatilTableView)
        viewManager.offerDeatilTableView.delegate = self;
        viewManager.offerDeatilTableView.dataSource = self;
    }
    
    //MARK: - Network
    private var errorView = ESErrorViewUtil()
    private func imageOfferDetail(){
        ESProgressHUD.show(in: view)
        ESAppointApi.imageOfferDetail(assetId, success: { (data) in
            
            ESProgressHUD.hide(for: self.view)
            self.errorView.hiddenErrorView()

            let detailModel = try?JSONDecoder().decode(ESOfferDetailModel.self, from: data)
            
            if let model = detailModel {
                self.dataSource = model
                if let status = model.status, status != "0" {
                    self.viewManager.offerDeatilTableView.reloadData()
                } else {
                    self.errorView.showErrorView(in: self.view, imgName:"nodata_datas", title:"暂无图纸报价", buttonTitle:"", block:nil)
                }
            } else {
                self.errorView.showErrorView(in: self.view, imgName:"nodata_datas", title:"暂无图纸报价", buttonTitle:"", block:nil)
            }
        }) { (error) in
            ESProgressHUD.hide(for: self.view)
            ESProgressHUD.showText(in: self.view, text: SHRequestTool.getErrorMessage(error))
        }
    }
    
    func checkCaseOffer(){
        print("查看报价")
        navigationController?.pushViewController(ESCaseOfferViewController(assetId: dataSource?.quoteId ?? ""), animated: true)
    }
    
}

extension ESOfferDetailViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if 0 == section {
            return 0
        } else if section == 2 {
            if let model = dataSource, let list = model.files {
                return list.count
            }
            return 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if 1 == indexPath.section {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESOfferDetailFirstTableViewCell", for: indexPath)as!ESOfferDetailFirstTableViewCell
            cell.setVC(self)
            if let model = dataSource {
                cell.setCellModel(model)
            }
            return cell
        } else if 3 == indexPath.section {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESChargebackDetalFourthTableViewCell", for: indexPath)as!ESChargebackDetalFourthTableViewCell
            if let model = dataSource {
                cell.setCellModel(model)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESOfferDetailSecondTableViewCell", for: indexPath)as!ESOfferDetailSecondTableViewCell
            if let model = dataSource, let list = model.files {
                cell.setCellModel(list[indexPath.row])
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if 0 == section  {
            return 126
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if 0 == section {
            
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESOfferDetailSectionHeader")as!ESOfferDetailSectionHeader
           
            if let model = dataSource {
                view.statusLabel.text = model.statusName ?? "--"
                view.dateLabel.text = model.createDate ?? "--"
                var amountStr = "--"
                if let erpAmount = model.amount {
                    amountStr = String(format: "%.2f元", erpAmount)
                }
                view.amountLabel.text = amountStr
            }
            
            view.statusLabel.textColor = ESColor.color(sample: .buttonGreen)
            
            return view
            
        } else if section == 2 {
           
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESPreviewResultDetailSceondHeader")as!ESPreviewResultDetailSceondHeader
           
            view.resetConstrantsForOffer()
            view.statusLabel.text = "附件"
            
            return view
            
        } else {
            
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESPreviewResultSectionHeader")as!ESPreviewResultSectionHeader
            
            if 1 == section {
                view.sectionLeftLabel.text = "提交材料"
            } else {
                view.sectionLeftLabel.text = "备注说明"
            }
            
            return view
        }
    }
}
