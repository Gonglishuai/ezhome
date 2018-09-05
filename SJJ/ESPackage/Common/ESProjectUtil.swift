//
//  ESPackageUtil.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/8.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESProjectUtil {
    
    static func getStatusInfo(_ status: ESProjectStatus) -> (String, UIColor) {
        switch status {
        case .allocating:
            return ("平台派单中", ESColor.color(hexColor: 0xFF9A02, alpha: 1.0))
        case .designing:
            return ("设计装修中", ESColor.color(hexColor: 0xFF9A02, alpha: 1.0))
        case .toEvaluate:
            return ("待评价", ESColor.color(hexColor: 0xFF9A02, alpha: 1.0))
        case .canceled:
            fallthrough
        case .notThrough:
            return ("交易关闭", ESColor.color(hexColor: 0xD8D8D8, alpha: 1.0))
        case .completed:
            return ("交易完成", ESColor.color(hexColor: 0xD8D8D8, alpha: 1.0))
        default:
            return ("", ESColor.color(hexColor: 0xFFFFFF, alpha: 0.0))
        }
    }
    
    static func getProjectTagInfo(_ proType: ESProjectType, _ pkgType: ESPackageType) -> (String, UIColor, UIColor) {
        switch proType {
        case .Individual:
            return ("个性化", UIColor.white, ESColor.color(hexColor: 0xF3ABA4, alpha: 1.0))
        case .Package:
            
            return ("南韵套餐", UIColor.white, ESColor.color(hexColor: 0xFEC672, alpha: 1.0))
//
//            switch pkgType {
//            case .Beishu:
//                return ("北舒套餐", UIColor.white, ESColor.color(hexColor: 0xD3B584, alpha: 1.0))
//            case .Dongjie:
//                return ("东捷套餐", UIColor.white, ESColor.color(hexColor: 0x9DC9D7, alpha: 1.0))
//            case .Nanyun:
//                return ("南韵套餐", UIColor.white, ESColor.color(hexColor: 0xFEC672, alpha: 1.0))
//            case .Xijing:
//                return ("西境套餐", UIColor.white, ESColor.color(hexColor: 0xA2ABD6, alpha: 1.0))
//            default:
//                return ("套餐", UIColor.white, ESColor.color(hexColor: 0x89CEF3, alpha: 1.0))
//            }
        default:
            return ("", UIColor.white, ESColor.color(hexColor: 0xFFFFFF, alpha: 0.0))
        }
    }
}
