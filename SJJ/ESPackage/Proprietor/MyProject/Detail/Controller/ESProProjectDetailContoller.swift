//
//  ESProProjectDetailContoller.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

public class ESProProjectDetailContoller: ESBasicViewController,
ESProProjectDetailViewDelegate,
ESProProjectDetailHeaderDelegate,
ESProProjectDetailFooterDelegate,
ESProProjectDetailCellDelegate {
    
    private var assetId: String = ""
    private var pkgViewTag: String = ""
    private var dataModel = ESProProjectDetailModel()
    private var cells: [(key: String, data: [String])] = []
    
    
    init(assetId: String, pkgViewTag: String) {
        super.init(nibName: nil, bundle: nil)
        self.assetId = assetId
        self.pkgViewTag = pkgViewTag
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        setupNavigationTitleWithBack(title: "我的装修项目")
        view.addSubview(mainView)
        setUpRightItem()
        mainView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        requestData()
    }
    
    private func setUpRightItem() {
        let rightItem = UIBarButtonItem(customView: rightBtn)
        navigationItem.rightBarButtonItem = rightItem
    }
    
    public func requestData() {
        ESProgressHUD.show(in: self.view)
        ESProProjectDetailManager.getProjectDetail(assetId, pkgViewTag, success: { (data) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                self.dataModel = data
                self.cells = ESProProjectDetailManager.getCellsId(dataModel: data)
                self.mainView.refreshMainView()
                self.manageRightItem()
            }
        }) {
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
            }
        }
    }
    
    private func manageRightItem() {
        if let base = dataModel.baseInfo {
            let status = ESProjectStatus(base.status)
            switch status {
            case .canceled:
                fallthrough
            case .completed:
                fallthrough
            case .notThrough:
                fallthrough
            case .toEvaluate:
                fallthrough
            case .unKnow:
                rightBtn.isHidden = true
            case .allocating:
                rightBtn.isHidden = false
            case .designing:
                if let payAmount = base.paidAmount, payAmount > 0 {
                    rightBtn.isHidden = true
                } else {
                    rightBtn.isHidden = false
                }
            }
            
        }
    }

    @objc private func rightItemBtnClick() { /// 取消预约
        
        if let info = dataModel.baseInfo, let assetId = info.assetId {
            let vc = ESCancleAppointViewController(assetId: "\(assetId)", block: {
                self.requestData()
            })
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ESProProjectDetailViewDelegate
    func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell? {
        let cell = ESProProjectDetailManager.getCell(tableView, self, indexPath, cells)
        return cell
    }
    
    func getSectionNum() -> Int {
        return cells.count
    }
    
    func getItemNum(section: Int) -> Int {
        if cells.count < section + 1 {
            return 0
        }
        return cells[section].data.count
    }

    // MARK: - ESProProjectDetailHeaderDelegate
    func getModel(index: Int, viewModel: ESProProjectDetailHeaderViewModel) {
        ESProProjectDetailManager.manageSection(index, cells, viewModel, dataModel)
    }
    
    /// 费用详情
    func subTitleClick(index: Int) {
        if let url = dataModel.baseInfo?.amountRedirectUrl {
            let vc = JRWebViewController()
            vc.setTitle("费用详情", url: url)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - ESTableViewCellProtocol
    func getViewModel(index: Int, section: Int, cellId: String, viewModel: ESViewModel) {
        ESProProjectDetailManager.manageData(dataModel, index, section, cellId, viewModel)
    }
    
    // MARK: - ESProProjectRejectCancelCellDelegate
    func goToBooking() {
//        let vc = ESFreeAppointViewController()
//        navigationController?.pushViewController(vc, animated: true)
        let appointVC = UIStoryboard.init(name: "ESAppointVC", bundle: nil).instantiateViewController(withIdentifier: "AppointVC") as! ESAppointTableVC
        appointVC.selectedType = 7
        self.navigationController?.pushViewController(appointVC, animated: true)
    }
    
    // MARK: - ESProProjectDesignerCellDelegate
    /// 设计师主页
    func designerDetail() {
        if let designerId = dataModel.designerInfo?.designerId {
            
            let dict = ["designId":String(designerId)]
            
            MGJRouter.openURL("/Design/DesignerDetail", withUserInfo: dict, completion: nil)
            
        }
    }
    
    /// 联系设计师
    func contactDesigner() {
        if let phone = dataModel.designerInfo?.designerMobile {
            ESDeviceUtil.callToSomeone(numberString: phone)
        } else {
            ESProgressHUD.showText(in: self.view, text: "该设计师暂未提供手机号码哦，请等待设计师联系您")
        }
    }
    
    // MARK: - ESProProjectContractCellDelegate
    func contractDetail() {
        let vc = ESContractListController(assetId: assetId, shouldAgree: false, type: .consumer, entry: .Detail)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - ESProProjectCostInfoCellDelegate
    /// 付款明细
    func paiedDetailClick() {
        var action = false
        let cashStatus = ESProjectReturnStatus(dataModel.cashDto?[0].operateStatus)
        let projectStatus = ESProjectStatus(dataModel.baseInfo?.status)
        if projectStatus == .designing && (cashStatus == .rejected || cashStatus == .unKnow) {
            action = true
        }
        
        var showContract = false
        if let paiedFirstFee = dataModel.baseInfo?.paidFirstFee, !paiedFirstFee,
            let firstFee = dataModel.baseInfo?.containsFirstFee, firstFee,
            let unPay = dataModel.baseInfo?.unPaidAmount, unPay > 0 {
            showContract = true
        }
        let vc = ESGatheringDetailViewController(assetId: String(dataModel.baseInfo?.assetId ?? -1),
                                                 orderId: dataModel.baseInfo?.mainOrderId ?? "-1",
                                                 role: .proprietor(action: action, agreeContract: showContract, entry: .Detail))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 交易明细
    func dealDetailClick() {
        var action = false
        let cashStatus = ESProjectReturnStatus(dataModel.cashDto?[0].operateStatus)
        let projectStatus = ESProjectStatus(dataModel.baseInfo?.status)
        if projectStatus == .designing && (cashStatus == .rejected || cashStatus == .unKnow) {
            action = true
        }
        var showContract = false
        if let paiedFirstFee = dataModel.baseInfo?.paidFirstFee, !paiedFirstFee,
            let firstFee = dataModel.baseInfo?.containsFirstFee, firstFee,
            let unPay = dataModel.baseInfo?.unPaidAmount, unPay > 0 {
            showContract = true
            return
        }
        let vc = ESTransactionViewController(assetId: String(dataModel.baseInfo?.assetId ?? -1),
                                             orderId: dataModel.baseInfo?.mainOrderId ?? "-1",
                                             role: .proprietor(action: action, agreeContract: showContract, entry: .Detail))
        vc.comeFromDetail = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 点击立即支付
    func payClick(type: ESCostPayBtnType) {
        switch type {
        case .confirmLastFee:
            let alertVC = UIAlertController(title: "提示", message: "是否确认尾款?", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "否", style: .cancel, handler: nil)
            let action2 = UIAlertAction(title: "是", style: .default, handler: { (action) in
                self.confrimLastFee()
            })
            alertVC.addAction(action1)
            alertVC.addAction(action2)
            DispatchQueue.main.async {
                self.present(alertVC, animated: true, completion: nil)
            }
        case .payment:
            goToPay()
        }
    }
    
    private func confrimLastFee() {
        if let orderId = dataModel.baseInfo?.mainOrderId, !orderId.isEmpty {
            ESProgressHUD.show(in: self.view)
            ESProProjectDetailManager.confirmLastFee(orderId, success: {
                DispatchQueue.main.async {
                    ESProgressHUD.hide(for: self.view)
                    ESProgressHUD.showText(in: self.view, text: "确认尾款")
                    self.requestData()
                }
            }, failure: { (msg) in
                DispatchQueue.main.async {
                    ESProgressHUD.hide(for: self.view)
                    ESProgressHUD.showText(in: self.view, text: msg)
                }
            })
        }
    }
    
    private func goToPay() {
        //先判断优惠券有效
        ESProgressHUD.show(in: self.view)
        ESProProjectDetailManager.checkCouponStatus(projectId: assetId, success: { (status) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                status ? self.checkgoToPay() : ESAlertControllerTool.showAlert(currentVC: self, cancelBtn: "确认", meg: ESAlertMessage.InvalidationOfCouponsForHouseMaster.rawValue)
            }
        }, failure: { (msg) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: msg)
            }
        })
    }
    
    /// 校验订单是否可以立即支付
    private func checkgoToPay() {
        ESProgressHUD.show(in: self.view)
        ESProProjectDetailManager.goToPay(assetId, success: { (mainOrderId) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                if let paiedFirstFee = self.dataModel.baseInfo?.paidFirstFee, !paiedFirstFee,
                    let firstFee = self.dataModel.baseInfo?.containsFirstFee, firstFee,
                    let unPay = self.dataModel.baseInfo?.unPaidAmount, unPay > 0 {
                    // 没有付过首款、待支付是否包含首款、未付金额 > 0
                    let alertView = UIAlertController(title: "提示", message: "在支付装修首款前，请先阅读并同意居然设计家平台的所有协议", preferredStyle: .alert)
                    let doneAction = UIAlertAction(title: "知道了", style: .default, handler: { (action) in
                        DispatchQueue.main.async {
                            let vc = ESContractListController(assetId: String(self.assetId),
                                                              shouldAgree: true,
                                                              type: .consumer,
                                                              entry: .Detail)
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
                self.openPayTimesController(mainOrderId)
            }
        }) { (msg) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: msg)
            }
        }
    }
    
    private func openPayTimesController(_ orderId: String) {
        if let unPay = dataModel.baseInfo?.unPaidAmount, unPay > 0 {
            let amount = String(format: "%.2f", unPay)
            let vc = ESPayTimesViewController(orderId: "",
                                              payOrderId: orderId,
                                              brandId: "",
                                              amount: amount,
                                              partPayment: true,
                                              loanDic: ["":""],
                                              payType: .pkgProjectDetail,
                                              payTimesType: .again)
            navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    // MARK: - ESProProjectPreviewInfoCellDelegate
    func phoneTextClick(phone: String) {
        ESDeviceUtil.callToSomeone(numberString: phone)
    }
    
    // MARK: - ESProProjectDeliveryInfoCellDelegate
    func deliveryDetailClick(index: Int) {
        if let list = dataModel.cases {
            if list.count < index + 1 {
                return
            }
            let caseItem = list[index]
            let assetId = caseItem.assetId != nil ? String(caseItem.assetId!) : ""
            var info = ["caseid" : assetId]
            info["isnew"] = "1"
            info["type"] = "1"
            info["source"] = "2"
            MGJRouter.openURL("/Design/Example", withUserInfo: info, completion: nil)
        }
    }
    
    func deliveryQuoteClick(index: Int) {
        if let list = dataModel.cases {
            if list.count < index + 1 {
                return
            }
            let caseItem = list[index]
            if let quoteId = caseItem.quoteId, !quoteId.isEmpty {
                let vc = ESCaseOfferViewController(assetId: quoteId)
                navigationController?.pushViewController(vc, animated: true)
            } else {
                ESProgressHUD.showText(in: self.view, text: "该方案暂无报价信息!")
            }
        }
    }
    
    // MARK: - ESProProjectDetailFooterDelegate
    func getFooterText() -> String? {
        return ESProProjectDetailManager.manageFooter(dataModel)
    }
    
    func applyReturn() {
        let status = ESProjectReturnStatus(dataModel.cashDto?[0].operateStatus)
        if let data = dataModel.cashDto?[0].drawCashOrderId, !data.isEmpty,
            let type = dataModel.cashDto?[0].type, status != .rejected {

            // 进入退单、退款详情
            if let cash = dataModel.cashDto, let cashId = cash[0].drawCashOrderId, !cashId.isEmpty {
                let vc = ESChargebackDetailViewController([cashId],type == "project")
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            // 申请退单
            if let base = dataModel.baseInfo, let assetId = base.assetId {
                let vc = ESApplyChargebackViewController(assetId: String(assetId), block: {
                    self.requestData()
                })
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: - lazy loading
    lazy var mainView: ESProProjectDetailView = {
        let view = ESProProjectDetailView(delegate: self)
        return view
    }()
    
    private lazy var rightBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
        btn.addTarget(self, action: #selector(ESProProjectDetailContoller.rightItemBtnClick), for: .touchUpInside)
        btn.setTitle("取消预约", for: .normal)
        btn.titleLabel?.font = ESFont.font(name: .regular, size: 14.0)
        btn.setTitleColor(ESColor.color(sample: .buttonBlue), for: .normal)
        btn.isHidden = true
        return btn
    }()
}
