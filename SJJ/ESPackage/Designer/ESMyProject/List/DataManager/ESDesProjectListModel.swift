//
//  ESDesProjectListModel.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESDesProjectListModel: Codable {
    var count: Int?
    var offset: Int?
    var limit: Int?
    var data: [ESDesProjectListItem]?
}

struct ESDesProjectListItem: Codable {
    /// 项目ID
    var assetId: Int?
    /// 项目编号
    var projectId: Int?
    /// 预约时间
    var publishTime: String?
    /// 套餐类型 1北舒 2西镜 3南韵
    var pkgType: Int?
    /// 套餐名字
    var pkgName: String?
    /// 业务状态 0派单中，1设计中，2未通过，3已取消 4待评价 5已完成
    var status: Int?
    /// 状态名字
    var statusName: String?
    /// 业主姓名
    var name: String?
    /// 业主电话
    var phone: String?
    /// 业主地址
    var address: String?
    /// 套餐标记
    var pkgViewFlag: Int?
    /// 项目类型
    var projectType: Int?
}
