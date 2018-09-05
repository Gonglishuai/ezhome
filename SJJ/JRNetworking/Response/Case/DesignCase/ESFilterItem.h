//
//  ESFilterItem.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/3.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  筛选类别中的标签

#import <Foundation/Foundation.h>

@interface ESFilterItem : NSObject

@property (nonatomic, strong) NSString *name;   // 标签名称
@property (nonatomic, strong) NSString *type;   // 标签所属列别
@property (nonatomic, strong) NSString *value;  // 标签的值

+ (instancetype)objFromDict:(NSDictionary *)dict;

+ (NSDictionary *)dictFromObj:(ESFilterItem *)obj;
@end
