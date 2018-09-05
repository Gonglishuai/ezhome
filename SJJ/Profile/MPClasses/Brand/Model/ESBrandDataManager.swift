//
//  ESBrandDataManager.swift
//  Consumer
//
//  Created by zhang dekai on 2018/3/2.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESBrandDataManager {
    
    static func fixBrandsToNeeded(nowBrand:ESFixRecommendBrandModel)->ESBrandBigTytpe{
       
        var brands = ESBrandBigTytpe()
        
        let list = nowBrand.brandItemList ?? []
        
        for model in list {
            
            let model1 = ESBrandGoodsModel(name: model.brandName ?? "", logo: model.brandLogo ?? "", id: model.brandId ?? "", cat2Id: model.categoryId ?? "", cat2Name: model.categoryName ?? "", hasSelected: true, description: model.description ?? "")
            brands.append(model1)
        }
        return brands
    }

    
}

