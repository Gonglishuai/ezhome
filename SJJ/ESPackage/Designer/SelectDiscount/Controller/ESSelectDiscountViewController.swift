//
//  ESSelectDiscountViewController.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/27.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

typealias DiscountSelectedBlock = ()->Void

/// 选择优惠券
class ESSelectDiscountViewController: ESBasicViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dataSource = [ESPackagePromotion]()
    var canChange = false
    
    private var viewManager = ESDiscountViewManager()
    private var assetId = ""
    private var selectBlock:DiscountSelectedBlock?
    private var errorView = ESErrorViewUtil()
    
    //MARK: - Init
    init(_ assetId: String, _ discount:[ESPackagePromotion], _ canChange:Bool) {
        super.init(nibName: nil, bundle: nil)
        self.dataSource = discount
        self.canChange = canChange
        self.assetId = assetId
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Life style
    override func viewDidLoad() {
        super.viewDidLoad()
        initilizaUI()
    }
    
    //MARK: - Init UI
    private func initilizaUI() {
        
        setupNavigationTitleWithBack(title: "选择优惠券")
        
        view.addSubview(viewManager.tableView)
        viewManager.tableView.delegate = self;
        viewManager.tableView.dataSource = self;
        
        let btnHeight:CGFloat = TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT
        viewManager.tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
             make.bottom.equalTo(view.snp.bottom).offset(-btnHeight)
        }
        
        let confirmButton = viewManager.completeButton(self)
        view.addSubview(confirmButton)
        
        confirmButton.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(btnHeight)
        }
        if BOTTOM_SAFEAREA_HEIGHT > 0 {
            confirmButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        }
        
        if !canChange {
            confirmButton.isHidden = true
            viewManager.tableView.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview()
            })
        }
        
        if dataSource.isEmpty {
            errorView.showNoDataView(in: viewManager.tableView)
        } else {
            errorView.hiddenErrorView()
        }
    }
    
    //MARK: - Network
    private func confirmCoupon(_ couponListDic:Dictionary<String, String>){
        
        ESAppointApi.confirmCoupon(assetId, parm: couponListDic, success: { (data) in
            
            if let block = self.selectBlock {
                block()
            }
            self.navigationController?.popViewController(animated: true)
            
        }) { (error) in
            MBProgressHUD.showError(SHRequestTool.getErrorMessage(error), to: self.view)
        }
    }
    
    //MARK: - Action
    
    func selectCoupon(block:@escaping DiscountSelectedBlock){
        self.selectBlock = block
    }
    
    func jumpToCouponUseDetail(index:Int){
        let model = dataSource[index]
        if let url = model.promotionH5Url {
            let webViewCon = JRWebViewController()
            webViewCon.setTitle("", url: url)
            webViewCon.setNavigationBarHidden(false, hasBackButton: false)
            webViewCon.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(webViewCon, animated: true)
        }
    }
    
    @objc func conformDiscount(){
        var selected = [String]()
        for model in dataSource {
            if let isSelected = model.isSelect, isSelected,
                let promotionId = model.promotionId {
                selected.append(String(promotionId))
            }
        }
        let listS = selected.joined(separator: ",")
        if listS.isEmpty {
            ESProgressHUD.showText(in: self.view, text: "您还没有选择任何优惠哦~")
        } else {
            confirmCoupon(["promotionIds":listS])
        }
    }
    
    //MARK: - UITableViewDelegate, UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ESSelectDiscountTableViewCell", for: indexPath)as!ESSelectDiscountTableViewCell
        
        cell.setCellIndex(indexPath.row, vc: self, model: dataSource[indexPath.row])
        
        return cell
    }

}
