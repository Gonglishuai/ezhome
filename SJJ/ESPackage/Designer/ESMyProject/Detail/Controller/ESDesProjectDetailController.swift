//
//  ESDesProjectDetailController.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/21.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

public class ESDesProjectDetailController: ESBasicViewController,
ESDesProjectDetailViewDelegate,
ESDesProjectDetailHeaderDelegate,
ESDesProjectDetailCellDelegate {
    
    private var assetId: String = ""
    private var pkgViewTag: String = ""
    private var dataModel = ESDesProjectDetailModel()
    private var cells: [(key: String, data: [String])] = []
    
    lazy var mainView: ESDesProjectDetailView = {
        let view = ESDesProjectDetailView(delegate: self)
        return view
    }()
    
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
        
        setupNavigationTitleWithBack(title: "项目详情")
        
        self.view.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
        }
        
        requestData()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestData() {
        ESProgressHUD.show(in: self.view)
        ESDesProjectDetailManager.getProjectDetail(assetId, pkgViewTag, success: { (data) in
            DispatchQueue.main.async {
                self.dataModel = data
                self.cells = ESDesProjectDetailManager.getCellsId(dataModel: data)
                self.mainViewManage()
                ESProgressHUD.hide(for: self.view)
            }
        }) { (errorMsg) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: errorMsg)
            }
        }
    }
    
    private func mainViewManage() {
        let status = ESProjectStatus(dataModel.baseInfo?.status)
        let project_type = ESProjectType(dataModel.baseInfo?.projectType)
        var showERP = true
        switch project_type {
        case .Package:
            switch status {
            case .allocating:
                fallthrough
            case .designing:
                if let erpId = dataModel.baseInfo?.erpId, !erpId.isEmpty {
                    showERP = false
                }
            default:
                showERP = false
            }
        default:
            showERP = false
        }
        
        let alertInfo = ESDesProjectDetailManager.manageAlertInfo(dataModel)
        self.mainView.updateView(matchERP: showERP, bottomAlert: alertInfo)
        if showERP {
            self.showERPAlert()
        }
    }
    
    private func showERPAlert() {
        let errorView = ESAlertView()
        errorView.setShowingElement(ESPackageAsserts.bundleImage(named: "create_project_fail"),
                                    mainTitle: "",
                                    subTitle: "亲爱的设计师您好，在进行下一步操作前，请您先关联ERP项目。关联后方可进行发起收款、录入合同、发起预交底等操作，感谢您的配合。",
                                    buttonTitle: "关联ERP项目",
                                    showClose: true)
        errorView.knownButtonClickBlock({
            self.matchERPBtnClick()
        })
       
        errorView.showViewAlterView()
    }
    
    // MARK: ESDesProjectViewDelegate
    func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell? {
        let cell = ESDesProjectDetailManager.getCell(tableView, self, indexPath, cells)
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
    
    func matchERPBtnClick() {
        if let phone = dataModel.baseInfo?.consumerMobile, !phone.isEmpty {
            let vc = ESERPMatchController(assetId: assetId, model: dataModel.baseInfo!)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: ESDesProjectDetailHeaderDelegate
    func getModel(index: Int, viewModel: ESDesProjectDetailHeaderViewModel) {
        ESDesProjectDetailManager.manageSecions(index, cells, dataModel, viewModel)
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
        ESDesProjectDetailManager.manageData(index, section, cellId, viewModel, dataModel)
    }
    
    // MARK: ESDesProjectOrderDetailCellDelegate
    func phoneTextClick(phone: String) {
        ESDeviceUtil.callToSomeone(numberString: phone)
    }
    
    func solutionCaseClick() {
        if let caseId = dataModel.baseInfo?.sourceUrl, !caseId.isEmpty {
            var info = ["caseid" : caseId]
            info["isnew"] = "1"
            var type = ""
            if let caseType = dataModel.baseInfo?.sourceType {
                if caseType == "3d" {
                    type = "1"
                }
            }
            
            info["type"] = type
            info["source"] = "1"
            MGJRouter.openURL("/Design/Example", withUserInfo: info, completion: nil)
        }
    }
    
    // MARK: ESDesProjectCostInfoCellDelegate
    /// 收款明细
    func receivablesDetailClick() {
//        if let base = dataModel.baseInfo, let assertId = base.assetId, let orderId = base.mainOrderId, !orderId.isEmpty {
        let vc = ESGatheringDetailViewController(assetId: String(dataModel.baseInfo?.assetId ?? -1), orderId: dataModel.baseInfo?.mainOrderId ?? "-1", role: .designer)
            navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    /// 交易流水
    func paiedDetailClick() {
//        if let base = dataModel.baseInfo, let orderId = base.mainOrderId {
            let vc = ESTransactionViewController(assetId: String(dataModel.baseInfo?.assetId ?? -1), orderId: dataModel.baseInfo?.mainOrderId ?? "-1", role: .designer)
            vc.comeFromDetail = true
            navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    /// 选择优惠
    func discountsChoiceClick() {
        if let base = dataModel.baseInfo,
            let assetId = base.assetId,
            let list = dataModel.promotionList {
            var canChange = true
            if let first = base.hasFirstFee, first {// 如果发起了首款，则不能再绑定优惠
                canChange = false
            }
            let vc = ESSelectDiscountViewController(String(assetId), list, canChange)
            vc.selectCoupon(block: {
                //添加刷新
                self.requestData()
            })
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// 面对面收款
    func faceToFaceClick() {
        if let assetId = dataModel.baseInfo?.assetId,
            let unpay = dataModel.baseInfo?.unPaidAmount, unpay > 0 {
            //先判断优惠券有效
            ESProgressHUD.show(in: self.view)
            ESProProjectDetailManager.checkCouponStatus(projectId: String(assetId), success: { (status) in
                DispatchQueue.main.async {
                    ESProgressHUD.hide(for: self.view)
                    status ? self.checkgoToPay() : ESAlertControllerTool.showAlert(currentVC: self, cancelBtn: "确认", meg: ESAlertMessage.InvalidationOfCouponsForDesigner.rawValue)
                }
            }, failure: { (msg) in
                DispatchQueue.main.async {
                    ESProgressHUD.hide(for: self.view)
                    ESProgressHUD.showText(in: self.view, text: msg)
                }
            })
        }
    }
    
    /// 校验订单是否可以立即支付
    private func checkgoToPay() {
        let assetId = dataModel.baseInfo?.assetId
        let unpay = dataModel.baseInfo?.unPaidAmount
        let alertVc = UIAlertController(title: "请选择收款方式", message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let action1 = UIAlertAction(title: ESFaceToFacePayType.Alipay.rawValue.text, style: .default, handler: { (action) in
            self.gotoFaceToFace(String(assetId!), unpay!, .Alipay)
        })
        let action2 = UIAlertAction(title: ESFaceToFacePayType.Wechat.rawValue.text, style: .default, handler: { (action) in
            self.gotoFaceToFace(String(assetId!), unpay!, .Wechat)
        })
        
        
        alertVc.addAction(action)
        alertVc.addAction(action1)
        alertVc.addAction(action2)
        DispatchQueue.main.async {
            self.present(alertVc, animated: true, completion: nil)
        }
    }
    
    private func gotoFaceToFace(_ assetId: String, _ amount: Double, _ type: ESFaceToFacePayType) {
        let vc = ESFaceToFaceController(assetId: assetId, amount: amount, payType: type)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 发起收款
    func receiptClick() {
        if let base = dataModel.baseInfo, let assetId = base.assetId {
            let aid = String(assetId)
            let erpId = dataModel.baseInfo?.erpId ?? ""
            var proList = [ESPackagePromotion]()
            
            if let list = dataModel.promotionList, list.count > 0 {
                proList = list.filter{$0.isSelect != nil && $0.isSelect!}
            }
            
            let showContract = ESStringUtil.isEmpty(dataModel.contractInfo?.signDate)
            var model = ESAgreementModel()
            model.erpId = base.erpId ?? ""
            model.projectId = aid
            model.name = base.consumerName ?? ""
            model.mobile = base.consumerMobile ?? ""
            model.houseSize = base.houseArea ?? ""
            model.roomType = base.roomType ?? ""
            model.houseType = base.houseType ?? ""
            model.province = base.provinceName ?? ""
            model.provinceCode = base.provinceCode ?? ""
            model.city = base.cityName ?? ""
            model.cityCode = base.cityCode ?? ""
            model.district = base.districtName ?? ""
            model.districtCode = base.districtCode ?? ""
            model.community = base.communityName ?? ""
            model.address = base.address ?? ""
            var amount = "0.00"
            if let erpAmount = dataModel.amount {
                amount = String(format: "%.2f", erpAmount)
            }
            model.amount = amount
            var payTypes = [ESPkgOrderType]()
            let status = ESProjectPreviewStatus(dataModel.designStatus)
            payTypes.append(.EARNEST)
            if let hasFirstFee = base.hasFirstFee, !hasFirstFee, status == .passed {
                // 所有订单不包括首款且图纸报价审核通过，才可以发起首款
                payTypes.append(.FIRST_FEE)
            }
            payTypes.append(.MATERIAL)
            let vc = ESInitiatePaymentViewController(aid, erpId, proList, showContract, model, payTypes, complete: {
                self.requestData()
            })
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: ESDesProjectContractCellDelegate
    // 查看合同详情
    func contractDetailClick() {
        if let assetId = dataModel.baseInfo?.assetId {
            let str = String(assetId)
            let vc = ESContractListController(assetId: str,
                                              shouldAgree: false,
                                              type: .designer,
                                              entry: .Detail)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// 录入合同
    func createContractClick() {
        if let base = dataModel.baseInfo, let assetId = base.assetId {
            let vc = ESAgreementViewController()
            vc.upload.erpId = base.erpId ?? ""
            vc.upload.projectId = String(assetId)
            vc.upload.name = base.consumerName ?? ""
            vc.upload.mobile = base.consumerMobile ?? ""
            vc.upload.houseSize = base.houseArea ?? ""
            vc.upload.roomType = base.roomType ?? ""
            vc.upload.houseType = base.houseType ?? ""
            vc.upload.province = base.provinceName ?? ""
            vc.upload.provinceCode = base.provinceCode ?? ""
            vc.upload.city = base.cityName ?? ""
            vc.upload.cityCode = base.cityCode ?? ""
            vc.upload.district = base.districtName ?? ""
            vc.upload.districtCode = base.districtCode ?? ""
            vc.upload.community = base.communityName ?? ""
            vc.upload.address = base.address ?? ""
            vc.AgreeAgreementBlock = {
                self.requestData()
            }
            var amount = "0.00"
            if let erpAmount = dataModel.amount {
                amount = String(format: "%.2f", erpAmount)
            }
            vc.upload.amount = amount
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// 修改合同
    func editContractClick() {
        if let contract = dataModel.contractInfo, let base = dataModel.baseInfo, let assetId = base.assetId {
            let vc = ESAgreementViewController()
            vc.upload.erpId = base.erpId ?? ""
            vc.upload.projectId = String(assetId)
            vc.upload.name = base.consumerName ?? ""
            vc.upload.mobile = base.consumerMobile ?? ""
            vc.upload.houseSize = base.houseArea ?? ""
            vc.upload.roomType = base.roomType ?? ""
            vc.upload.houseType = base.houseType ?? ""
            vc.upload.province = base.provinceName ?? ""
            vc.upload.provinceCode = base.provinceCode ?? ""
            vc.upload.city = base.cityName ?? ""
            vc.upload.cityCode = base.cityCode ?? ""
            vc.upload.district = base.districtName ?? ""
            vc.upload.districtCode = base.districtCode ?? ""
            vc.upload.community = base.communityName ?? ""
            vc.upload.address = base.address ?? ""
            vc.upload.amount = contract.amount != nil ? String(format: "%.2f", contract.amount!) : "0.00"
            vc.upload.signDate = contract.signDate ?? ""
            vc.upload.startDate = contract.startDate ?? ""
            vc.upload.proNumber = contract.proNumber != nil ? String(contract.proNumber!) : ""
            let weekend = contract.weekendConstruct ?? 0
            vc.upload.weekendConstruct = String(weekend)
            vc.upload.completeDate = contract.completeDate ?? ""
            vc.upload.remark = contract.remark ?? ""
            vc.AgreeAgreementBlock = {
                self.requestData()
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: ESDesProjectPreviewCellDelegate
    /// 预交底详情
    func previewDetailClick() {
        if let base = dataModel.baseInfo, let assetId = base.assetId {
            let preStatus = ESProjectPreviewStatus(dataModel.preConfirm?.status)
            if preStatus != .unKnow && preStatus != .notApply {
                let vc = ESPreviewResultDetailViewController(assetId: String(assetId))
                navigationController?.pushViewController(vc, animated: true)
            } else {
                ESProgressHUD.showText(in: self.view, text: "您暂未发起预交底哦~")
            }
        }
    }
    
    /// 发起预交底
    func createPreviewClick() {
        if let base = dataModel.baseInfo {
            var model = ESPreviewResultUploadModel()
            model.erpId = base.erpId ?? ""
            model.projectId = base.assetId != nil ? String(base.assetId!) : ""
            model.name = base.consumerName ?? ""
            model.mobile = base.consumerMobile ?? ""
            model.community = base.communityName ?? ""
            model.province = base.provinceName ?? ""
            model.provinceCode = base.provinceCode ?? ""
            model.city = base.cityName ?? ""
            model.cityCode = base.cityCode ?? ""
            model.district = base.districtName ?? ""
            model.districtCode = base.districtCode ?? ""
            model.roomType = base.roomType ?? ""
            model.houseType = base.houseType ?? ""
            model.houseSize = base.houseArea ?? ""
            model.community = base.communityName ?? ""
            model.address = base.address ?? ""
            
            let vc = ESPreviewResultViewController(uploadModel: model, block: {
                self.requestData()
            })
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// 取消预交底申请
    func cancelPreviewClick() {
        ESProgressHUD.show(in: self.view)
        ESDesProjectDetailManager.cancelProjectPreview(dataModel.baseInfo?.assetId, success: {
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: "取消成功")
                self.requestData()
            }
        }) { (errorMsg) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: errorMsg)
            }
        }
    }
    
    // MARK: ESDesProjectQuoteInfoCellDelegate
    func quoteInfoDetailClick() {
        if let base = dataModel.baseInfo, let assetId = base.assetId {
            let status = ESProjectPreviewStatus(dataModel.designStatus)
            if status != .unKnow && status != .notApply {
                let vc = ESOfferDetailViewController(assetId: String(assetId))
                navigationController?.pushViewController(vc, animated: true)                
            } else {
                ESProgressHUD.showText(in: self.view, text: "您暂未发起图纸报价审核哦~")
            }
        }
    }
    
    // MARK: ESDesProjectDeliveryInfoCellDelegate
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
}
