//
//  ESHomePageApi.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/28.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

enum ESHomePageType: String {
    case Proprietor = "1"
    case Designer = "2"
}

class ESHomePageApi: NSObject {
    
    /// 获取首页数据
    ///
    /// - Parameters:
    ///   - type: 类型
    ///   - isLogin: 是否为登录状态
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func getHomePageData(type: ESHomePageType,
                                isLogin: Bool,
                                success: @escaping (Data?) -> Void,
                                failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        let url = "\(baseUrl!)espot/appIndex/\(type.rawValue)"
        var header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)
        
        if !isLogin {
            header!["X-Token"] = ""
            header!["X-Member-Id"] = "0"
        }
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
