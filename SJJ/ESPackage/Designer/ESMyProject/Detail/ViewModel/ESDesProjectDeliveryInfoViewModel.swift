//
//  ESDesProjectDeliveryInfoViewModel.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/27.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  交付信息

import UIKit

class ESDesProjectDeliveryInfoViewModel: ESViewModel {
    
    /// 方案(方案名称, 方案图片)
    var delivery: (name: String?, url: String?, showQuote: Bool, pkgName: String?, isFinally: Bool)?
}
