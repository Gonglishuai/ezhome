

//
//  ESBrandGoodsModel.swift
//  Consumer
//
//  Created by zhang dekai on 2018/2/27.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit


/// 品牌分类一级
struct ESBrandsCatalogsModel:Decodable {
    let subList:[ESBrandsCatalogsSubModel]?
    let name:String?
    let id:String?
    let key:String?
}

/// 品牌分类二级
struct ESBrandsCatalogsSubModel:Decodable {
    let name:String?
    let id:String?
    let key:String?
}

/// 品牌商品model
struct ESBrandGoodsModel:Decodable {
    var name:String?
    var logo:String?
    var id:String?
    var cat2Id:String?
    var cat2Name:String?
    var hasSelected:Bool?
    var description:String?

}

/// 修改品牌清单
struct ESFixRecommendBrandModel:Decodable {
    let recommendsBrandId:String?
    let designerId:String?
    let decorationId:String?
    let name:String?
    let description:String?
    let brandItemList:[ESBrandItemListModel]?
}
/// 修改品牌清单 brandItemList
struct ESBrandItemListModel:Decodable {
    let recommendsBrandId:String?
    let brandId:String?
    let brandName:String?
    let brandLogo:String?
    let categoryId:String?
    let categoryName:String?
    let description:String?
}
