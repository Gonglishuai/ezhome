//
//  ESDesProjectPreviewViewModel.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/26.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  预交底信息

import UIKit

class ESDesProjectPreviewViewModel: ESViewModel {
    enum PreviewType {
        case create
        case cancel
        case none
    }
    
    /// 按钮类型
    var buttonType: PreviewType = .none
    var buttonAble: Bool = true
}
