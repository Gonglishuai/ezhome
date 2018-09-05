//
//  ESPackageCashDto.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/22.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESPackageCashDto: Codable {
    /// 退单或者提现的ID
    var drawCashOrderId: String?
    /// 退单或者提取的余额
    var amount: Float?
    /// 1审核中 2审核通过 3审核失败 4提现失败
    var operateStatus: Int?
    /// 失败原因
    var remark: String?
    /// 退单 project 提取余额cash
    var type: String?
    /// app显示内容
    var showContent: String?
}
