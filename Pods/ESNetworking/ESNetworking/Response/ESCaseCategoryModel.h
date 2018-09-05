//
//  ESCaseCategoryModel.h
//  Consumer
//
//  Created by jiang on 2017/8/23.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESCaseCategoryModel : NSObject
@property (nonatomic, strong) NSString *categoryName;      //
@property (nonatomic, strong) NSString *categoryId;   //
+ (instancetype)objFromDict: (NSDictionary *)dict;
@end
