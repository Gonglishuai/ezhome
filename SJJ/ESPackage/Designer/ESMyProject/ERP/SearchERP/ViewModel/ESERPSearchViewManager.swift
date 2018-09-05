//
//  ESERPSearchViewManager.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/14.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESERPSearchViewManager: NSObject {
    /// 搜索erp项目
    static func getERP(_ erpId: String,
                       _ mobile: String,
                       success: @escaping (ESERPMatchModel) -> Void,
                       failure: @escaping (String) -> Void) {
        let erpIdEncode = erpId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        ESERPApi.getERPList(erpIdEncode, mobile, success: { (response) in
            if let data = response {
                let arr = try? JSONDecoder().decode(ESERPMatchModelList.self, from: data)
                if let list = arr?.data, list.count > 0 {
                    success(list[0])
                } else {
                    failure("未找到相应的ERP项目!")
                }
            }else {
                failure("未找到相应的ERP项目!")
            }
        }) { (error) in
            let msg = SHRequestTool.getErrorMessage(error)
            failure(msg!)
        }
    }
}
