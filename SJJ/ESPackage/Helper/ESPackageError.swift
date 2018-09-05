//
//  ESPackageError.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/17.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESPackageError {
    static func getErrorMsg(_ error: Error?) -> String {
        var msg = "网络错误, 请稍后重试!"
        if let err = error as NSError? {
            let data = err.userInfo["com.alamofire.serialization.response.error.data"] as? Data
            guard let errorData = data  else {
                return msg
            }
            
            let errDict = try? JSONSerialization.jsonObject(with: errorData, options: .mutableContainers)
            
            guard let dic = errDict as? [String: Any?] else {
                return msg
            }
            
            if dic.keys.contains("message") {
                if let value = dic["message"] as? String,
                    let data = value.data(using: .utf8) {
                    let json = try?  JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    if let jsonDic = json as? [String: Any?], jsonDic.keys.contains("msg") {
                        let str = jsonDic["msg"] as? String
                        msg = str ?? "网络错误, 请稍后重试!"
                    }
                }
            }
            
            if dic.keys.contains("msg") {
                if let value = dic["msg"] as? String {
                    msg = value
                }
            }
        }

        return msg
    }
    
}
