//
//  ESProProjectListDataManager.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/8.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESProProjectListDataManager: NSObject {
    static func getProjectList(_ limit: Int,
                        _ offset: Int,
                        success: @escaping ([ESProProjectListItemModel], _ count: Int) -> Void,
                        failure: @escaping () -> Void) {
        ESPackageProjectApi.getProprietorProjectList(limit: limit, offset: offset, success: { (response) in
            if let data = response {
                print("我的项目列表: \(String(data: data, encoding: .utf8) ?? "error")")
                let arr = try? JSONDecoder().decode(ESProProjectListModel.self, from: data)
                if let list = arr {
                    success(list.data ?? [], list.count ?? 0)
                }
            }else {
                failure()
            }
        }) { (error) in
            failure()
        }
    }
    
    static func getHeaderData(data: ESProProjectListItemModel, vm: ESESProProjectListHeaderViewModel) {
        vm.projectId = (data.assetId != nil) ? String(data.assetId!) : nil
        vm.publishTime = data.publishTime
    }
    
    static func manageData(data: ESProProjectListItemModel, vm: ESProProjectListViewModel) {
        let project_type = ESProjectType(data.projectType)
        let package_type = ESPackageType(data.pkgType)
        let project_status = ESProjectStatus(data.status)
        
        let (tagText, _, _) = ESProjectUtil.getProjectTagInfo(project_type, package_type)
        var text = data.pkgName
        if project_type == .Individual {
            text = tagText
        }
        vm.businessType = text
        vm.consumerName = data.name
        vm.phone = data.phone
        vm.address = data.address
        let (_, color) = ESProjectUtil.getStatusInfo(ESProjectStatus(data.status))
        vm.status = (data.statusName, color)
        
        // 预约审核
        var rejectShow = false
        if !ESStringUtil.isEmpty(data.bookingFailReason), ESProjectStatus(data.status) == .notThrough {
            rejectShow = true
        }
        vm.bookingFailReason = (rejectShow, data.bookingFailReason)
        
        // 设计师信息
        var designerShow = false
        if let designer_id = data.designerId, designer_id != 0 {
            designerShow = true
        }
        vm.designerInfo = (designerShow, data.designerAvatar, data.designerName)
        
        let unPayamount = data.unPaidAmount ?? 0.0
        let casDtoType = ESProjectReturnType(data.cashDto?[0].type)
        let casDtoStatus = ESProjectReturnStatus(data.cashDto?[0].operateStatus)
        switch casDtoType {
        case .balance: // 退款信息
            vm.returnInfo = (true, data.cashDto?[0].showContent, nil, "退款详情")
        case .chargeback: // 退单信息
            vm.returnInfo = (true, data.cashDto?[0].showContent, nil, "退单详情")
        default:
            vm.returnInfo = (false, nil, nil, "")
        }
        
        // 支付信息
        var showPay = false
        if unPayamount > 0 && project_status == .designing
            && (casDtoType == .unKnow || (casDtoType == .chargeback && casDtoStatus == .rejected)) {
            // 未付金额 > 0 并且 (退单/退款信息为空 或 类型为退单且审核状态为“审核未通过”)
            showPay = true
        }
        vm.payInfo = (showPay, data.unPaidAmount ?? 0.00)
        
        
        // 提取余额信息
        var showWithdraw = false
        if unPayamount < 0 && project_status == .designing && (casDtoType == .unKnow || (casDtoType == .balance && casDtoStatus == .unKnow)) {
            // 未付金额 < 0 并且 (退单/退款信息为空 或 类型为退款且审核状态为“审核未通过”)
            showWithdraw = true
        }
        vm.withdrawInfo = (showWithdraw, "此前支付金额有剩余，请点击申请退款，审核通过后将尽快将余额退回至您的原支付账号中。", -unPayamount, false)
    }
    
    /// 申请退款
    static func withDraw(orderId: String,
                         success: @escaping () -> Void,
                         failure: @escaping (String) -> Void) {
        ESPackageOrderApi.orderDrawCash(orderId: orderId, type: "cash", success: { (data) in
            success()
        }) { (error) in
            let msg = SHRequestTool.getErrorMessage(error)
            failure(msg!)
        }
    }
}
