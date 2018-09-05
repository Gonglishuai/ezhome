//
//  ESERPApi.swift
//  ESPackage
//
//  Created by 焦旭 on 2018/1/3.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESERPApi {
    
    /// 创建ERP
    ///
    /// - Parameters:
    ///   - assetId: 项目id
    ///   - param: 表单
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func createERP(_ assetId: String, _ param: [String: String], success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {

        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        let url = "\(baseUrl!)demand/createErp/\(assetId)"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)
        SHHttpRequestManager.post(url, withParameters: nil,
                                  withHeader: header,
                                  withBody: param,
                                  withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager,
                                  andSuccess: { (task, response) in
                                    success()
                                    
        }) { (task, error) in
            failure(error)
        }
    }
    
    /// 获取ERP列表
    ///
    /// - Parameters:
    ///   - mobile: 手机号
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func getERPList(_ erpid: String, _ mobile: String, success: @escaping (Data?) -> Void, failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        let url = "\(baseUrl!)demand/list/erpProject?erpId=\(erpid)&mobile=\(mobile)"
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
    
    /// 绑定ERP项目
    ///
    /// - Parameters:
    ///   - assetId: 项目id
    ///   - erpId: erp项目id
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func bindERP(_ assetId: String, _ erpId: String, success: @escaping (Data?) -> Void, failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        let url = "\(baseUrl!)demand/bindErp/\(assetId)/\(erpId)"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)
        SHHttpRequestManager.post(url, withParameters: nil,
                                  withHeader: header,
                                  withBody: nil,
                                  withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager,
                                  andSuccess: { (task, response) in
                                    success(response)
                                    
        }) { (task, error) in
            failure(error)
        }
    }
}
