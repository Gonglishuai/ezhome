//
//  ESGatheringDetailViewController.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/18.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

enum ESRole {
    case proprietor(action: Bool, agreeContract: Bool, entry: EntryType)
    case designer
}

/// 收款明细
class ESGatheringDetailViewController: ESBasicViewController , ESGatheringExpressionDelegate , ESDesignerGathringViewForTableHeaderDelegate{
    
    lazy var cellTitle = [String]()
    var comeFromDetail = true
    
    private lazy var viewManager = ESDesignerGathringViewManager()
    private var dataSource:ESGatheringDetailsModel?
    private var assetId = ""
    private var orderId = ""
    private var role:ESRole = .designer
    private var payButton:UIButton!
    
    //MARK: - Init
    init(assetId: String, orderId: String, role: ESRole) {
        super.init(nibName: nil, bundle: nil)
        self.assetId = assetId
        self.orderId = orderId
        self.role = role
        self.viewManager.role = role
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
        var middleTitle = "收款明细"
        switch role {
        case .proprietor(_):
            middleTitle = "付款明细"
        default:
            break
        }
        setupNavigationTitleWithBack(title: middleTitle)
        
        setupCustomRightItemWithTitle(title: "交易流水", color: ESColor.color(sample: .buttonBlue), font: ESFont.font(name: ESFont.ESFontName.regular, size: 13))
    }
    
    private func initilizaUI() {
        cellTitle = ESGatheringDetailModel.createModel(role: role)
        view.addSubview(viewManager.tableView)
        viewManager.tableView.delegate = self;
        viewManager.tableView.dataSource = self;
        viewManager.gathringTableHeader.headerDelegate = self
        viewManager.transactionTableHeader.headerDelegate = self
        viewManager.tableView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        switch role {
        case .proprietor(let action, _, _):
            viewManager.tableView.snp.updateConstraints({ (make) in
                make.bottom.equalTo(view.snp.bottom).offset(-50)
            })
            payButton = viewManager.payImmediately(self)
            payButton.isEnabled = action
            view.addSubview(payButton)
            let btnHeight = TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT
            payButton.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(btnHeight)
            }
            if BOTTOM_SAFEAREA_HEIGHT > 0 {
                payButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
            }
        default:
            break
        }
    }
    
    //MARK: - Network
    private var errorView =  ESErrorViewUtil()

    private func gatheringDetail(){
        
        ESProgressHUD.show(in: self.view)
        ESAppointApi.getGatheringDetail(assetId, success: { (data) in
            
            ESProgressHUD.hide(for: self.view)
            self.errorView.hiddenErrorView()
            let deatilModel = try?JSONDecoder().decode(ESGatheringDetailsModel.self, from: data)
            
            if let model = deatilModel {
                self.loadData(model: model)
            } else {
               self.errorView.showNoDataView(in: self.view)
            }
        }) { (error) in
            ESProgressHUD.hide(for: self.view)
            MBProgressHUD.showError(SHRequestTool.getErrorMessage(error), to: self.view)
        }
    }
    
    //MARK: - Actions
    override func navigationBarRightAction() {
        print("交易流水")
        if comeFromDetail {
            let vc = ESTransactionViewController(assetId: assetId, orderId: orderId, role: role)
            vc.comeFromDetail = false
            navigationController?.pushViewController(vc, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func loadData(model:ESGatheringDetailsModel){
        self.dataSource = model
        if let realData = model.data {//设置待收金额
            self.viewManager.gathringTableHeader.setupGathringDetailHeaderModel(realData, role: self.role)
            self.viewManager.tableView.reloadData()
        }
        switch self.role {
        case .proprietor(let action, _, _):
            if let data = model.data, let unPay = data.unPaidAmount, unPay > 0.0, action {
                self.payButton.backgroundColor = ESColor.color(sample: .buttonBlue)
                self.payButton.isEnabled = true
            } else {
                self.payButton.backgroundColor = ESColor.color(sample: .subTitleColor)
                self.payButton.isEnabled = false
            }
        default:
            break
        }
    }
    
    private func payClick() {
        var showContract = false
        var entryType = EntryType.Detail
        switch role {
        case .proprietor( _, let agreeContract, let entry):
            showContract = agreeContract
            entryType = entry
        default:
            break
        }
        
        //先判断优惠券有效
        ESProgressHUD.show(in: self.view)
        ESProProjectDetailManager.checkCouponStatus(projectId: assetId, success: { (status) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                status ? self.checkgoToPay(showContract: showContract, entryType: entryType) : ESAlertControllerTool.showAlert(currentVC: self, cancelBtn: "确认", meg: ESAlertMessage.InvalidationOfCouponsForDesigner.rawValue)
            }
        }, failure: { (msg) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: msg)
            }
        })
    }
    
    /// 校验订单是否可以立即支付
    private func checkgoToPay(showContract: Bool, entryType: EntryType) {
        ESProgressHUD.show(in: self.view)
        ESProProjectDetailManager.goToPay(assetId, success: { (mainOrderId) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                if let model = self.dataSource,let data = model.data, let unPay = data.unPaidAmount, unPay > 0 {
                    let unPayamount = String(format: "%.2f", unPay)
                    
                    if showContract {
                        let vc = ESContractListController(assetId: String(self.assetId),
                                                          shouldAgree: true,
                                                          type: .consumer,
                                                          entry: entryType)
                        vc.info = (mainOrderId, Double(unPay))
                        self.navigationController?.pushViewController(vc, animated: true)
                        return
                    }
                    self.openPayTimesController(mainOrderId, unPayamount, entryType)
                }
            }
        }) { (msg) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: msg)
            }
        }
    }
    
    private func openPayTimesController(_ orderId: String, _ unPay: String, _ entry: EntryType) {
        let payType = entry == .List ? ESPayType.pkgProjectList : ESPayType.pkgProjectDetail
        let vc = ESPayTimesViewController(orderId: "",
                                          payOrderId: orderId,
                                          brandId: "",
                                          amount: unPay,
                                          partPayment: true,
                                          loanDic: ["":""],
                                          payType: payType,
                                          payTimesType: .again)
        navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func payImmediately(){
        payClick()
    }
}

