//
//  ESBrandApi.swift
//  Consumer
//
//  Created by zhang dekai on 2018/2/28.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESBrandApi:NSObject {
    
    ///获取品牌分类
    static func getBrandsCatagorys(success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.recommend
        
        let url = "\(baseUrl!)mdm/catalogs"
        //        let url = "http://47.94.207.68:30057/api/v1/mdm/catalogs"
        
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)!
        
        print("url:\(url)   header:\(header)\n")
        
        SHHttpRequestManager.get(url, withParameters: nil, withHeaderField: header, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (responseData) in
            
            //            print("responseData:\(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)")
            
            success(responseData!)
            
        }) { (error) in
            
            print(error.debugDescription)
            
            failed(error!)
        }
    }
    
    ///加载招商类目-品牌
    static func getCatagorysBrands(catLevel:String, catId:String, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.recommend
        
        let url = "\(baseUrl!)mdm/catalog/\(catLevel)/\(catId)/brands"
        //        let url = "http://47.94.207.68:30057/api/v1/mdm/catalog/\(catLevel)/\(catId)/brands"
        
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
    
    
    ///品牌搜索
    static func searchBrands(ketword:String, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.recommend
        
        let ketwordEncode = ketword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let url = "\(baseUrl!)mdm/search-brand?name=\(ketwordEncode)"
        //        let url = "http://47.94.207.68:30057/api/v1/mdm/search-brand?name=\(ketwordEncode)"
        
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
    
    ///创建品牌清单
    static func createBrandList(_ parm:Dictionary<String, Any>, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.recommend
        
        let url = "\(baseUrl!)recommendsBrand"
        //        let url = "http://47.94.207.68:30057/api/v1/recommendsBrand"
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
    
    ///获取品牌清单
    static func getBrandList(brandList:String, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.recommend
        
        let url = "\(baseUrl!)recommendsBrand/detailForUpdate/\(brandList)"
        //        let url = "http://47.94.207.68:30057/api/v1/recommendsBrand/detailForUpdate/\(brandList)"
        
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
    
    ///创建品牌清单
    static func fixBrandList(parm:Dictionary<String,Any>, success: @escaping ESPackageAPISuccess, failed:@escaping ESPackageAPIFailed){
        
        let baseUrl = JRNetEnvConfig.sharedInstance().netEnvModel.recommend
        
        let url = "\(baseUrl!)recommendsBrand"
        //        let url = "http://47.94.207.68:30057/api/v1/recommendsBrand"
        
        let header = ESHTTPSessionManager.sharedInstance().getRequestHeader(nil)!
        
        print("url:\(url)   header:\(header)\n")
        
        
        SHHttpRequestManager.put(url, withParameters: parm, withHeaderField: header, withAFTTPInstance: ESHTTPSessionManager.sharedInstance().manager, andSuccess: { (responseData) in
            
            print("responseData:\(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)")
            
            success(responseData!)
            
        }) { (error) in
            
            print(error.debugDescription)
            
            failed(error!)
        }
    }
}
