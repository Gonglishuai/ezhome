//
//  ESPackageBaseAPI.swift
//  ESPackage
//
//  Created by 焦旭 on 2018/1/3.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESPackageBaseAPI {
    
    /// 从模块管理类中获取公共头
    func getHeader() -> [String: String]? {
        return ESPackageManager.sharedInstance.header
    }
    
    func getURL(_ url: String) -> String {
        let host = ESPackageManager.sharedInstance.host
        let sign = ESPackageManager.sharedInstance.sign ? "-sign" : ""
        let version = "api/v1"

        return "\(host)\(url)\(sign)/\(version)"
    }
}
