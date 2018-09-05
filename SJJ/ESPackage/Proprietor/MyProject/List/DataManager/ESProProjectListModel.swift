//
//  ESProProjectListModel.swift
//  Consumer
//
//  Created by Jiao on 2018/1/7.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESProProjectListModel: Codable {
    var count: Int?
    var offset: Int?
    var limit: Int?
    var data: [ESProProjectListItemModel]?
}

struct ESProProjectListItemModel: Codable {
    /// 项目ID
    var assetId: Int?
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
    /// 设计师头像
    var designerAvatar: String?
    /// 设计师姓名
    var designerName: String?
    /// 设计师JmemberId，初始未分配设计师为0
    var designerId: Int?
    /// 设计师电话
    var designerMobile: String?
    /// 未付金额
    var unPaidAmount: Double?
    /// 套餐标记 1套餐
    var pkgViewFlag: Int?
    /// 项目类型
    var projectType: Int?
    /// 预约审核未通过原因
    var bookingFailReason: String?
    /// 提现或者退单详情
    var cashDto: [ESProProjectListCashModel]?
    /// 主订单id
    var mainOrderId: String?
    /// 待付款是否包含首款
    var containsFirstFee: Bool?
    /// 首款是否已支付
    var paidFirstFee: Bool?
}

struct ESProProjectListCashModel: Codable {
    /// 退单或者提现的ID
    var drawCashOrderId: String?
    /// 退单或者提取的余额
    var amount: Float?
    /// 1审核中 2审核通过 3审核失败 4打款失败
    var operateStatus: Int?
    /// 失败原因title
    var showContent: String?
    /// 失败原因描述
    var remark: String?
    /// 退单 project 提取余额cash
    var type: String?
}

