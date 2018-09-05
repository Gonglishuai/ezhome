//
//  ESProProjectCostInfoViewModel.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

enum ESCostPayBtnType: String {
    case payment = "立即支付"        //  立即支付
    case confirmLastFee = "确认尾款" // 确认尾款
}

class ESProProjectCostInfoViewModel: ESViewModel {
    /// 付款明细(待收款金额, 是否可点击收款明细)
    var payDetail: (price: String?, able: Bool) = (nil, false)
    
    /// 交易流水(已收款金额, 是否可点击交易流水)
    var dealDetail: (price: String?, able: Bool) = (nil, false)
    
    /// 是否可立即支付
    var payButton: (type: ESCostPayBtnType, action: Bool) = (.payment, false)
}
