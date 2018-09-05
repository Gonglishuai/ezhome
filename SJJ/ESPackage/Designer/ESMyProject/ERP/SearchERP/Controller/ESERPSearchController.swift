//
//  ESERPSearchController.swift
//  ESPackage
//
//  Created by 焦旭 on 2018/1/2.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESERPSearchController: ESBasicViewController, ESERPSearchViewDelegate {
    private var assetId = ""
    private var orderInformation = ESPackageBaseInfo()
    private var erpId = ""
    private var model = ESERPMatchModel()
    private var canBind = false
    
    init(assetId: String, model: ESPackageBaseInfo) {
        super.init(nibName: nil, bundle: nil)
        self.assetId = assetId
        self.orderInformation = model
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationTitleWithBack(title: "查询ERP项目")
        
        self.view.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            }else {
                make.top.equalTo(self.topLayoutGuide.snp.bottom)
            }
        }
    }
    
    func request() {
        ESERPSearchViewManager.getERP(erpId, orderInformation.consumerMobile!, success: { (erpModel) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                self.model = erpModel
                self.canBind = true
                self.mainView.updateView()
            }
        }) { (msg) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: msg)
                self.canBind = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - ESERPSearchViewDelegate
    func getViewModel(viewModel: ESERPSearchViewModel) {
        viewModel.consumerName = model.name ?? "--"
        viewModel.projectAddr = model.address ?? "--"
        viewModel.designerName = model.designerName ?? "--"
        viewModel.serviceStore = model.serviceStoreName ?? "--"
        viewModel.canNext = canBind
    }
    
    func erpSearch(code: String?) {
        if let erpID = code, !erpID.isEmpty {
            erpId = erpID
            request()
        }
    }
    
    func nextButtonClick() {
        ESERPMatchDataManager.bindERP(assetId: assetId, erpId: erpId, success: {
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
    
    private lazy var mainView: ESERPSearchView = {
        let view = ESERPSearchView(delegate: self)
        return view
    }()

}
