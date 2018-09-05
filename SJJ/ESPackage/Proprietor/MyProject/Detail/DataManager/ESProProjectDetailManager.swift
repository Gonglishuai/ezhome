//
//  ESProProjectDetailManager.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESProProjectDetailManager: NSObject {
    
    /// 获取消费者项目详情
    static func getProjectDetail(_ assetId: String,
                                 _ pkgViewTag: String,
                                 success: @escaping (ESProProjectDetailModel) -> Void,
                                 failure: @escaping () -> Void) {
        
        ESPackageProjectApi.getProprietorProjectDetail(assetId, pkgViewTag, success: { (response) in
            if let data = response {
                
                let model = try? JSONDecoder().decode(ESProProjectDetailModel.self, from: data)
                if model != nil {
                    success(model!)
                    return
                }
            }
            failure()
            
        }) { (error) in
            failure()
        }
    }
    
    // MARK: - 配置显示的Cell
    static let orderDetail = "orderDetail"  // 预约明细key
    static let designer = "designer"        // 设计师key
    static let contract = "contract"        // 合同key
    static let costInfo = "costInfo"        // 费用信息key
    static let preview = "preview"          // 预交底信息key
    static let delivery = "cases"              // 交付key
    static func getCellsId(dataModel: ESProProjectDetailModel) -> [(String, [String])] {
        var cells: [(key: String, data: [String])] = []
        let projectType = ESProjectType(dataModel.baseInfo?.projectType)
        let projectStatus = ESProjectStatus(dataModel.baseInfo?.status)
        
        cells.append((orderDetail, ["ESProProjectOrderDetailCell"]))
        
        switch projectType {
        case .Individual:
            cells.append((designer, ["ESProProjectDesignerCell"]))
            if projectStatus != .allocating && projectStatus != .notThrough {
                if let caseList = dataModel.cases, caseList.count > 0 {
                    let cases = [String](repeatElement("ESProProjectDeliveryInfoCell", count: caseList.count))
                    cells.append((delivery, cases))
                } else {
                    cells.append((delivery, ["ESProProjectDeliveryInfoCell"]))
                }
            }
        case .Package:
            if projectStatus == .unKnow {
                return cells
                
            } else if projectStatus == .allocating {// 派单中：预约明细+设计师(暂无设计师)
                cells.append((designer, ["ESProProjectDesignerCell"]))
                
            } else if projectStatus == .notThrough {// 未通过
                cells[0].data.append("ESProProjectRejectCancelCell")
                
//            } else if projectStatus == .canceled {// 取消(取消预约，退单)
                
//                cells[0].data.append("ESProProjectRejectCancelCell")
                
//                cells.append((designer, ["ESProProjectDesignerCell"]))
//
//                if let unPayamount = dataModel.baseInfo?.unPaidAmount, unPayamount > 0 {
//                    cells.append((costInfo, ["ESProProjectCostInfoCell"]))
//                }
//
//                if let caseList = dataModel.cases, caseList.count > 0 {
//                    let cases = [String](repeatElement("ESProProjectDeliveryInfoCell", count: caseList.count))
//                    cells.append((delivery, cases))
//                } else {
//                    cells.append((delivery, ["ESProProjectDeliveryInfoCell"]))
//                }
                
            } else {
                
                if projectStatus == .canceled {// 取消(取消预约，退单)
                    cells[0].data.append("ESProProjectRejectCancelCell")
                }
                
                cells.append((designer, ["ESProProjectDesignerCell"]))
                
                if let erpid = dataModel.baseInfo?.erpId, !erpid.isEmpty { /// 若已绑定erp
                    if let agree = dataModel.baseInfo?.paidFirstFee, agree == true {
                        // 已付首款(包括分笔)
                        cells.append((contract, ["ESProProjectContractCell"]))
                    }
                    
                    cells.append((costInfo, ["ESProProjectCostInfoCell"]))
                    
                    if let roleList = dataModel.preConfirm?.roleList, roleList.count > 0 {
                        let roles = [String](repeatElement("ESProProjectPreviewInfoCell", count: roleList.count))
                        cells.append((preview, roles))
                    } else {
                        cells.append((preview, ["ESProProjectPreviewInfoCell"]))
                    }
                    
                    if let caseList = dataModel.cases, caseList.count > 0 {
                        let cases = [String](repeatElement("ESProProjectDeliveryInfoCell", count: caseList.count))
                        cells.append((delivery, cases))
                    } else {
                        cells.append((delivery, ["ESProProjectDeliveryInfoCell"]))
                    }
                }
            }
        default:
            break
        }
        
        return cells
    }
    
    static func getCell(_ tableView: UITableView,
                        _ delegate: ESProProjectDetailContoller,
                        _ indexPath: IndexPath,
                        _ cells: [(key: String, data: [String])]) -> UITableViewCell? {
        if cells.count <= 0 || cells.count < indexPath.section + 1{
            return nil
        }
        let section = cells[indexPath.section].data
        if section.count <= 0 || section.count < indexPath.row + 1 {
            return nil
        }
        let cellId = section[indexPath.row]
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! ESProProjectDetailCellProtocol
        cell.delegate = delegate
        cell.updateCell(index: indexPath.row, section: indexPath.section)
        let returnCell = cell as! UITableViewCell
        return returnCell
    }
    
    static func manageData(_ dataModel: ESProProjectDetailModel,
                           _ index: Int,
                           _ section: Int,
                           _ cellId: String,
                           _ viewModel: ESViewModel) {
        let projectType = ESProjectType(dataModel.baseInfo?.projectType)
        let pkgType = ESPackageType(dataModel.baseInfo?.pkgType)
        let status = ESProjectStatus(dataModel.baseInfo?.status)
        let returnStatus = ESProjectReturnStatus(dataModel.cashDto?[0].operateStatus)
        let action = ESProProjectDetailManager.couldAction(dataModel)
        
        switch cellId {
        case "ESProProjectOrderDetailCell":
            let vm = viewModel as! ESProProjectOrderDetailViewModel
            let (tagText, textColor, bgColor) = ESProjectUtil.getProjectTagInfo(projectType, pkgType)
            
            var text = dataModel.baseInfo?.pkgName
            if projectType == .Individual {
                text = tagText
            }
            vm.tag = (text, textColor, bgColor)
            
            let (_, statusColor) = ESProjectUtil.getStatusInfo(status)
            vm.status = (dataModel.baseInfo?.statusName, statusColor)
            let projectId = dataModel.baseInfo?.projectId != nil ? String(dataModel.baseInfo!.projectId!) : nil
            vm.projectId = projectId
            vm.orderTime = dataModel.baseInfo?.publishTime
            vm.consumerName = dataModel.baseInfo?.consumerName
            vm.phone = dataModel.baseInfo?.consumerMobile
            let address = String(format: "%@%@%@%@",
                                 dataModel.baseInfo?.provinceName ?? "",
                                 dataModel.baseInfo?.cityName ?? "",
                                 dataModel.baseInfo?.districtName ?? "",
                                 dataModel.baseInfo?.address ?? "")
            vm.address = address.isEmpty ? "--" : address
            vm.communityName = dataModel.baseInfo?.communityName
            
            vm.houseType = dataModel.baseInfo?.houseTypeName
            vm.area = dataModel.baseInfo?.houseArea
            vm.budget = dataModel.baseInfo?.budget
            vm.style = dataModel.baseInfo?.designStyleName
            vm.roomType = dataModel.baseInfo?.roomTypeName
        case "ESProProjectRejectCancelCell":
            let vm = viewModel as! ESProProjectRejectCancelViewModel
            if status == .notThrough {
                let title = "您的预约装修服务申请未通过，原因如下:"
                let reason = dataModel.baseInfo?.bookingFailReason ?? ""
                vm.type = .rejected(title: title, reason: reason)
            } else {
                var text = ""
                if let payAmount = dataModel.baseInfo?.paidAmount, payAmount > 0 { // 申请退单
                    text = "您已退单成功，现交易关闭，您还可以重新预约哦～"
                } else { /// 取消预约
                    text = "您已取消预约，现交易关闭，您还可以重新预约哦～"
                }
                vm.type = .canceled(reason: text)
            }
        case "ESProProjectDesignerCell":
            let vm = viewModel as! ESProProjectDesignerViewModel
            if (dataModel.designerInfo?.designerId) != nil {
                vm.empty = false
                vm.header = dataModel.designerInfo?.designerAvatar
                vm.name = dataModel.designerInfo?.designerName
            } else {
                vm.empty = true
            }
        case "ESProProjectContractCell":
            let vm = viewModel as! ESProProjectContractViewModel
            
            vm.signTime = dataModel.contractInfo?.signDate ?? "--"
            vm.startTime = dataModel.contractInfo?.signDate ?? "--"
            vm.finishTime = dataModel.contractInfo?.completeDate ?? "--"
            
            let days = dataModel.contractInfo?.proNumber ?? 0
            let weekends = dataModel.contractInfo?.weekendConstruct ?? 0
            let text = weekends == 1 ? "  周末开工" : ""
            vm.tiemLimit = "\(days)天\(text)"
            if let amount = dataModel.contractInfo?.amount {
                let amountStr = String(format: "%.2f", amount)
                vm.amount = "¥ \(amountStr)"
            } else {
                vm.amount = "--"
            }
            
            vm.promotion = dataModel.contractInfo?.promotion ?? "--"
        case "ESProProjectCostInfoCell":
            let vm = viewModel as! ESProProjectCostInfoViewModel
            let unPayamount = dataModel.baseInfo?.unPaidAmount ?? 0.0
            if let lastFee = dataModel.baseInfo?.lastFeeStatus {
                if lastFee == "N" {
                    vm.payButton = (.confirmLastFee, true)
                } else if lastFee == "Y" {
                    vm.payButton = (.confirmLastFee, false)
                }
            } else {
                if action && unPayamount > 0 {
                    vm.payButton = (.payment, true)
                } else {
                    vm.payButton = (.payment, false)
                }
            }
            
            var unPayAmount = dataModel.baseInfo?.unPaidAmount ?? 0.0
            unPayAmount = unPayAmount >= 0 ? unPayAmount : 0.0
            let text1 = String(format: "¥ %.2f", unPayAmount)
            vm.payDetail = (text1, unPayAmount > 0)
            
            var payAmount = dataModel.baseInfo?.paidAmount ?? 0.0
            payAmount = payAmount >= 0 ? payAmount : 0.0
            let text2 = String(format: "¥ %.2f", payAmount)
            vm.dealDetail = (text2, payAmount > 0)
            
        case "ESProProjectPreviewInfoCell":
            let vm = viewModel as! ESProProjectPreviewViewModel
            if let roleList = dataModel.preConfirm?.roleList, roleList.count > 0 {
                vm.empty = false
                let role = roleList[index]
                let roleName = role.roleName ?? ""
                vm.name = ("\(roleName)姓名", role.userName)
                vm.phone = ("\(roleName)电话", role.userMobile)
            } else {
                vm.empty = true
            }
        case "ESProProjectDeliveryInfoCell":
            let vm = viewModel as! ESProProjectDeliveryInfoViewModel
            if let caseList = dataModel.cases, caseList.count > 0 {
                let caseItem = caseList[index]
                let showQuote = projectType == .Package
                let pkgName = caseItem.pkgName
                let isFinally = caseItem.isFinally ?? false
                vm.delivery = (caseItem.assetName, caseItem.imageUrl, showQuote, pkgName, isFinally)
            } else {
                vm.delivery = nil
            }
        default:
            break
        }
    }
    
    static func manageSection(_ index: Int,
                              _ cells: [(key: String, data: [String])],
                              _ viewModel:ESProProjectDetailHeaderViewModel,
                              _ dataModel: ESProProjectDetailModel) {
        if cells.count > 0 {
            let (key, _) = cells[index]
            let titleColor = ESColor.color(sample: .mainTitleColor)
            let titleFont = ESFont.font(name: .medium, size: 15.0)
            switch key {
            case orderDetail:
                viewModel.title = ("预约明细", titleFont, titleColor)
                viewModel.subTitle = (nil, nil, nil, false)
            case designer:
                viewModel.title = ("我的设计师", titleFont, titleColor)
                viewModel.subTitle = (nil, nil, nil, false)
            case contract:
                viewModel.title = ("合同信息", titleFont, titleColor)
                let subFont = ESFont.font(name: .medium, size: 13.0)
                let subColor = ESColor.color(hexColor: 0x6ABD25, alpha: 1.0)
                viewModel.subTitle = ("已同意合同", subFont, subColor, false)
            case costInfo:
                viewModel.title = ("费用信息", titleFont, titleColor)
                let subFont = ESFont.font(name: .regular, size: 13.0)
                let subColor = ESColor.color(sample: .buttonBlue)
                var subTitle = ""
                var action = false
                if let show = dataModel.baseInfo?.showSettlement, show {
                    subTitle = "费用详情"
                    action = true
                }
                viewModel.subTitle = (subTitle, subFont, subColor, action)
            case preview:
                viewModel.title = ("预交底信息", titleFont, titleColor)
                if let preDate = dataModel.preConfirm?.preDate, !preDate.isEmpty {
                    let subtext = String(format: "预交底时间: %@", preDate)
                    let subFont = ESFont.font(name: .regular, size: 12.0)
                    let subColor = ESColor.color(sample: .subTitleColorA)
                    viewModel.subTitle = (subtext, subFont, subColor, false)
                } else {
                    viewModel.subTitle = (nil, nil, nil, false)
                }
            case delivery:
                viewModel.title = ("交付信息", titleFont, titleColor)
                viewModel.subTitle = (nil, nil, nil, false)
            default:
                break
            }
        }
    }
    
    static func manageFooter(_ dataModel: ESProProjectDetailModel) -> String? {
        let status = ESProjectReturnStatus(dataModel.cashDto?[0].operateStatus)
        if let payamount = dataModel.baseInfo?.paidAmount, payamount > 0 {
            if let data = dataModel.cashDto?[0].drawCashOrderId, !data.isEmpty,
                let type = dataModel.cashDto?[0].type {
                if type == "project" {
                    if status != .rejected {
                        return "退单详情"
                    } else {
                        return "申请退单"
                    }
                } else if type == "cash" {
                    return "退款详情"
                }
            } else {
                return "申请退单"
            }
        }
        return nil
    }
    
    /// 校验优惠
    ///
    /// - Parameters:
    ///   - projectId: 项目编号id
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func checkCouponStatus(projectId: String,
                                  success: @escaping (Bool) -> Void,
                                  failure: @escaping (String) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.designUrl
        let url = "\(baseUrl!)order/checkPromotion/\(projectId)"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)
        SHHttpRequestManager.get(url,
                                 withParameters: nil,
                                 withHeaderField: header,
                                 withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager,
                                 andSuccess: { (response) in
                                    if let data = response {
                                        let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                                        
                                        if let dic = dict as? [String: Any?], let status = dic["success"] as? Bool {
                                            
                                            success(status)
                                            return
                                        }
                                    }
                                    failure("网络请求失败，请稍后重试!")
        }) { (error) in
            let msg = SHRequestTool.getErrorMessage(error)
            failure(msg!)
        }
    }
    
    /// 校验订单是否可以立即支付
    static  func goToPay(_ assetId: String, success: @escaping (_ orderId: String) -> Void, failure: @escaping (String) -> Void) {
        ESPackageOrderApi.checkPayStatus(assetId, success: { (response) in
            if let data = response {
                let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                
                if let dic = dict as? [String: Any?], let orderId = dic["mainOrderId"] as? String {
                    
                    success(orderId)
                    return
                }
            }
        }) { (error) in
            let msg = SHRequestTool.getErrorMessage(error)
            failure(msg!)
        }
    }
    
    /// 是否允许关键性操作
    static func couldAction(_ data: ESProProjectDetailModel) -> Bool {
        let status = ESProjectStatus(data.baseInfo?.status)
//        let cashType = ESProjectReturnType(data.cashDto?.type)
        let cashStatus = ESProjectReturnStatus(data.cashDto?[0].operateStatus)
        
        switch status {
        case .allocating:
            fallthrough
        case .designing:
            if cashStatus == .rejected || cashStatus == .unKnow {
                return true
            } else {
                return false
            }
        default:
            return false
        }
    }
    
    /// 确认尾款
    static func confirmLastFee(_ mainOrderId: String,
                               success: @escaping () -> Void,
                               failure: @escaping (String) -> Void) {
        ESPackageOrderApi.confirmLastFee(orderId: mainOrderId, success: { (data) in
            success()
        }) { (error) in
            let msg = SHRequestTool.getErrorMessage(error)
            failure(msg!)
        }
    }
    
    /// 撤销收款
    static func cancelPay(_ projectNum: String,orderId: String,
                               success: @escaping (Bool) -> Void,
                               failure: @escaping (String) -> Void) {
        
        ESPackageOrderApi.deleteOrder(projectNum: projectNum, orderId: orderId, success: { (response) in
            if let data = response {
                let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                
                if let dic = dict as? [String: Any?], let status = dic["success"] as? Bool {
                    
                    success(status)
                    return
                }
            }
            failure("网络请求失败，请稍后重试!")
        }) { (error) in
            let msg = SHRequestTool.getErrorMessage(error)
            failure(msg!)
        }
    }

}
