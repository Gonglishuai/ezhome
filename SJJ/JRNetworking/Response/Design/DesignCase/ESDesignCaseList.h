//
//  ESDesignCaseList.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/6.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  案例列表模型

#import <Foundation/Foundation.h>

@interface ESDesignCaseList : NSObject

@property (nonatomic, assign) BOOL isNew;                   // 是否为新案例
@property (nonatomic, strong) NSString *assetId;            // 案例id
@property (nonatomic, strong) NSString *designCover;        // 案例图片
@property (nonatomic, strong) NSString *designName;         // 案例名称
@property (nonatomic, strong) NSString *designerId;         // 设计师id
@property (nonatomic, strong) NSString *designerAvatar;     // 设计师头像
@property (nonatomic, assign) BOOL designerCertifyStatus;   // 设计师是否实名
@property (nonatomic, strong) NSString *designerName;       // 设计师名称
@property (nonatomic, strong) NSString *style;              // 案例风格
@property (nonatomic, strong) NSString *area;               // 面积
@property (nonatomic, strong) NSString *roomType;           // 户型
@property (nonatomic, strong) NSString *favoriteCount;      // 点赞数

+ (instancetype)objFromDict:(NSDictionary *)dict;
@end
