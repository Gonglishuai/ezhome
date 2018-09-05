//
//  ESPackageEnum.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/8.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

/// 项目类型
///
/// - Package: 套餐
/// - Individual: 个性化
/// - Other: 其他
/// - UnKnow: 未知
enum ESProjectType {
    case Package
    case Individual
    case Other
    case UnKnow
    
    init(_ projectType: Int?) {
        if let proType = projectType {
            switch proType {
            case 5:
                self = .Package
            case 6:
                self = .Other
            case 7:
                self = .Individual
            default:
                self = .UnKnow
            }
        } else {
            self = .UnKnow
        }
    }
}

/// 套餐类型
///
/// - Beishu: 北舒
/// - Nanyun: 南韵
/// - Xijing: 西境
/// - Dongjie: 东捷
/// - UnKnow: 未知
enum ESPackageType {
    case Beishu
    case Nanyun
    case Xijing
    case Dongjie
    case UnKnow
    
    init(_ pkgType: Int?) {
        if let type = pkgType {
            switch type {
            case 1:
                self = .Beishu
            case 2:
                self = .Xijing
            case 3:
                self = .Nanyun
            case 4:
                self = .Dongjie
            default:
                self = .UnKnow
            }
        } else {
            self = .UnKnow
        }
    }
}

/// 项目业务状态
///
/// - allocating: 派单中
/// - designing: 设计中
/// - notThrough: 未通过
/// - canceled: 已取消
/// - toEvaluate: 待评价
/// - completed: 已完成
enum ESProjectStatus {
    case unKnow
    case allocating
    case designing
    case notThrough
    case canceled
    case toEvaluate
    case completed
    
    init(_ value: Int?) {
        if let status = value{
            switch status {
            case 0:
                self = .allocating
            case 1:
                self = .designing
            case 2:
                self = .notThrough
            case 3:
                self = .canceled
            case 4:
                self = .toEvaluate
            case 5:
                self = .completed
            default:
                self = .unKnow
            }
        } else {
            self = .unKnow
        }
    }
}

/// 退单/申请退款 类型
///
/// - unKnow: 未知
/// - chargeback: 退单
/// - balance: 提取余额
enum ESProjectReturnType {
    case unKnow
    case chargeback
    case balance
    
    init(_ value: String?) {
        if let type = value {
            switch type {
            case "project":
                self = .chargeback
            case "cash":
                self = .balance
            default:
                self = .unKnow
            }
        } else {
            self = .unKnow
        }
    }
}

/// 退单/申请退款 审核状态
///
/// - unKnow: 未知
/// - inReview: 审核中
/// - passed: 审核通过 / 打款成功
/// - rejected: 审核未通过
/// - failed: 审核通过、打款失败
enum ESProjectReturnStatus {
    case unKnow
    case inReview
    case rejected
    case passed
    case failed
    
    init(_ value: Int?) {
        if let status = value {
            switch status {
            case 1:
                self = .inReview
            case 2:
                self = .passed
            case 3:
                self = .rejected
            case 4:
                self = .failed
            default:
                self = .unKnow
            }
        } else {
            self = .unKnow
        }
    }
}

/// 预交底 审核状态
///
/// - unKnow: 未知
/// - notApply: 未申请
/// - inReview: 审核中
/// - passed: 已通过
/// - rejected: 未通过
/// - canceld: 取消审核
enum ESProjectPreviewStatus {
    case unKnow
    case notApply
    case inReview
    case passed
    case rejected
    case canceled
    
    init(_ value: String?) {
        if let status = value {
            switch status {
            case "0":
                self = .notApply
            case "1":
                self = .inReview
            case "2":
                self = .passed
            case "3":
                self = .rejected
            case "4":
                self = .canceled
            default:
                self = .unKnow
            }
        } else {
            self = .unKnow
        }
    }
}
