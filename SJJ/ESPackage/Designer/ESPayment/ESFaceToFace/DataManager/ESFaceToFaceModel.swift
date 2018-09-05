//
//  ESFaceToFaceModel.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/14.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

/// 面对面付款类型
enum ESFaceToFacePayType {
    /// 支付宝
    case Alipay
    /// 微信
    case Wechat
    
    var rawValue: (img: String, text: String, value: String) {
        switch self {
        case .Alipay:
            return ("pay_way_wx", "微信", "4")
        case .Wechat:
            return ("pay_way_ali", "支付宝", "6")
            
        }
    }
}

