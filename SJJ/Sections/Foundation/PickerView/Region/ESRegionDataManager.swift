//
//  ESRegionDataManager.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/4.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

public enum RegionDataType {
    case shopping   /// 购物地址
    case package    /// 套餐项目地址
    case memberInfo /// 个人信息地址
    case none
}

public class ESRegionDataManager: NSObject {
    private var dataArray: [ESRegion] = []
    private var type: RegionDataType = .none
    
    init(type: RegionDataType) {
        super.init()
        self.type = type
    }
    
    static func initRegionData(manager: ESRegionDataManager, success: @escaping () -> (), failure: @escaping () -> Void) {
        manager.dataArray.removeAll()
        
        ESPickerApi.getPackageRegion(success: { (response) in
            if let data = response {
                let arr = try? JSONDecoder().decode(ESRegionList.self, from: data)
                if let list = arr {
                    manager.dataArray = list.results ?? []
                    success()
                } else {
                    failure()
                }
            }else {
                failure()
            }
        }) { (error) in
            failure()
        }
    }
    
    func getProvinces() -> [ESRegion] {
        var regions: [ESRegion] = []
        for region in dataArray {
            if let rid = region.parentId, rid == "100000" {
                regions.append(region)
            }
        }
        return regions
    }
    
    func getCitys(provinceCode: String) -> [ESRegion] {
        var regions: [ESRegion] = []
        for region in dataArray {
            if region.parentId == provinceCode {
                regions.append(region)
            }
        }
        return regions
    }
    
    func getDistricts(cityCode: String) -> [ESRegion] {
        var regions: [ESRegion] = []
        for region in dataArray {
            if region.parentId == cityCode {
                regions.append(region)
            }
        }
        return regions
    }
}
