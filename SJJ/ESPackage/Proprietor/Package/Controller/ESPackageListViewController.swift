//
//  ESPackageListViewController.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/28.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

/// 套餐列表
class ESPackageListViewController: ESBasicViewController {
    
    private lazy var viewManager = ESPackageViewManager()
    private var dataSource = [ESPackageListModel]()
    
    //MARK: - Life Style
    override func viewDidLoad() {
        super.viewDidLoad()
        initilizeUI()
        requestData()
    }
    
    //MARK: - Init UI
    private func initilizeUI(){
        
        setupNavigationTitleWithBack(title: "套餐")
        
        view.addSubview(viewManager.tableView)
        viewManager.tableView.delegate = self
        viewManager.tableView.dataSource = self
        
        view.addSubview(viewManager.orderButton(self))
        view.addSubview(viewManager.personalButton(self))
        
    }
    
    //MARK: - Network
    private var errorView = ESErrorViewUtil()
    private func requestData(){
        ESProgressHUD.show(in: view)
        ESPackageEntranceApi.getPackageList({ (responseData) in
            ESProgressHUD.hide(for: self.view)
            self.errorView.hiddenErrorView()

            let packageList = try?JSONDecoder().decode([ESPackageListModel].self, from: responseData)
            
            if let list = packageList {
                self.dataSource = list
                self.viewManager.tableView.reloadData()
            } else {
               self.errorView.showNoDataView(in: self.view)
            }
        }) { (error) in
            ESProgressHUD.hide(for: self.view)
            ESProgressHUD.showText(in: self.view, text: SHRequestTool.getErrorMessage(error))
        }
    }
    
    //MARK: - Actions
    @objc func orderButtonClick(){
        print("预约")
//        let vc = ESFreeAppointViewController()
//        vc.selectedType = 5
//        navigationController?.pushViewController(vc, animated: true)
        let appointVC = UIStoryboard.init(name: "ESAppointVC", bundle: nil).instantiateViewController(withIdentifier: "AppointVC") as! ESAppointTableVC
        appointVC.selectedType = 5
        self.navigationController?.pushViewController(appointVC, animated: true)
    }
    
    @objc func personalButtonClick(){
        print("个性化")
        navigationController?.pushViewController(ESPersonalAppointViewController(), animated: true)
    }
}

extension ESPackageListViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ESPackageListTableViewCell", for: indexPath)as!ESPackageListTableViewCell
        if !dataSource.isEmpty {
            cell.setCell(dataSource[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !dataSource.isEmpty {
            let model = dataSource[indexPath.row]
            if let url = model.h5Url,url != "" {
                let webViewCon = JRWebViewController()
                webViewCon.setTitle("", url: url)
                webViewCon.setNavigationBarHidden(true, hasBackButton: true)
                webViewCon.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(webViewCon, animated: true)
            }
        }
    }
}
