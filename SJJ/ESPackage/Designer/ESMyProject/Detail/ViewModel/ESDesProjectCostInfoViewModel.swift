//
//  ESDesProjectCostInfoViewModel.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/22.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  费用信息

import UIKit

class ESDesProjectCostInfoViewModel: ESViewModel {
    
    /// 收款明细(待收款金额, 是否可点击收款明细)
    var receivables: (price: String?, able: Bool) = (nil, false)
    
    /// 交易流水(已收款金额, 是否可点击交易流水)
    var paiedDetail: (price: String?, able: Bool) = (nil, false)
    
    /// 选择优惠(信息, 信息字体颜色, 是否可选择优惠)
    var discounts: (info: String?, infoColor: UIColor?, able: Bool) = (nil, nil, false)
    
    /// 是否可发起面对面
    var faceToFace: Bool = false
    
    /// 是否可发起收款
    var canReceipt: Bool = false
}
