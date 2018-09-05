//
//  ESProProjectListControllerViewController.swift
//  Consumer
//
//  Created by Jiao on 2018/1/6.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

public class ESProProjectListController: ESBasicViewController, ESProProjectListViewDelegate, ESProProjectEmptyViewDelegate, ESProProjectListCellDelegate, ESProProjectListHeaderDelegate, ESProProjectListFooterDelegate {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitleWithBack(title: "我的装修项目")
        self.view.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            }else {
                make.top.equalTo(self.topLayoutGuide.snp.bottom)
            }
        }
        requestData(more: false)
    }
    
    public func requestData(more: Bool) {
        ESProgressHUD.show(in: self.view)
        ESProProjectListDataManager.getProjectList(limit, offset, success: { (array, count) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                self.mainView.endHeaderFresh()
                if !more {
                    self.dataArray.removeAll()
                }
                
                self.dataArray += array
                if array.count > 0 {
                    ESProProjectEmptyView.hideEmptyView(in: self.mainView)
                    self.mainView.endFooterFresh(noMore: self.dataArray.count >= count)
                    self.mainView.refreshMainView()
                } else {
                    self.mainView.endFooterFresh(noMore: true)
                    ESProProjectEmptyView.showEmptyView(in: self.mainView, delegate: self)
                }
            }
        }) {
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: "网络错误, 请稍后重试")
            }
        }
    }

    // MARK: - ESProProjectListViewDelegate
    func refreshProjectList() {
        offset = 0
        requestData(more: false)
    }
    
    func loadMoreProjectList() {
        offset += limit
        requestData(more: true)
    }
    
    func getItemNum(section: Int) -> Int {
        return 1
    }
    
    func getSectionNum() -> Int {
        return dataArray.count
    }
    
    // MARK: - ESProProjectEmptyViewDelegate
    /// 立即预约
    func booking() {
//        let vc = ESFreeAppointViewController()
//        navigationController?.pushViewController(vc, animated: true)
        let appointVC = UIStoryboard.init(name: "ESAppointVC", bundle: nil).instantiateViewController(withIdentifier: "AppointVC") as! ESAppointTableVC
        appointVC.selectedType = 7
        self.navigationController?.pushViewController(appointVC, animated: true)
    }
    
    // MARK: - ESProProjectListHeaderDelegate
    func getModel(index: Int, viewModel: ESESProProjectListHeaderViewModel) {
        if dataArray.count <= 0, dataArray.count <= index {
            return
        }
        let model = dataArray[index]
        ESProProjectListDataManager.getHeaderData(data: model, vm: viewModel)
    }
    
    // MARK: - ESProProjectListFooterDelegate
    func projectDetailClick(index: Int) {
        if dataArray.count <= index {
            return
        }
        let model = dataArray[index]
        if let assetId = model.assetId {
            let pkgTag = model.pkgViewFlag != nil ? String(model.pkgViewFlag!) : ""
            let vc = ESProProjectDetailContoller(assetId: String(assetId), pkgViewTag: pkgTag)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - ESProProjectListCellDelegate
    func getViewModel(index: Int, section: Int, cellId: String, viewModel: ESViewModel) {
        if dataArray.count <= 0, dataArray.count <= section {
            return
        }
        let vm = viewModel as! ESProProjectListViewModel
        let model = dataArray[section]
        ESProProjectListDataManager.manageData(data: model, vm: vm)
    }

    func phoneCall(phone: String) {
        ESDeviceUtil.callToSomeone(numberString: phone)
    }
    
    /// 设计师详情
    func designerDetail(index: Int) {
        if dataArray.count <= index {
            return
        }
        let model = dataArray[index]
        if let designer_id = model.designerId {

            let dict = ["designId":String(designer_id)]
            
            MGJRouter.openURL("/Design/DesignerDetail", withUserInfo: dict, completion: nil)
        }
    }
    
    func contactDesigner(index: Int) {
        if dataArray.count <= index {
            return
        }
        let model = dataArray[index]
        if ESStringUtil.isEmpty(model.designerMobile) {
            ESProgressHUD.showText(in: self.view, text: "该设计师暂未提供手机号码哦，请等待设计师联系您")
        } else {
            ESDeviceUtil.callToSomeone(numberString: model.designerMobile)
        }
    }
    
    /// 支付详情
    func payOrderDetail(index: Int) {
        if dataArray.count <= index {
            return
        }
        let model = dataArray[index]
        if let assetId = model.assetId,
              let orderId = model.mainOrderId, !orderId.isEmpty {
            var action = false
            let status = ESProjectReturnStatus(model.cashDto?[0].operateStatus)
            if status == .rejected || status == .unKnow {
               action = true
            }
            var showContract = false
            if let paiedFirstFee = model.paidFirstFee, !paiedFirstFee,
                let firstFee = model.containsFirstFee, firstFee,
                let unPay = model.unPaidAmount, unPay > 0 {
                showContract = true
            }
            let vc = ESGatheringDetailViewController(assetId: String(assetId),
                                                     orderId: orderId,
                                                     role: .proprietor(action: action, agreeContract: showContract, entry: .List))
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// 去支付
    func goToPay(index: Int) {
        if dataArray.count <= index {
            return
        }
        //先判断优惠券有效
        let model = dataArray[index]
        if let assetId = model.assetId {
            ESProgressHUD.show(in: self.view)
            ESProProjectDetailManager.checkCouponStatus(projectId: String(assetId), success: { (status) in
                DispatchQueue.main.async {
                    ESProgressHUD.hide(for: self.view)
                    status ? self.checkgoToPay(index: index) : ESAlertControllerTool.showAlert(currentVC: self, cancelBtn: "确认", meg: ESAlertMessage.InvalidationOfCouponsForHouseMaster.rawValue)
                }
            }, failure: { (msg) in
                DispatchQueue.main.async {
                    ESProgressHUD.hide(for: self.view)
                    ESProgressHUD.showText(in: self.view, text: msg)
                }
            })
        }
    }
    
    private func openPayTimesController(_ orderId: String, _ unPay: String) {
        let vc = ESPayTimesViewController(orderId: "",
                                          payOrderId: orderId,
                                          brandId: "",
                                          amount: unPay,
                                          partPayment: true,
                                          loanDic: ["":""],
                                          payType: .pkgProjectList,
                                          payTimesType: .again)
        navigationController?.pushViewController(vc!, animated: true)

    }
    
    /// 退款/退单详情
    func returnDetail(index: Int) {
        if dataArray.count <= index {
            return
        }
        let item = dataArray[index]
        if let data = item.cashDto?[0].drawCashOrderId, !data.isEmpty,
            let type = item.cashDto?[0].type {
            
            // 进入退单、退款详情
            if let cash = item.cashDto, let cashId = cash[0].drawCashOrderId, !cashId.isEmpty {
                let array = NSMutableArray()
                for order:ESProProjectListCashModel in cash{
                    array.add(order.drawCashOrderId!)

                }
                let cashIdArray = array.copy() as! [String]
                let vc = ESChargebackDetailViewController(cashIdArray,type == "project")
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            // 申请退单
            if let assetId = item.assetId {
                let vc = ESApplyChargebackViewController(assetId: String(assetId), block: {
                    self.requestData(more: false)
                })
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    /// 申请退款
    func withdrawClick(index: Int) {
        let alert = UIAlertController(title: "提示", message: "确定退款吗?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let confirm = UIAlertAction(title: "确定", style: .default) { (action) in
            self.withdraw(index)
        }
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// 申请退款
    func withdraw(_ index: Int) {
        if dataArray.count <= index {
            return
        }
        let item = dataArray[index]
        if let orderId = item.mainOrderId, !orderId.isEmpty {
            ESProgressHUD.show(in: self.view)
            ESProProjectListDataManager.withDraw(orderId: orderId, success: {
                DispatchQueue.main.async {
                    ESProgressHUD.hide(for: self.view)
                    self.requestData(more: false)
                }
            }, failure: { (msg) in
                
            })
        }
    }
    
    /// 去评价
    func evaluate(index: Int) {
        if dataArray.count <= index {
            return
        }
        let item = dataArray[index]
        if let assetId = item.assetId {
            let vc = ESEvaluateViewController(assetId: String(assetId),
                                              designerAvatar: item.designerAvatar,
                                              designerName: item.designerName)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    /// 校验订单是否可以立即支付
    func checkgoToPay(index: Int) {
        let model = dataArray[index]
        if let assetId = model.assetId {
            ESProgressHUD.show(in: self.view)
            ESProProjectDetailManager.goToPay(String(assetId), success: { (mainOrderId) in
                DispatchQueue.main.async {
                    ESProgressHUD.hide(for: self.view)
                    if let paiedFirstFee = model.paidFirstFee, !paiedFirstFee,
                        let firstFee = model.containsFirstFee, firstFee,
                        let unPay = model.unPaidAmount, unPay > 0 {
                        // 没有付过首款、待支付是否包含首款、未付金额 > 0
                        let alertView = UIAlertController(title: "提示", message: "在支付装修首款前，请先阅读并同意居然设计家平台的所有协议", preferredStyle: .alert)
                        let doneAction = UIAlertAction(title: "知道了", style: .default, handler: { (action) in
                            DispatchQueue.main.async {
                                let vc = ESContractListController(assetId: String(assetId),
                                                                  shouldAgree: true,
                                                                  type: .consumer,
                                                                  entry: .List)
                                vc.info = (mainOrderId, unPay)
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        })
                        alertView.addAction(doneAction)
                        DispatchQueue.main.async {
                            self.present(alertView, animated: true, completion: nil)
                        }
                        return
                    }
                    
                    if let unPay = model.unPaidAmount, unPay > 0 {
                        let unPayamount = String(format: "%.2f", unPay)
                        self.openPayTimesController(mainOrderId, unPayamount)
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
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Property
    private var limit: Int = 10
    private var offset: Int = 0
    
    private lazy var mainView: ESProProjectListView = {
        let view = ESProProjectListView(delegate: self)
        return view
    }()
    
    private var dataArray: [ESProProjectListItemModel] = []
    
}
