//
//  ESERPMatchDataManager.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESERPMatchDataManager: NSObject {
    /// 获取erp匹配列表
    static func getERPList(_ mobile: String,
                           success: @escaping ([ESERPMatchModel]) -> Void,
                           failure: @escaping () -> Void) {
        
        ESERPApi.getERPList("", mobile, success: { (response) in
            if let data = response {
                let arr = try? JSONDecoder().decode(ESERPMatchModelList.self, from: data)
                if let list = arr {
                    success(list.data ?? [])
                }
            }else {
                failure()
            }
        }) { (error) in
            failure()
        }
    }
    
    /// 绑定erp项目
    static func bindERP(assetId: String,
                        erpId: String,
                        success: @escaping () -> Void,
                        failure: @escaping (String) -> Void) {
        
        ESERPApi.bindERP(assetId, erpId, success: { (response) in
            success()
        }) { (error) in
            let msg = SHRequestTool.getErrorMessage(error)
            failure(msg!)
        }
    }
}
