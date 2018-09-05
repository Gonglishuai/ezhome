//
//  ESPackagePrefirm.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/13.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESPackagePrefirm: Codable {
    /// 预交底日期
    var preDate: String?
    /// 预交底状态
    var status: String?
    /// 状态名称
    var statusName: String?
    /// 角色信息
    var roleList: [ESPackagePrefirmRoleInfo]?
}

struct ESPackagePrefirmRoleInfo: Codable {
    /// 角色名称
    var roleName: String?
    /// 用户姓名
    var userName: String?
    /// 用户手机
    var userMobile: String?
}
