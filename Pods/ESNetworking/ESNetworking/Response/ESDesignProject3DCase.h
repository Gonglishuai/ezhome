//
//  ESDesignProject3DCase.h
//  Consumer
//
//  Created by 焦旭 on 2017/8/8.
//  Copyright © 2017年 Autodesk. All rights reserved.
//
//  项目详情的3D案例

#import <Foundation/Foundation.h>

@interface ESDesignProject3DCase : NSObject

@property (nonatomic, strong) NSString *designAssetId;
@property (nonatomic, strong) NSString *designName;
@property (nonatomic, strong) NSString *mainImageUrl;
@property (nonatomic, assign) BOOL isNew;

+ (instancetype)objFromDict:(NSDictionary *)dict;
@end
