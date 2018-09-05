//
//  ESPackageContract.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/13.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESPackageContractInfo: Codable {
    /// 创建时间
    var createDate: String?
    /// 签约日期
    var signDate: String?
    /// 开工日期
    var startDate: String?
    /// 竣工日期
    var completeDate: String?
    /// 施工天数
    var proNumber: Int?
    /// 0否1是
    var weekendConstruct: Int?
    /// 合同备注
    var remark: String?
    /// 合同状态
    var status: String?
    /// 合同审核未通过原因
    var auditRemark: String?
    /// 合同金额
    var amount: Double?
    /// 促销活动
    var promotion: String?
}

struct ESPackageContract: Codable {
    var fileName: String?
    var fileUrl: String?
    var fileH5Url: String?
}
