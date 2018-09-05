//
//  ESAppointApi.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESAppointApi: NSObject {

    ///预约
    static func appoint(_ parm:Dictionary<String,String>, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        
        let url = "\(baseUrl!)demand/booking"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)!
        
        print("url:\(url)   header:\(header) parm:\(parm)")
        
        SHHttpRequestManager.post(url, withParameters: parm, withHeaderField: header, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (responseData) in
            print("responseData:\(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)")

            success(responseData!)
            
        }) { (error) in
            
            print(error.debugDescription)
            
            failed(error!)
        }
    }
    
    ///创建家装项目
    static func creatProject(_ parm:Dictionary<String,String>, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        
        let url = "\(baseUrl!)demand/booking"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)as!Dictionary<String,String>
        
        print("url:\(url)   header:\(header)\n")
        
        SHHttpRequestManager.post(url, withParameters: parm, withHeaderField: header, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (responseData) in
            print("responseData:\(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)")

            success(responseData!)
            
        }) { (error) in
            
            print(error.debugDescription)
            
            failed(error!)
        }
        
    }
    
    ///发起预交底
    static func previewResult(_ parm:Dictionary<String,String>, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        
        let url = "\(baseUrl!)demand/preConfirm"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)!
        
        print("url:\(url)   header:\(header)\n")
        
        SHHttpRequestManager.post(url, withParameters: parm, withHeaderField: header, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (responseData) in
            print("responseData:\(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)")

            success(responseData!)
            
        }) { (error) in
            print(error.debugDescription)
            
            failed(error!)
        }
    }
    
    ///预交底详情
    static func previewResultDetail(_ projectId:String, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        
        let url = "\(baseUrl!)demand/preConfirm/\(projectId)"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)!
        
        print("url:\(url)   header:\(header)\n")
        
        SHHttpRequestManager.get(url, withParameters: nil, withHeaderField: header, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (responseData) in
            print("responseData:\(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)")

            success(responseData!)
            
        }) { (error) in
            
            print(error.debugDescription)
            
            failed(error!)
        }
    }
    
    ///取消预约
    static func cancleAppointWith(_ assetId:String, parm:Dictionary<String,String>, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        
        let url = "\(baseUrl!)demand/booking/cancel/\(assetId)"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)!
        
        print("url:\(url)   header:\(header)\n")
        
        SHHttpRequestManager.post(url, withParameters: parm, withHeaderField: header, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (responseData) in
            print("responseData:\(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)")

            success(responseData!)
            
        }) { (error) in
            
            print(error.debugDescription)
            
            failed(error!)
        }
    }
    
    ///装修风格
    static func getDecorationStyle(_ success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        
        let url = "\(baseUrl!)espot/styles"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)!
        
        print("url:\(url)   header:\(header)\n")
        
        SHHttpRequestManager.get(url, withParameters: nil, withHeaderField: header, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (responseData) in
            print("responseData:\(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)")

            success(responseData!)
            
        }) { (error) in
            
            print(error.debugDescription)
            
            failed(error!)
        }
    }
    
    ///收款明细
    static func getGatheringDetail(_ projectId:String, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.designUrl
        
        let url = "\(baseUrl!)order/query/all/\(projectId)"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)!
        
//        print("url:\(url)   header:\(header)\n")
        
        SHHttpRequestManager.get(url, withParameters: nil, withHeaderField: header, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (responseData) in
            
//            print("responseData:\(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)")

            success(responseData!)
            
        }) { (error) in
            
            print(error.debugDescription)
            
            failed(error!)
        }
    }
    
    ///交易流水
    static func getTaransaction(_ orderId:String, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        
        let url = "\(baseUrl!)demand/list/packagePayRecord/\(orderId)"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)!
        
        print("url:\(url)   header:\(header)\n")
        
        SHHttpRequestManager.get(url, withParameters: nil, withHeaderField: header, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (responseData) in
            
            print("responseData:\(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)")

            success(responseData!)
            
        }) { (error) in
            
            print(error.debugDescription)
            
            failed(error!)
        }
    }
    
    ///申请退单
    static func cancleOrder(_ parm:Dictionary<String,String>, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.designUrl
        
        let url = "\(baseUrl!)order/cancel"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)!
        
        print("url:\(url)   header:\(header)\n")
        
        SHHttpRequestManager.post(url, withParameters: parm, withHeaderField: header, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (responseData) in
            
            print("responseData:\(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)")

            success(responseData!)
            
        }) { (error) in
            
            print(error.debugDescription)
            
            failed(error!)
        }
    }
    
    ///退单详情
    static func cancleOrderDetail(_ orderId:String, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.designUrl
        
        let url = "\(baseUrl!)order/detail/\(orderId)"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)!
        
        print("url:\(url)   header:\(header)\n")
        
        SHHttpRequestManager.get(url, withParameters: nil, withHeaderField: header, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (responseData) in
            
            print("responseData:\(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)")

            success(responseData!)
            
        }) { (error) in
            
            print(error.debugDescription)
            
            failed(error!)
        }
    }
    
    ///图纸报价详情
    static func imageOfferDetail(_ projectId:String, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        
        let url = "\(baseUrl!)demand/designDetail/\(projectId)"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)!
        
        print("url:\(url)   header:\(header)\n")
        
        SHHttpRequestManager.get(url, withParameters: nil, withHeaderField: header, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (responseData) in
            
            print("responseData:\(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)")
            
            success(responseData!)
            
        }) { (error) in
            
            print(error.debugDescription)
            
            failed(error!)
        }
    }

    ///方案报价
    static func caseOffer(_ caseId:String, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        
        let url = "\(baseUrl!)demand/\(caseId)/getAppQuoteSummary"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)!
        
        print("url:\(url)   header:\(header)\n")
        
        SHHttpRequestManager.get(url, withParameters: nil, withHeaderField: header, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (responseData) in
            
            print("responseData:\(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)")

            success(responseData!)
            
        }) { (error) in
            
            print(error.debugDescription)
            
            failed(error!)
        }
    }
    
    
    ///确定优惠券
    static func confirmCoupon(_ projectId:String, parm:Dictionary<String,String>, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.gatewayServer
        
        let url = "\(baseUrl!)demand/bonusDiscount/\(projectId)"
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)!
        
        print("url:\(url)   header:\(header)\n")
        
        SHHttpRequestManager.post(url, withParameters: parm, withHeaderField: header, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (responseData) in
            
            print("responseData:\(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)")
            
            success(responseData!)
            
        }) { (error) in
            
            print(error.debugDescription)
            
            failed(error!)
        }
    }
    
}
