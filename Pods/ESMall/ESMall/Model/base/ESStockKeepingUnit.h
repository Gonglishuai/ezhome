//
//  ESStockKeepingUnit.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/11.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//
//  SKU

#import <Foundation/Foundation.h>

@interface ESStockKeepingUnit : NSObject
@property (nonatomic, strong) NSString *name;   //SKU属性名
@property (nonatomic, strong) NSString *value;  //SKU属性值
@property (nonatomic, strong) NSString *nameId;   //SKU属性名Id
@property (nonatomic, strong) NSString *valueId;  //SKU属性值Id

+ (instancetype)objFormDict:(NSDictionary *)dict;
@end
