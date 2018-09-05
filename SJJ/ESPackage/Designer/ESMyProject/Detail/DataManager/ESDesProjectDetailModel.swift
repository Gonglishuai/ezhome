//
//  ESDesProjectDetailModel.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESDesProjectDetailModel: Codable {
    /// 基本信息
    var baseInfo: ESPackageBaseInfo?
    /// 交付方案信息
    var cases: [ESPackageCase]?
    /// 预交底信息
    var preConfirm: ESPackagePrefirm?
    /// 图纸报价状态
    var designStatus: String?
    /// 图纸报价状态名称
    var designStatusName: String?
    /// 促销列表
    var promotionList: [ESPackagePromotion]?
    /// 合同信息
    var contractInfo: ESPackageContractInfo?
    /// 提现/退单信息
    var cashDto: [ESPackageCashDto]?
    /// ERP金额
    var amount: Double?
    /// 报价金额
    var quoteAmount: Double?
}
