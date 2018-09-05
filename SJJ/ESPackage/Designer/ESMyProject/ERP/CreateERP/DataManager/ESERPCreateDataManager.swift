//
//  ESERPCreateDataManager.swift
//  ESPackage
//
//  Created by 焦旭 on 2018/1/3.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESERPCreateModel: Codable {
    var customerName: String = ""
    var phoneNum: String = ""
    var province: String = ""
    var provinceCode: String = ""
    var city: String = ""
    var cityCode: String = ""
    var district: String = ""
    var districtCode: String = ""
    var community: String = ""
    var address: String = ""
    var serviceStore: String = ""
    var designer: String = ""
}

class ESERPCreateDataManager: NSObject {
    static func getItemViewModel() -> [ESERPCreateViewModel] {
        var arr: [ESERPCreateViewModel] = Array()
        
        let model1 = ESERPCreateViewModel(title: "业主姓名", placeholder: "请输入业主姓名", itemContent: nil, isSelectedItme: false, key: .consumer)
        arr.append(model1)
        
        let model2 = ESERPCreateViewModel(title: "业主手机号", placeholder: "请输入业主手机号", itemContent: nil, isSelectedItme: false, key: .consumerMobile)
        arr.append(model2)
        
        let model3 = ESERPCreateViewModel(title: "项目地址", placeholder: "请选择省市区", itemContent: nil, isSelectedItme: true, key: .region)
        arr.append(model3)
        
        let model4 = ESERPCreateViewModel(title: "小区名称", placeholder: "请输入小区名称", itemContent: nil, isSelectedItme: false, key: .community)
        arr.append(model4)
        
        let model5 = ESERPCreateViewModel(title: nil, placeholder: "请输入详细地址", itemContent: nil, isSelectedItme: false, key: .addrDetail)
        arr.append(model5)
        
        let model6 = ESERPCreateViewModel(title: "设计师", placeholder: "请输入您在ERP中预留的手机号", itemContent: nil, isSelectedItme: false, key: .designer)
        arr.append(model6)
        
        let model7 = ESERPCreateViewModel(title: "服务门店", placeholder: "请选择服务门店", itemContent: nil, isSelectedItme: true, key: .store)
        arr.append(model7)
        return arr
    }
    
    static func createERP(assertId: String,
                          form: ESERPCreateModel,
                          success: @escaping () -> Void,
                          failure: @escaping (String) -> Void) {
        
        if let data = try? JSONEncoder().encode(form) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                let dic = json as! Dictionary<String, String>
                ESERPApi.createERP(assertId, dic, success: success, failure: { (error) in
                    let msg = SHRequestTool.getErrorMessage(error)
                    failure(msg!)
                })
            } catch _ {
            }
        }
    }
    
    static func manageData(vm: ESERPCreateViewModel, data: ESERPCreateModel) {
        switch vm.key {
        case .consumer:
            data.customerName = vm.itemContent ?? ""
        case .community:
            data.community = vm.itemContent ?? ""
        case .addrDetail:
            data.address = vm.itemContent ?? ""
        case .designer:
            data.designer = vm.itemContent ?? ""
        default:
            break
        }
    }
    
    static func check(_ form: ESERPCreateModel) -> Bool {
        if !ESStringUtil.isEmpty(form.customerName) &&
            !ESStringUtil.isEmpty(form.province) &&
            !ESStringUtil.isEmpty(form.community) &&
            !ESStringUtil.isEmpty(form.address) &&
            !ESStringUtil.isEmpty(form.designer) &&
            !ESStringUtil.isEmpty(form.serviceStore){
            return true
        }
        return false
    }
}
