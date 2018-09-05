//
//  ESPackageCases.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/13.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESPackageCase: Codable {
    /// 方案ID
    var assetId: Int?
    /// 方案名称
    var assetName: String?
    /// 图片
    var imageUrl: String?
    /// 报价id
    var quoteId: String?
    /// 报价名称（套餐类型）
    var pkgName: String?
    /// 是否是最终方案
    var isFinally: Bool?
}
