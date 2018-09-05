//
//  ESERPSearchViewModel.swift
//  ESPackage
//
//  Created by 焦旭 on 2018/1/2.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESERPSearchViewModel: NSObject {
    
    /// 业主姓名
    var consumerName: String?
    
    /// 项目地址
    var projectAddr: String?
    
    /// 设计师姓名
    var designerName: String?

    /// 服务门店
    var serviceStore: String?
    
    /// 是否可下一步
    var canNext: Bool = false
}
