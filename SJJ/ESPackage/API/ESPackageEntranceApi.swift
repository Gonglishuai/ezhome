//
//  ESPackageEntranceApi.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

typealias ESPackageAPISuccess = (_ data:Data)->Void
typealias ESPackageAPIFailed = ((_ error:Error)->Void)

/// 套餐入口部分API
class ESPackageEntranceApi: NSObject {
    
    ///获取套餐列表
    static func getPackageList(_ success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
       
        let url = "\(baseUrl!)espot/appAllPackage"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)!
        print("url:\(url)   header:\(header)\n")
        SHHttpRequestManager.get(url, withParameters: nil, withHeaderField: header, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (responseData) in
            
            success(responseData!)

        }) { (error) in
            
            print(error.debugDescription)
            
            failed(error!)
        }
    }
    
}