extension ESGatheringDetailViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let model = dataSource,let data = model.data,
            let list = data.orderList {
            return list.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitle.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let model = dataSource,let data = model.data,
            let list = data.orderList {

            viewManager.designerGathringViewManagerDelegate = self;
    
            return viewManager.returnDesignerGatheringDetailCell(tableView: tableView, cellForRowAt: indexPath, cellTitle: cellTitle, listModel: list[indexPath.section])
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESGathringSectionFooterView")as!ESGathringSectionFooterView
        
        if let model = dataSource,let data = model.data,
            let list = data.orderList {
            view.setDateLabel(model: list[section],role: role)
        }
        return view
    }
    
    func cancelPay(_ orderId: String) {
        ESAlertControllerTool.showAlert(currentVC: self, meg: "撤销后的费用在项目详情中将不再展示，确定撤销？", cancelBtn: "取消", otherBtn: "确认") { (alertAction) in
            ESProProjectDetailManager.cancelPay(self.assetId, orderId: orderId, success: {(status) in
                DispatchQueue.main.async {
                    ESProgressHUD.hide(for: self.view)
                    ESProgressHUD.showText(in: self.view, text: status ? "撤销成功" : "撤销失败，建议重新撤销")
                    status ? self.gatheringDetail() : nil
                    for vc in (self.navigationController?.viewControllers.reversed())! {
                        if let dvc = vc as? ESDesProjectDetailController {
                            dvc.requestData()
                            break
                        }
                    }
                }
            }, failure: { (msg) in
                DispatchQueue.main.async {
                    ESProgressHUD.hide(for: self.view)
                    ESProgressHUD.showText(in: self.view, text: msg)
                }
            })
        }
    }
    
    func openTipsView() {
        ESAlertControllerTool.showAlert(currentVC: self, cancelBtn: "确定", meg: "1、装修项目中的每项优惠，均有时效性，请务必在有效期内进行支付\n  2、若在优惠有效期内未支付，则该笔款项作废，建议设计师撤销该笔费用收款，重新发起")
    }
}
