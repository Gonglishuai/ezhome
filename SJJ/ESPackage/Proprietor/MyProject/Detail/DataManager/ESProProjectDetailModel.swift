//
//  ESProProjectDetailModel.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESProProjectDetailModel: Codable {
    /// 基本信息
    var baseInfo: ESPackageBaseInfo?
    /// 设计师信息
    var designerInfo: ESProProjectDesignerInfo?
    /// 交付方案信息
    var cases: [ESPackageCase]?
    /// 预交底信息
    var preConfirm: ESPackagePrefirm?
    /// 合同信息
    var contractInfo: ESPackageContractInfo?
    /// 提现/退单信息
    var cashDto: [ESPackageCashDto]?
}

struct ESProProjectDesignerInfo: Codable {
    /// 设计师ID
    var designerId: String?
    /// 设计师头像
    var designerAvatar: String?
    /// 设计师名称
    var designerName: String?
    /// 设计师手机号
    var designerMobile: String?
}
