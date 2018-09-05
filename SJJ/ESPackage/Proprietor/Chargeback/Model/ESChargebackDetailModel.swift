//
//  ESChargebackDetailModel.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/9.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import Foundation


struct ESChargebackDetailModel:Decodable {
    let data:ESChargebackDetailsModel?
    let message:String?
}

struct ESChargebackDetailsModel:Decodable {
    let projectType:String?
    let projectTypeName:String?
    let consumerName:String?
    let consumerMobile:String?
    let address:String?
    let remark:String?
    let orderId:String?
    let operateTime:String?
    let operateStatus:Int?
    let operateStatusName:String?
    let refundStatus:Int?
    let amount:Float?
    let checkRemark:String?
}

