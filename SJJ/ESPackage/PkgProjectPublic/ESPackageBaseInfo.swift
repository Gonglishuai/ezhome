//
//  ESPackageBaseInfo.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/13.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESPackageBaseInfo: Codable {
    /// ERP_ID,非套餐没有此ID
    var erpId: String?
    /// 项目ID
    var assetId: Int?
    /// 项目编号
    var projectId: Int?
    /// 套餐类型
    var pkgType: Int?
    /// 套餐名称
    var pkgName: String?
    /// 项目类型
    var projectType: Int?
    /// 状态 业务状态 0派单中，1设计中，2未通过，3已取消 4待评价 5已完成
    var status: Int?
    /// 状态名称
    var statusName: String?
    /// 预约时间
    var publishTime: String?
    /// 姓名
    var consumerName: String?
    /// 联系电话
    var consumerMobile: String?
    /// 小区名称
    var communityName: String?
    /// 地址
    var address: String?
    /// 面积
    var houseArea: String?
    /// 房屋类型 code
    var houseType: String?
    /// 房屋类型 name
    var houseTypeName: String?
    /// 预算
    var budget: String?
    /// 装修风格
    var designStyle: String?
    /// 装修风格Name
    var designStyleName: String?
    /// 户型 code
    var roomType: String?
    /// 户型 name
    var roomTypeName: String?
    /// 未付
    var unPaidAmount: Double?
    /// 已付
    var paidAmount: Double?
    /// 主订单id
    var mainOrderId: String?
    /// 费用跳转H5url
    var amountRedirectUrl: String?
    /// 首款是否已付
    var paidFirstFee: Bool?
    /// 待付款是否包含首款
    var containsFirstFee: Bool?
    /// 预约失败原因
    var bookingFailReason: String?
    /// 省
    var provinceName: String?
    /// 省code
    var provinceCode: String?
    /// 市
    var cityName: String?
    /// 市code
    var cityCode: String?
    /// 区
    var districtName: String?
    /// 区code
    var districtCode: String?
    /// 参考方案名称
    var sourceName: String?
    /// 参考方案assetId
    var sourceUrl: String?
    /// 参考方案类型
    var sourceType: String?
    /// 备注
    var remark: String?
    /// 显示费用详情 (true:显示，false：不显示)
    var showSettlement: Bool?
    /// 线上尾款确认状态 (N:为确认，Y:已确认)
    var lastFeeStatus: String?
    /// 所有订单是否包含首款
    var hasFirstFee: Bool?
}
