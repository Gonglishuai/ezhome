//
//  ESCaseProductModel.h
//  Consumer
//
//  Created by jiang on 2017/8/21.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESCaseProductModel : NSObject
@property (nonatomic, strong) NSString *catentryId;       //
@property (nonatomic, strong) NSString *skuName;           //
@property (nonatomic, strong) NSString *imgUrl;
@property (nonatomic, strong) NSString *catentrySpuId;       //
+ (instancetype)objFromDict: (NSDictionary *)dict;
@end
