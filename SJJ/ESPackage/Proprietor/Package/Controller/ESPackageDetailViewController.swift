//
//  ESPackageDetailViewController.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/29.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

/// 套餐想请
class ESPackageDetailViewController: ESBasicViewController,UITableViewDelegate, UITableViewDataSource {

    private lazy var viewManager = ESPackageViewManager()
    private var headerView:ESPackageDetailHeaderView!
    
    //MARK: - Life style
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        initilizeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false

    }
    //MARK: - Init UI
    private func initilizeUI(){
        
        headerView = ESPackageDetailHeaderView.loadNib()
        
        view.addSubview(headerView)
        headerView.setViewContainer(self)
 
        if ScreenHeight == 812 {
            headerView.frame = CGRect(x: 0, y: 24, width: ScreenWidth, height: 324)
        } else {
            headerView.snp.makeConstraints { (make) in
                make.left.equalTo(0)
                make.top.equalTo(0)
                make.right.equalTo(0)
                make.height.equalTo(324)
            }
        }

        view.addSubview(viewManager.detailTableView)
        viewManager.detailTableView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(headerView.snp.bottom)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        }
        viewManager.detailTableView.delegate = self;
        viewManager.detailTableView.dataSource = self;
        
    }
    
    func closeViewController(){
        navigationController?.popViewController(animated: true)
    }
    
    func orderButtonClick(){
        print("预约")
//        navigationController?.pushViewController(ESFreeAppointViewController(), animated: true)
    }
    
    //MARK: - UITableViewDelegate, UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESPackageDetailFirstTableViewCell", for: indexPath)as!ESPackageDetailFirstTableViewCell
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESPackageThirdTableViewCell", for: indexPath)as!ESPackageThirdTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESPackageDetailSecondTableViewCell", for: indexPath)as!ESPackageDetailSecondTableViewCell
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return 45
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESPreviewResultSectionHeader")as!ESPreviewResultSectionHeader
        view.setPackageDetaillayout()
        if 0 == section {
            view.sectionLeftLabel.text = ""
        } else {
            view.sectionLeftLabel.text = "卧室"
        }
        return view
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}
