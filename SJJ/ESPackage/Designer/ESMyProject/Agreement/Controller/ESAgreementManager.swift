//
//  ESAgreementManager.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/13.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESAgreementManager: NSObject {
    
    static func editContract(_ info: ESAgreementModel, success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        let (pass, msg) = check(info)
        if !pass {
            failure(msg)
            return
        }
        
        
        if let data = try? JSONEncoder().encode(info) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                let dic = json as! Dictionary<String, String>
                ESPackageProjectApi.editContract(dic, success: { (data) in
                    success()
                }, failure: { (error) in
                    let msg = SHRequestTool.getErrorMessage(error)
                    failure(msg!)
                })
            } catch _ {
                failure("网络错误, 请稍后重试!")
            }
        }
    }
    
    static func check(_ info: ESAgreementModel) -> (pass: Bool, msg: String) {
        var message = ""
        if ESStringUtil.isEmpty(info.name) {
            message = "请输入业主姓名!"
            return (false, message)
        }
        if ESStringUtil.isEmpty(info.mobile) {
            message = "请输入联系电话!"
            return (false, message)
        }
        if ESStringUtil.isEmpty(info.houseSize) {
            message = "请输入套内建筑面积!"
            return (false, message)
        }
        if ESStringUtil.isEmpty(info.houseType) {
            message = "请选择户型!"
            return (false, message)
        }
        if ESStringUtil.isEmpty(info.roomType) {
            message = "请选择房屋类型!"
            return (false, message)
        }
        if ESStringUtil.isEmpty(info.city) {
            message = "请选择小区地址!"
            return (false, message)
        }
        if ESStringUtil.isEmpty(info.community) {
            message = "请输入小区名称!"
            return (false, message)
        }
        if ESStringUtil.isEmpty(info.address) {
            message = "请输入详细地址!"
            return (false, message)
        }
        if ESStringUtil.isEmpty(info.amount) {
            message = "请输入合同金额!"
            return (false, message)
        }
        if ESStringUtil.isEmpty(info.signDate) {
            message = "请选择签约日期!"
            return (false, message)
        }
        if ESStringUtil.isEmpty(info.startDate) {
            message = "请选择开工日期!"
            return (false, message)
        }
        if ESStringUtil.isEmpty(info.proNumber) {
            message = "请输入工期天数!"
            return (false, message)
        }
        if ESStringUtil.isEmpty(info.completeDate) {
            message = "请选择竣工日期!"
            return (false, message)
        }
        return (true, message)
    }
    
    /// 计算竣工日期
    ///
    /// - Parameters:
    ///   - from: 起始日期
    ///   - days: 总天数
    ///   - weekend: 是否包含周末
    /// - Returns: 日期
    static func getCompleteDate(_ from: Date, _ days: Int, _ weekend: Bool) -> Date? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let daysTime = TimeInterval((days + 1) * 24 * 60 * 60)
//        let completeDate = Date(timeInterval: daysTime, since: date)
//        let completeDateStr = dateFormatter.string(from: completeDate)
        
        return nil
    }
}
