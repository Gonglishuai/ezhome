
//
//  ESOfferDetailModel.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/9.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import Foundation

struct ESOfferDetailModel:Decodable {
    
    let createDate:String?
    let designId:Int?
    let designName:String?
    let designCoverImg:String?
    let remark:String?
    let status:String?
    let statusName:String?
    let quoteId:String?
    let files:[ESOfferDetailSubModel]?
    let pkgName:String?
    /// erp金额
    let amount:Double?
    /// 报价金额
    let quoteAmount:Double?
}

struct ESOfferDetailSubModel:Decodable {
    let name:String?
    let url:String?
}

struct ESCaseOfferModel:Decodable {
    let projectName:String?
    let projectDesc:String?
    let amount:Double?

}
