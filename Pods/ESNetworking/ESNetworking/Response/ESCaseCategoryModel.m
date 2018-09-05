//
//  ESCaseCategoryModel.m
//  Consumer
//
//  Created by jiang on 2017/8/23.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseCategoryModel.h"
#import "CoStringManager.h"

@implementation ESCaseCategoryModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.categoryName     = [CoStringManager judgeNSString:dict forKey:@"categoryName"];
        self.categoryId       = [CoStringManager judgeNSString:dict forKey:@"categoryId"];
        
        
    }
    return self;
}

+ (instancetype)objFromDict: (NSDictionary *)dict {
    ESCaseCategoryModel *comment = [[ESCaseCategoryModel alloc] initWithDict:dict];
    return comment;
}

@end
