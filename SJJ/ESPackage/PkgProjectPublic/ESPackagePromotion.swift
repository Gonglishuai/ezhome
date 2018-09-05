//
//  ESPackagePromotion.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/13.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESPackagePromotion: Codable {
    /// 优惠id
    var promotionId: Int?
    /// 优惠名称
    var promotionName: String?
    /// 该优惠是否已选择
    var isSelect: Bool?
    /// 优惠类型 1:返现 2:优惠
    var rewardType: Int?
    /// 优惠券使用说明
    var promotionH5Url: String?
}
