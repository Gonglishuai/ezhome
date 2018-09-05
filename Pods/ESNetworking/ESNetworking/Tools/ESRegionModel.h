//
//  ESRegionModel.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/10.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESRegionModel : NSObject
@property (nonatomic, strong) NSString *rid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *parentId;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, strong) NSString *levelType;
@property (nonatomic, strong) NSString *cityCode;
@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, strong) NSString *pinyin;

+ (instancetype)objFromDict:(NSDictionary *)dict;
@end
