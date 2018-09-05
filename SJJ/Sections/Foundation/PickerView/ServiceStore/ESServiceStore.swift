//
//  ESServiceStore.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

public struct ESServiceStoreList: Codable {
    var storeDTOList: [ESServiceStore]?
}

public struct ESServiceStore: Codable {
    var code: String?
    
    var name: String?
    
    var region: String?
    
    var parentCode: String?
    
}
