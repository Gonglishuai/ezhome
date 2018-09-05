//
//  ESERPCreateViewModel.swift
//  ESPackage
//
//  Created by 焦旭 on 2018/1/2.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESERPCreateViewModel {
    
    /// 填写项标题
    var title: String?
    
    /// 输入项的占位文字
    var placeholder: String?
    
    /// 该项的内容
    var itemContent: String?
    
    /// 是否为选择项
    var isSelectedItme: Bool = false
    
    /// 该项的标识
    var key: ESERPCreateItemType
    
    enum ESERPCreateItemType {
        case consumer
        case consumerMobile
        case region
        case community
        case addrDetail
        case designer
        case store
    }
}
