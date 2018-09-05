//
//  ESERPMatchController.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/28.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

/// ERP项目匹配
public class ESERPMatchController: ESBasicViewController, ESERPMatchViewDelegate, ESERPMatchCellDelegate, ESERPMatchBottomCellDelegate {
    private var assetId: String = ""
    private var orderInformation = ESPackageBaseInfo()
    private var dataArr: [ESERPMatchModel] = []
    
    private lazy var mainView: ESERPMatchView = {
        let view = ESERPMatchView(delegate: self)
        return view
    }()
    
    private var selectIndex: Int = 0
    
    init(assetId: String, model: ESPackageBaseInfo) {
        super.init(nibName: nil, bundle: nil)
        self.assetId = assetId
        self.orderInformation = model
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationTitleWithBack(title: "ERP项目匹配")
        
        self.view.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            }else {
                make.top.equalTo(self.topLayoutGuide.snp.bottom)
            }
        }
        ESProgressHUD.show(in: self.view)
        ESERPMatchDataManager.getERPList(orderInformation.consumerMobile!, success: { (array) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                self.dataArr = array
                self.mainView.refreshView()
            }
        }) {
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
            }
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ESTableViewProtocol
    func getItemNum(section: Int) -> Int {
        let empty = isEmpty()
        switch section {
        case 0:
            return empty ? 1 : dataArr.count
        default:
            return 1
        }
    }
    
    func getSectionNum() -> Int {
        return 2
    }
    
    // MARK: ESERPMatchViewDelegate
    func nextButtonClick() {
        if dataArr.count <= 0 {
            return
        }
        if let erpid = dataArr[selectIndex].erpId {
            ESProgressHUD.show(in: self.view)
            ESERPMatchDataManager.bindERP(assetId: self.assetId, erpId: erpid, success: {
                DispatchQueue.main.async {
                    ESProgressHUD.hide(for: self.view)
                    ESProgressHUD.showText(in: self.view, text: "绑定成功!")
                    for vc in (self.navigationController?.viewControllers.reversed())! {
                        if vc is ESDesProjectDetailController {
                            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5) {
                                DispatchQueue.main.async {
                                    self.navigationController?.popToViewController(vc, animated: true)
                                }
                            }
                            break
                        }
                    }
                }
            }) { (msg) in
                DispatchQueue.main.async {
                    ESProgressHUD.hide(for: self.view)
                    ESProgressHUD.showText(in: self.view, text: msg)
                }
            }
        }
    }
    
    func isEmpty() -> Bool {
        return dataArr.count <= 0
    }
    
    // MARK: ESERPMatchCellDelegate
    func getViewModel(index: Int, section: Int, cellId: String, viewModel: ESViewModel) {
        if cellId == "ESERPMatchCell" {
            if dataArr.count <= 0 {
                return
            }
            let erp = dataArr[index]
            let itemModel = viewModel as! ESERPMatchViewModel
            itemModel.consumerName = erp.name ?? "--"
            itemModel.projectAddr = erp.address ?? "--"
            itemModel.designerName = erp.designerName ?? "--"
            itemModel.serviceStore = erp.serviceStoreName ?? "--"
            let isSelected = index == self.selectIndex
            itemModel.isSelected = isSelected
        }
    }
    
    func selectItem(index: Int) {
        self.selectIndex = index
        mainView.refreshView()
    }
    
    // MARK: ESERPMatchBottomCellDelegate
    func tapSearchERP() {
        self.navigationController?.pushViewController(ESERPSearchController(assetId: assetId, model: orderInformation), animated: true)
    }
    
    func tapCreateERP() {
        self.navigationController?.pushViewController(ESERPCreateController(assetId: assetId, model: orderInformation), animated: true)
    }
}
