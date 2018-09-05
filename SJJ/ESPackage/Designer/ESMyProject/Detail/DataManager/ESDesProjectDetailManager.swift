//
//  ESDesProjectDetailManager.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/12.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESDesProjectDetailManager: NSObject {
    /// 获取设计师项目详情
    static func getProjectDetail(_ assetId: String,
                                 _ pkgViewTag: String,
                                 success: @escaping (ESDesProjectDetailModel) -> Void,
                                 failure: @escaping (String) -> Void) {
        ESPackageProjectApi.getDesignerProjectDetail(assetId, pkgViewTag, success: { (response) in

            print("responseData:\(NSString(data: response!, encoding: String.Encoding.utf8.rawValue)!)")

            if let data = response {
                let model = try? JSONDecoder().decode(ESDesProjectDetailModel.self, from: data)
                if model != nil {
                    success(model!)
                    return
                }
            }
            failure("网络错误, 请稍后重试!")
        }) { (error) in
            let msg = SHRequestTool.getErrorMessage(error)
            failure(msg!)
        }
    }
    
    // MARK: - 配置显示的Cell
    static let orderDetail = "orderDetail"  // 预约明细key
    static let costInfo = "costInfo"        // 费用信息key
    static let contract = "contract"        // 合同key
    static let preview = "preview"          // 预交底信息key
    static let quoteInfo = "quoteInfo"      // 图纸报价信息key
    static let delivery = "cases"           // 交付信息key
    static func getCellsId(dataModel: ESDesProjectDetailModel) -> [(String, [String])] {
        var cells: [(key: String, data: [String])] = []
        let projectType = ESProjectType(dataModel.baseInfo?.projectType)
        let projectStatus = ESProjectStatus(dataModel.baseInfo?.status)
        
        cells.append((orderDetail, ["ESDesProjectOrderDetailCell"]))
        
        switch projectType {
        case .Individual:   /// 个性化
            if projectStatus != .allocating && projectStatus != .notThrough {
                if let caseList = dataModel.cases, caseList.count > 0 {
                    let cases = [String](repeatElement("ESDesProjectDeliveryInfoCell", count: caseList.count))
                    cells.append((delivery, cases))
                } else {
                    cells.append((delivery, ["ESDesProjectDeliveryInfoCell"]))
                }
            }
        case .Package:
            if let erpId = dataModel.baseInfo?.erpId, !erpId.isEmpty {
                cells.append((costInfo, ["ESDesProjectCostInfoCell"]))
                cells.append((contract, ["ESDesProjectContractCell"]))
                cells.append((preview, ["ESDesProjectPreviewCell"]))
                cells.append((quoteInfo, ["ESDesProjectQuoteInfoCell"]))
                
                if let caseList = dataModel.cases, caseList.count > 0 {
                    let cases = [String](repeatElement("ESDesProjectDeliveryInfoCell", count: caseList.count))
                    cells.append((delivery, cases))
                } else {
                    cells.append((delivery, ["ESDesProjectDeliveryInfoCell"]))
                }
            }
        default:
            break
        }
        
        return cells
    }
    
    static func getCell(_ tableView: UITableView,
                        _ delegate: ESDesProjectDetailController,
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
        
        guard var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? ESDesProjectDetailCellProtocol else {
            return nil
        }
        cell.delegate = delegate
        cell.updateCell(index: indexPath.row, section: indexPath.section)
        let returnCell = cell as! UITableViewCell
        return returnCell
    }
    
    static func manageSecions(_ index: Int,
                              _ cells: [(key: String, data: [String])],
                              _ data: ESDesProjectDetailModel,
                              _ vm: ESDesProjectDetailHeaderViewModel) {
        if cells.count > 0 {
            let (key, _) = cells[index]
            let titleColor = ESColor.color(sample: .mainTitleColor)
            let titleFont = ESFont.font(name: .medium, size: 15.0)
            switch key {
            case orderDetail:
                vm.title = ("预约明细", titleFont, titleColor)
                vm.subTitle = (nil, nil, nil, false)
            case costInfo:
                vm.title = ("费用信息", titleFont, titleColor)
                var subTitle = ""
                var action = false
                if let show = data.baseInfo?.showSettlement, show {
                    subTitle = "费用详情"
                    action = true
                }
                vm.subTitle = (subTitle, ESFont.font(name: .regular, size: 13.0), ESColor.color(sample: .buttonBlue), action)
            case contract:
                vm.title = ("合同信息", titleFont, titleColor)
                var status: String?
                if let firstFee = data.baseInfo?.paidFirstFee, firstFee {
                    status = "业主已签约"
                }
                vm.subTitle = (status, ESFont.font(name: .regular, size: 13.0), ESColor.color(hexColor: 0x6ABD25, alpha: 1.0), false)
            case preview:
                vm.title = ("预交底信息", titleFont, titleColor)
                let status = ESProjectPreviewStatus(data.preConfirm?.status)
                
                var color: UIColor?
                var text: String?
                
                if status == .unKnow || status == .canceled {
                    text = "未申请"
                    color = ESColor.color(hexColor: 0xFF9A02, alpha: 1.0)
                } else if status == .rejected {
                    text = "审核未通过"
                    color = ESColor.color(hexColor: 0xFF9A02, alpha: 1.0)
                } else if status == .inReview {
                    text = "审核中"
                    color = ESColor.color(hexColor: 0x6ABD25, alpha: 1.0)
                } else if let roleList = data.preConfirm?.roleList, roleList.count > 0, status == .passed {
                    text = "已分配"
                    color = ESColor.color(hexColor: 0x6ABD25, alpha: 1.0)
                }
                vm.subTitle = (text, ESFont.font(name: .regular, size: 13.0), color, false)
            case quoteInfo:
                vm.title = ("图纸报价审核", titleFont, titleColor)
                let status = ESProjectPreviewStatus(data.designStatus)
                
                var color: UIColor?
                var text: String?
                
                if status == .unKnow || status == .canceled {
                    text = "未申请"
                    color = ESColor.color(hexColor: 0xFF9A02, alpha: 1.0)
                } else if status == .rejected {
                    text = "审核未通过"
                    color = ESColor.color(hexColor: 0xFF9A02, alpha: 1.0)
                } else if status == .inReview {
                    text = "审核中"
                    color = ESColor.color(hexColor: 0x6ABD25, alpha: 1.0)
                } else if status == .passed {
                    text = "审核通过"
                    color = ESColor.color(hexColor: 0x6ABD25, alpha: 1.0)
                }
                vm.subTitle = (text, ESFont.font(name: .regular, size: 13.0), color, false)
            case delivery:
                vm.title = ("交付信息", titleFont, titleColor)
                vm.subTitle = (nil, nil, nil, false)
            default:
                break
            }
        }
    }
    
    static func manageData(_ index: Int,
                           _ section: Int,
                           _ cellId: String,
                           _ viewModel: ESViewModel,
                           _ data: ESDesProjectDetailModel) {
        let projectType = ESProjectType(data.baseInfo?.projectType)
        let pkgType = ESPackageType(data.baseInfo?.pkgType)
        let project_status = ESProjectStatus(data.baseInfo?.status)
        let action = ESDesProjectDetailManager.couldAction(data)
        
        switch cellId {
        case "ESDesProjectOrderDetailCell":
            let itemModel = viewModel as! ESDesProjectOrderDetailViewModel
            let (text, textColor, bgColor) = ESProjectUtil.getProjectTagInfo(projectType, pkgType)
            
            var tagText = data.baseInfo?.pkgName
            if projectType == .Individual {
                tagText = text
            }
            itemModel.tag = (tagText, textColor, bgColor)
            
            let (_, color) = ESProjectUtil.getStatusInfo(project_status)
            itemModel.status = (data.baseInfo?.statusName, color)
            let project_id = data.baseInfo?.projectId
            itemModel.projectId = project_id != nil ? String(project_id!) : nil
            itemModel.orderTime = data.baseInfo?.publishTime
            itemModel.consumerName = data.baseInfo?.consumerName
            itemModel.phone = data.baseInfo?.consumerMobile
            let address = String(format: "%@%@%@%@",
                                 data.baseInfo?.provinceName ?? "",
                                 data.baseInfo?.cityName ?? "",
                                 data.baseInfo?.districtName ?? "",
                                 data.baseInfo?.address ?? "")
            itemModel.address = address.isEmpty ? "--" : address
            itemModel.communityName = data.baseInfo?.communityName
            itemModel.houseType = data.baseInfo?.houseTypeName ?? "--"
            
            itemModel.area = data.baseInfo?.houseArea
            itemModel.budget = data.baseInfo?.budget
            itemModel.style = data.baseInfo?.designStyleName ?? "--"
            
            itemModel.roomType = data.baseInfo?.roomTypeName ?? "--"
            itemModel.solution = data.baseInfo?.sourceName
            itemModel.remark = data.baseInfo?.bookingFailReason
            
        case "ESDesProjectCostInfoCell":
            let item = viewModel as! ESDesProjectCostInfoViewModel
            var unPay = data.baseInfo?.unPaidAmount ?? 0.00
            unPay = unPay >= 0 ? unPay : 0.0
            let unPayAmount = String(format: "¥ %.2f", unPay)
            item.receivables = (unPayAmount, true)
            
            var pay = data.baseInfo?.paidAmount ?? 0.00
            pay = pay >= 0 ? pay : 0.0
            let payAmount = String(format: "¥ %.2f", pay)
            item.paiedDetail = (payAmount, true)
            
            var selNum: Int?
            var text: String?
            var color: UIColor?
    
            var entry = true
            if let list = data.promotionList, list.count > 0 {
                let selList = list.filter{$0.isSelect != nil && $0.isSelect!}
                selNum = selList.count
                if selNum! > 0 {
                    text = "已选择\(selNum!)种优惠"
                    color = ESColor.color(sample: .mainTitleColor)
                    entry = true
                } else {
                    if let hasFirst = data.baseInfo?.hasFirstFee, hasFirst {
                        text = "未选择优惠"
                        color = ESColor.color(sample: .subTitleColorB)
                    } else {
                        text = "请先选择优惠"
                        color = ESColor.color(hexColor: 0xFF9A02, alpha: 1.0)
                    }
                    
                    entry = true
                }
            } else {
                text = "暂无优惠"
                color = ESColor.color(sample: .subTitleColorB)
            }
            
            if !action {//当前项目状态不可操作
                item.discounts = (text, color, false)
                item.canReceipt = false
                item.faceToFace = false
                return
            }
            
            item.discounts = (text, color, entry)
            
            var faceToFace = false
            var canReceipt = false
            
            if project_status == .designing {
                //不选择优惠也可以发起收款
//                if let sel = selNum {
//                    canReceipt = sel > 0
//                } else {
                    canReceipt = true
//                }
            }
            item.canReceipt = canReceipt
            
            if let unPay = data.baseInfo?.unPaidAmount, unPay > 0, canReceipt {
                faceToFace = true
            }
            item.faceToFace = faceToFace
            
        case "ESDesProjectContractCell":
            let item = viewModel as! ESDesProjectContractViewModel
            let status = ESProjectPreviewStatus(data.designStatus)
            if status == .passed, action {
                item.buttonAble = true
            }

            if project_status == .designing {
                if ESStringUtil.isEmpty(data.contractInfo?.signDate) {
                    item.buttonType = .create
                } else if let hasPay = data.baseInfo?.paidFirstFee, let containFirstFee = data.baseInfo?.containsFirstFee {
                    if hasPay || containFirstFee {// 已付首款 或 发起收款包含首款
                        item.buttonType = .none
                    } else {
                        item.buttonType = .edit
                    }
                } else {
                    item.buttonType = .edit
                }
            }
            
        case "ESDesProjectPreviewCell":
            let item = viewModel as! ESDesProjectPreviewViewModel
            item.buttonAble = action
            if project_status == .designing {
                let status = ESProjectPreviewStatus(data.preConfirm?.status)
                if status == .unKnow || status == .notApply || status == .rejected || status == .canceled {
                    item.buttonType = .create
                } else if status == .inReview {
                    item.buttonType = .cancel
                }
            }
            
        case "ESDesProjectQuoteInfoCell":
            let item = viewModel as! ESDesProjectQuoteInfoViewModel
            let status = ESProjectPreviewStatus(data.designStatus)
            var alert: String?
            if status == .unKnow || status == .notApply {
                alert = "提交图纸报价审核，请登录设计家PC端进行提交"
            }
            item.alertInfo = (alert, ESColor.color(hexColor: 0xFF9A02, alpha: 1.0))
            
        case "ESDesProjectDeliveryInfoCell":
            let item = viewModel as! ESDesProjectDeliveryInfoViewModel
            if let caseList = data.cases, caseList.count > 0, caseList.count > index {
                let caseItem = caseList[index]
                let showQuote = projectType == .Package
                let pkgName = caseItem.pkgName
                let isFinally = caseItem.isFinally ?? false
                item.delivery = (caseItem.assetName, caseItem.imageUrl, showQuote, pkgName, isFinally)
            } else {
                item.delivery = nil
            }
        default:
            break
        }
    }
    
    /// 取消预交底
    static func cancelProjectPreview(_ assetId: Int?,
                                    success: @escaping () -> Void,
                                    failure: @escaping (String) -> Void) {
        if assetId == nil {
            failure("网络错误, 请稍后重试!")
            return
        }
        ESPackageProjectApi.cancelPreview(String(assetId!), success: { (response) in
            success()
        }) { (error) in
            let msg = SHRequestTool.getErrorMessage(error)
            failure(msg!)
        }
    }
    
    /// 配置底部黄色提示视图
    static func manageAlertInfo(_ data: ESDesProjectDetailModel) -> (Bool, String?) {
        let status = ESProjectStatus(data.baseInfo?.status)
        switch status {
        case .canceled:
            if let payAmount = data.baseInfo?.paidAmount, payAmount > 0 {//申请退单
                return (true, "业主已申请退单, 现交易关闭。")
            } else {//取消预约
                return (true, "业主已取消预约, 现交易关闭。")
            }
        case .designing:
            if ESProjectReturnType(data.cashDto?[0].type) == .chargeback,
                ESProjectReturnStatus(data.cashDto?[0].operateStatus) == .inReview{
                return (true, "业主申请了退单, 现暂时无法进行操作。")
            }
        default:
            break
        }
        return (false, nil)
    }
    
    /// 是否允许关键性操作
    static func couldAction(_ data: ESDesProjectDetailModel) -> Bool {
        let status = ESProjectStatus(data.baseInfo?.status)
        switch status {
        case .allocating:
            fallthrough
        case .designing:
            if ESProjectReturnType(data.cashDto?[0].type) == .chargeback,
                ESProjectReturnStatus(data.cashDto?[0].operateStatus) == .inReview{
                return false
            } else {
                return true
            }
        default:
            return false
        }
    }
}
