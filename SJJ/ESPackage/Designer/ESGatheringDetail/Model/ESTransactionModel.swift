//
//  ESTransactionModel.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/11.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import Foundation

struct ESTransactionModel:Decodable {
    let payType:String?
    let paidAmount:Float?
    let payAmount:Float?
    let detailList:[ESTransactionSubModel]?

}

struct ESTransactionSubModel:Decodable {
    let payTime:String?
    let payNo:String?
    let payAmount:Float?
    let payMethodName:String?
    
}
