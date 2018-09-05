//
//  ESDesignerApi.swift
//  EZHome
//
//  Created by shiyawei on 2/8/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

typealias Success = ((_ data:Any)->Void)
typealias Failure = ((_ error:Error)->Void)

class ESDesignerApi: NSObject {

    /// 获取设计师信息
    ///
    /// - Parameters:
    ///   - designerId: 设计师ID
    ///   - success: 成功返回
    ///   - failure: 失败返回
    static func loadDesignerMsg(_ designerId:String,success:@escaping Success,failure:@escaping Failure) {
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil) as Dictionary
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer as String
        let url = baseUrl + "design/designer/" + designerId
        SHHttpRequestManager.get(url, withParameters: nil, withHeader: header, withBody: nil, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (nil, responseData) in
//            print("responseData:\(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)")
            success(responseData!)
        }) { (nil, error) in
            failure(error!)
        }
    }
    
    
    /// 业主评价
    ///
    /// - Parameters:
    ///   - designId: 设计师Id
    ///   - offset: 分页
    ///   - limit: 数量
    ///   - success: 成功
    ///   - failure: 失败
    static func loadEvaluateList(designId:String,offset:Int,limit:Int,success:@escaping Success,failure:@escaping Failure) {
        
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil) as Dictionary
        let url = JRNetEnvConfig.sharedInstance().netEnvModel.host + "/jrdesign/api/v1/designer/demand/\(designId)/comments?offset=\(offset)&limit=\(limit)"
        
        SHHttpRequestManager.get(url, parameters: nil, headerField: header, afttpInstance: ESHTTPSessionManager.sharedInstance().manager) { (responseObject, error) in
            if error == nil {

                success(responseObject as Any)
            }else {
                failure(error!)
            }
        }
        

    }
    
}



