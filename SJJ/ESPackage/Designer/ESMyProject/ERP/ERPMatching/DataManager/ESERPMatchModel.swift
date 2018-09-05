//
//  ESERPMatchModel.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESERPMatchModelList: Codable {
    var data: [ESERPMatchModel]?
}

struct ESERPMatchModel: Codable {
    var erpId: String?
    var phoneNum: String?
    var name: String?
    var address: String?
    var designer: String?
    var designerName: String?
    var serviceStore: String?
    var serviceStoreName: String?
}
