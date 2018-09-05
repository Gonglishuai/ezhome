
//
//  ESPreviewResultDetailModel.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/9.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import Foundation

struct ESPreviewResultRoleListModel:Codable {
    let roleName:String?
    let userName:String?
    let userMobile:String?
}

struct ESPreviewResultDetailModel:Codable {
    let preDate:String?
    let status:String?
    let statusName:String?
    let mobile:String?
    let name:String?
    let address:String?
    let community:String?
    let roleList:[ESPreviewResultRoleListModel]?
}
