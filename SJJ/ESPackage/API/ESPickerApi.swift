//
//  ESPickerApi.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESPickerApi {
    
    /// 获取套餐项目的地址列表
    ///
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func getPackageRegion(success: @escaping (Data?) -> Void, failure: @escaping (Error?) -> Void) {
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.mdmService
        let url = "\(baseUrl!)district/package"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)
        SHHttpRequestManager.get(url,
                                 withParameters: nil,
                                 withHeaderField: header,
                                 withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager,
                                 andSuccess: { (data) in
                                    success(data)
        }) { (error) in
            failure(error)
        }
    }
    
    /// 获取套餐项目的服务门店列表
    ///
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func getServiceStore(success: @escaping (Data?) -> Void, failure: @escaping (Error?) -> Void) {
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        let url = "\(baseUrl!)demand/list/allStore"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)
        SHHttpRequestManager.get(url,
                                 withParameters: nil,
                                 withHeaderField: header,
                                 withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager,
                                 andSuccess: { (data) in
            success(data)
        }) { (error) in
            failure(error)
        }
    }
}
