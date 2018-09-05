//
//  ESProProjectListViewModel.swift
//  Consumer
//
//  Created by Jiao on 2018/1/7.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESProProjectListViewModel: ESViewModel {
    /// 项目状态
    var status: (text: String?, color: UIColor?)
    
    /// 业务类型
    var businessType: String?
    
    /// 业主姓名
    var consumerName: String?
    
    /// 联系电话
    var phone: String?
    
    /// 项目地址
    var address: String?
    
    /// 预约审核失败原因
    var bookingFailReason: (show: Bool, text: String?) = (false, nil)
    
    /// 设计师信息
    var designerInfo: (show: Bool, header: String?, name: String?) = (false, nil, nil)
    
    /// 支付信息
    var payInfo: (show: Bool, amount: Double) = (false, 0.0)
    
    /// 提取余额信息
    var withdrawInfo: (show: Bool, content: String?, amount: Double, complete: Bool) = (false, nil, 0.0, false)
    
    /// 退单信息
    var returnInfo: (show: Bool, title: String?, reason: String?, buttonTitle: String) = (false, nil, nil, "")
    
    /// 去评价信息
    var evaluateInfo: (show: Bool, title: String?, buttonTitle: String) = (false, nil, "")
}
