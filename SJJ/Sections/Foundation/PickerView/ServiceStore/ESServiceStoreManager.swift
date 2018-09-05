//
//  ESServiceStoreManager.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

public class ESServiceStoreManager: NSObject {
    static func getStoreList(success: @escaping ([ESServiceStore]) -> Void, failure: @escaping () -> Void ) {
        ESPickerApi.getServiceStore(success: { (response) in
            if let data = response {
                let arr = try? JSONDecoder().decode(ESServiceStoreList.self, from: data)
                if let list = arr {
                    success(list.storeDTOList ?? [])
                }
            }else {
                failure()
            }
        }) { (error) in
            failure()
        }
    }
}
