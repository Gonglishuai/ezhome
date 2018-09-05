//
//  ESPackageProjectApi.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESPackageProjectApi: NSObject {
    
    /// 获取设计师项目列表
    ///
    /// - Parameters:
    ///   - type: 列表类型
    ///   - limit: 条数
    ///   - offset: 偏移量
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func getDesignerProjectList(type: String,
                                       keywork: String?,
                                       limit: Int,
                                       offset: Int,
                                       success: @escaping (Data?) -> Void,
                                       failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        let url = "\(baseUrl!)demand/list/designerProject?type=\(type)&limit=\(limit)&offset=\(offset)&keyword=\(keywork ?? "")"
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
    
    /// 获取设计师项目详情
    ///
    /// - Parameters:
    ///   - assertId: 项目id
    ///   - pkgViewTag: 套餐标记
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func getDesignerProjectDetail(_ assetId: String,
                                         _ pkgViewTag: String,
                                         success: @escaping (Data?) -> Void,
                                         failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        let url = "\(baseUrl!)demand/designer/project/\(assetId)?pkgViewTag=\(pkgViewTag)"
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
    
    /// 获取业主项目列表
    ///
    /// - Parameters:
    ///   - limit: 条数
    ///   - offset: 偏移量
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func getProprietorProjectList(limit: Int,
                                         offset: Int,
                                         success: @escaping (Data?) -> Void,
                                         failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        let url = "\(baseUrl!)demand/list/customerProject?offset=\(offset)&limit=\(limit)"
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
    
    /// 获取业主项目详情
    ///
    /// - Parameters:
    ///   - assertId: 项目id
    ///   - pkgViewTag: 套餐标记
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func getProprietorProjectDetail(_ assetId: String,
                                           _ pkgViewTag: String,
                                           success: @escaping (Data?) -> Void,
                                           failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        let url = "\(baseUrl!)demand/customer/project/\(assetId)?pkgViewTag=\(pkgViewTag)"
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
    
    /// 取消预交底
    ///
    /// - Parameters:
    ///   - assetId: 项目id
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func cancelPreview(_ assetId: String,
                              success: @escaping (Data?) -> Void,
                              failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        let url = "\(baseUrl!)demand/preConfirm/cancel/\(assetId)"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)
        SHHttpRequestManager.post(url,
                                  withParameters: nil,
                                  withHeaderField: header,
                                  withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager,
                                  andSuccess: { (data) in
                                    success(data)
        }) { (error) in
            failure(error)
        }
    }
    
    /// 录入，修改合同
    ///
    /// - Parameters:
    ///   - dict: 合同信息
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func editContract(_ dict: [String: String],
                             success: @escaping (Data?) -> Void,
                             failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        let url = "\(baseUrl!)demand/contract"
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
    
    /// 获取项目合同列表
    ///
    /// - Parameters:
    ///   - assetId: 项目id
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func getContractList(_ assetId: String,
                                _ type: String,
                                success: @escaping (Data?) -> Void,
                                failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        let url = "\(baseUrl!)demand/contract/\(assetId)/\(type)"
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
    
    /// 获取评价标签列表
    ///
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func getEvaluateTags(success: @escaping (Data?) -> Void,
                                failure: @escaping (Error?) -> Void) {
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.designUrl
        let url = "\(baseUrl!)project/getCommentTags"
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
