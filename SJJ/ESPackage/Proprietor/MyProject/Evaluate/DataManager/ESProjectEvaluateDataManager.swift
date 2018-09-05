//
//  ESProjectEvaluateDataManager.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/1.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESProjectEvaluateDataManager: NSObject {
    
    /// 获取评价标签列表
    static func getEvaluateTags(success: @escaping ([String?]) -> Void, failure: @escaping (String) -> Void) {
        ESPackageProjectApi.getEvaluateTags(success: { (response) in
            if let data = response {
                let container = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                if let array = container as? [String?]{
                    success(array)
                    return
                }
            }
        }) { (error) in
            let msg = SHRequestTool.getErrorMessage(error)
            failure(msg!)
        }
    }
    
    static func getEvaluateStarTitle() -> [String] {
        return ["服务满意度","专业度","交付时效"]
    }
}
