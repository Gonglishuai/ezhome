//
//  ESDesProjectContractViewModel.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/26.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  合同信息

import UIKit

class ESDesProjectContractViewModel: ESViewModel {

    enum ContractType {
        case create
        case edit
        case none
    }
    
    /// 按钮类型
    var buttonType: ContractType = .none
    var buttonAble: Bool = false
}
