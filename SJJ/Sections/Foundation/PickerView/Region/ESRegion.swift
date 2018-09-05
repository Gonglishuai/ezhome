//
//  ESRegion.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/4.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

public struct ESRegionList: Codable {
    var results: [ESRegion]?
    var count: Int?
}

public struct ESRegion: Codable {
    
    /// 区域id
    var id: String?
    
    /// 区域名称
    var name: String?
    
    /// 父级区域id
    var parentId: String?
    
    /// 区域简称
    var shortName: String?
    
    /// 区域等级
    var levelType: String?
    
    /// 区域编码
    var cityCode: String?
    
    /// 区域邮编
    var zipcode: String?
    
    /// 区域拼音
    var pinyin: String?
}

public struct ESSelectedRegion {
    
    var province: String = ""
    var provinceCode: String = ""
    var city: String = ""
    var cityCode: String = ""
    var district: String = ""
    var districtCode: String = ""
}
