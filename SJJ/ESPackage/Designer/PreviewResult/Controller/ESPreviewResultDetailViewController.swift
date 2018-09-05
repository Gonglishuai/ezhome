//
//  ESPreviewResultDetailViewController.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/20.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

/// 预交底详情
class ESPreviewResultDetailViewController: ESBasicViewController {
    
    private lazy var viewManager = ESPreviewResultViewManager()
    private let sectionTwoData = ["业主姓名","联系电话","小区地址","小区名称"]
    private var dataSoure:ESPreviewResultDetailModel?
    private var assetId = ""
    
    //MARK: - Init
    init(assetId: String) {
        super.init(nibName: nil, bundle: nil)
        self.assetId = assetId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - life Style
    override func viewDidLoad() {
        super.viewDidLoad()
        initilizaUI()
        previewResultDetail()
    }
    
    //MARK: - Init UI
    func initilizaUI() {
        setupNavigationTitleWithBack(title: "预交底详情")
        view.addSubview(viewManager.deatilTableView)
        viewManager.deatilTableView.delegate = self;
        viewManager.deatilTableView.dataSource = self;
        viewManager.deatilTableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    //MARK: - Network
    private var errorView = ESErrorViewUtil()
    func previewResultDetail(){
        ESProgressHUD.show(in: view)
        ESAppointApi.previewResultDetail(assetId, success: { (data) in
            ESProgressHUD.hide(for: self.view)
            self.errorView.hiddenErrorView()
            
            let detail = try?JSONDecoder().decode(ESPreviewResultDetailModel.self, from: data)
            if let model = detail {
                self.dataSoure = model
                self.viewManager.deatilTableView.reloadData()
            } else {
                self.errorView.showNoDataView(in: self.view)
            }
        }) { (error) in
            ESProgressHUD.hide(for: self.view)
            MBProgressHUD.showError(SHRequestTool.getErrorMessage(error), to: self.view)
        }
    }
}

extension ESPreviewResultDetailViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if 0 == section {
            if let model = dataSoure, let list = model.roleList {
                return list.count
            }
            return 0
        } else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if 0 == indexPath.section {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESPreviewResultDetailTableViewCell", for: indexPath)as!ESPreviewResultDetailTableViewCell
            if let model = dataSoure, let list = model.roleList  {
                cell.setCellModel(list[indexPath.row])
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESPreviewResultDetailOwnerMessageCell", for: indexPath)as!ESPreviewResultDetailOwnerMessageCell
            cell.cellIndex = indexPath.row
            if 1 == indexPath.row {
                cell.rightMessageLabel.textColor = ESColor.color(sample: .buttonBlue)
                cell.rightMessageLabel.font = ESFont.font(name: .medium, size: 12)
            } else {
                cell.rightMessageLabel.textColor = ESColor.color(sample: .textGray)
                cell.rightMessageLabel.font = ESFont.font(name: .regular, size: 12)
            }
            cell.leftTitleLabel.text = sectionTwoData[indexPath.row]
            if let model = dataSoure {
                cell.setCellModel(model)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if 0 == section  {
            return 114
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if 0 == section {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESPreviewResultDetailSectionHeader")as!ESPreviewResultDetailSectionHeader
            if let model = dataSoure {
                view.statusLabel.text = model.statusName ?? ""
                view.dateLabel.text = model.preDate ?? ""
            }
            return view
        } else {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESPreviewResultDetailSceondHeader")as!ESPreviewResultDetailSceondHeader
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if 1 == section {
            return 50
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if 1 == section {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESPreviewResultDetailSceondFooter")as!ESPreviewResultDetailSceondFooter
            return view
        }
        return nil
    }
}
