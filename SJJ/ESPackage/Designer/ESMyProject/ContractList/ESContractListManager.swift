//
//  ESContractListModel.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/13.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESContractListManager: NSObject {
    static func getContractList(assetId: String,
                                type: String,
                                success: @escaping ([ESPackageContract]) -> Void,
                                failure: @escaping (String) -> Void) {
        ESPackageProjectApi.getContractList(assetId, type, success: { (response) in
            if let data = response {
                let model = try? JSONDecoder().decode(Array<ESPackageContract>.self, from: data)
                if model != nil {
                    success(model!)
                    return
                }
            }
            failure("网络错误, 请稍后重试!")
        }) { (error) in
            let errmsg = SHRequestTool.getErrorMessage(error)
            failure(errmsg!)
        }
    }
}
