//
//  ESDesProjectOrderDetailViewModel.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/22.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  预约明细

import UIKit

class ESDesProjectOrderDetailViewModel: ESViewModel {
    /// 标签(内容, 内容颜色, 背景颜色)
    var tag: (text: String?, textColor: UIColor?, bgColor: UIColor?)
    
    /// 项目状态
    var status: (text: String?, color: UIColor?)
    
    /// 项目编号
    var projectId: String?
    
    /// 预约时间
    var orderTime: String?
    
    /// 业主姓名
    var consumerName: String?
    
    /// 联系电话
    var phone: String?
    
    /// 项目地址
    var address: String?
    
    /// 小区名称
    var communityName: String?
   
    /// 房屋类型
    var houseType: String?
    
    /// 建筑面积
    var area: String?
    
    /// 装修预算
    var budget: String?
    
    /// 装修风格
    var style: String?
    
    /// 户型
    var roomType: String?
    
    /// 参考方案
    var solution: String?
    
    /// 备注说明
    var remark: String?
}
