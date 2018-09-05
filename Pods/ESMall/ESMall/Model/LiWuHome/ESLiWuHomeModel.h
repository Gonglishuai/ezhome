//
//  ESLiWuHomeModel.h
//  Mall
//
//  Created by 焦旭 on 2017/9/9.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESCMSModel.h"
#import "ESCMSCommodity.h"
#import "ESLiWuCategoryModel.h"

@interface ESLiWuHomeModel : NSObject

@property (nonatomic, strong) NSArray <ESCMSModel *>* banner;
@property (nonatomic, strong) ESCMSCommodity *product;
@property (nonatomic, strong) NSArray <ESLiWuCategoryModel *>* category;

+ (instancetype)objFromDict:(NSDictionary *)dict;
@end
