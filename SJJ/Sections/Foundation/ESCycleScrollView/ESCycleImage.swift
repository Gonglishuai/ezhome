//
//  ESCycleImage.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

enum ESCycleImageType {
    /// 本地图片
    case Local(name: String?)
    /// 网络图片
    case Net(url: String?)
}

struct ESCycleImage {
    /// 图片类型
    var type: ESCycleImageType = .Net(url: nil)
    /// 默认图
    var placeHolder: String?
}
