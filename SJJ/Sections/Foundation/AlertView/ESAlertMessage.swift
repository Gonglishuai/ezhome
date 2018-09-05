//
//  ESAlertMessage.swift
//  Consumer
//
//  Created by xiefei on 3/4/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

public enum ESAlertMessage: String {
    /// 优惠券失效
    case  InvalidationOfCouponsForDesigner  = "您的待付费用中包含已失效优惠无法支付，建议联系设计师"

    case InvalidationOfCouponsForHouseMaster = "您的待收费用中包含已失效优惠无法支付，建议撤销收款重新设置"
    
}
