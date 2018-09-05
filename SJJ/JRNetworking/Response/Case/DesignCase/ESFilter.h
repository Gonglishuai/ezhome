//
//  ESFilter.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/3.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  筛选类别

#import <Foundation/Foundation.h>
#import "ESFilterItem.h"

@interface ESFilter : NSObject

@property (nonatomic, strong) NSString *name;                                   // 筛选类别名称
@property (nonatomic, strong) NSString *logo;                                   //
@property (nonatomic, strong) NSString *type;                                   // 筛选类型标识
@property (nonatomic, strong) NSArray <ESFilterItem *> *tagsBeans;    // 筛选类别下的所有标签

+ (instancetype)objFromDict:(NSDictionary *)dict;
@end
