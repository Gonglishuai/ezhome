//
//  ESPackageOrderApi.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/13.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESPackageOrderApi: NSObject {
    /// 支付款优惠计算
    static func promotionCalc(_ dict: [String: String],
                             success: @escaping (Data?) -> Void,
                             failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.designUrl
        let url = "\(baseUrl!)promotions/calc"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)
        SHHttpRequestManager.post(url,
                                  withParameters: nil,
                                  withHeader: header,
                                  withBody: dict,
                                  withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager,
                                  andSuccess: { (task, response) in
                                    success(response)
        }) { (task, error) in
            failure(error)
        }
    }
    
    /// 创建订单
    ///
    /// - Parameters:
    ///   - info: 订单信息
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func orderCreate(_ info: [String: String],
                            success: @escaping (Data?) -> Void,
                            failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.designUrl
        let url = "\(baseUrl!)order/create"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)
        SHHttpRequestManager.post(url,
                                  withParameters: nil,
                                  withHeader: header,
                                  withBody: info,
                                  withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager,
                                  andSuccess: { (task, response) in
                                    success(response)
        }) { (task, error) in
            failure(error)
        }
    }
    
    /// 校验订单是否可以支付
    static func checkPayStatus(_ assetId: String,
                               success: @escaping (Data?) -> Void,
                               failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.designUrl
        let url = "\(baseUrl!)order/checkPayStatus/\(assetId)"
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
    
    /// 面对面支付
    static func orderFace2Face(info: [String: String],
                               success: @escaping (Data?) -> Void,
                               failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.designUrl
        let url = "\(baseUrl!)order/face2Face"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)
        SHHttpRequestManager.post(url,
                                  withParameters: nil,
                                  withHeader: header,
                                  withBody: info,
                                  withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager,
                                  andSuccess: { (task, response) in
                                    success(response)
        }) { (task, error) in
            failure(error)
        }
    }

    /// 提取余额
    ///
    /// - Parameters:
    ///   - orderId: 订单id
    ///   - type: 余额：cash  退款：project
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func orderDrawCash(orderId: String,
                              type: String,
                              success: @escaping (Data?) -> Void,
                              failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.designUrl
        let url = "\(baseUrl!)order/drawCash/\(orderId)/\(type)"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)
        SHHttpRequestManager.post(url,
                                  withParameters: nil,
                                  withHeader: header,
                                  withBody: nil,
                                  withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager,
                                  andSuccess: { (task, response) in
                                    success(response)
        }) { (task, error) in
            failure(error)
        }
    }
    
    /// 套餐订单确认尾款
    ///
    /// - Parameters:
    ///   - orderId: 主订单id
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func confirmLastFee(orderId: String,
                               success: @escaping (Data?) -> Void,
                               failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.order
        let url = "\(baseUrl!)orders/package/confirmLastFee/\(orderId)"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)
        SHHttpRequestManager.post(url,
                                  withParameters: nil,
                                  withHeader: header,
                                  withBody: nil,
                                  withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager,
                                  andSuccess: { (task, response) in
                                    success(response)
        }) { (task, error) in
            failure(error)
        }
    }
    
    /// 查询订单应交付费用
    ///
    /// - Parameters:
    ///   - projectId: 项目id
    ///   - type: 订单类型(定金:2,装修款首款:3,主材预存款:10)
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func getPayDetail(projectId: String,
                             type: String,
                             success: @escaping (Data?) -> Void,
                             failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.designUrl
        let url = "\(baseUrl!)order/payDetail?projectId=\(projectId)&type=\(type)"
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
    
    /// 撤销付款
    ///
    /// - Parameters:
    ///   - projectNum: 项目的ID
    ///   - orderId: 订单号
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func deleteOrder(projectNum: String,
                               orderId: String,
                               success: @escaping (Data?) -> Void,
                               failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.designUrl
        let url = "\(baseUrl!)order/deleteOrder"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)
        let body = ["projectNum": projectNum, "orderList": [orderId]] as [String : Any]
        SHHttpRequestManager.post(url,
                                  withParameters: nil,
                                  withHeader: header,
                                  withBody: body,
                                  withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager,
                                  andSuccess: { (task, response) in
                                    success(response)
        }) { (task, error) in
            failure(error)
        }
    }
    
}
