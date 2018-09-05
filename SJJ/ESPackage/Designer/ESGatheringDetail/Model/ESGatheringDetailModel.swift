//
//  ESGatheringDetailModel.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/18.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESGatheringDetailModel: NSObject {
    
    static func createModel(role:ESRole) -> [String] {
        
        switch role {
        case .proprietor(action: _, agreeContract: _, entry: _):
            return ["费用名称","费用金额","返现金额","优惠金额","应付金额","已付金额"]
        case .designer:
            return ["费用名称","费用金额","返现金额","优惠金额","应收金额","已收金额"]
        }
    }
}

struct ESGatheringDetailsModel:Decodable{
    var data:ESGatheringDetailsSubModel?
    var message:ESGatheringDetailsSubModel?
}


struct ESGatheringDetailsSubModel:Decodable {
    let paidAmount:Float?
    let amount:Float?
    let unPaidAmount:Float?
    let orderList:[ESGatheringDetailsSubSubModel]?
}

struct ESGatheringDetailsSubSubModel:Decodable {
    let amount:Float?
    let paidAmount:Float?
    let unPaidAmount:Float?
    let discountAmount:Float?
    let cashBackAmount:Float?
    let type:String?
    let remark:String?
    let createDate:String?
    let discountNames:[String]?
    let cashBackNames:[String]?
    var orderId: String?
}

