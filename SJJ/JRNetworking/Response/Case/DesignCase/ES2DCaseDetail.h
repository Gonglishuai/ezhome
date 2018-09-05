//
//  ES2DCaseDetail.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESCaseDesignerInfo : NSObject

@property (nonatomic, strong) NSString *designerId; // j_member_id
@property (nonatomic, strong) NSString *avatar;     // 头像
@property (nonatomic, strong) NSString *userName;   // 用户名
@property (nonatomic, assign) BOOL isFollow;        // 是否关注了
@property (nonatomic, assign) BOOL isAuth;          // 是否为实名认证

@end

@interface ES2DCaseDetail : NSObject
@property (nonatomic, strong) NSString *communityName;              // 小区名称
@property (nonatomic, strong) NSString *caseDescription;            // 案例描述
@property (nonatomic, strong) NSString *favoriteCount;              // 点赞数
@property (nonatomic, strong) NSString *assetId;                    // 案例id
@property (nonatomic, strong) NSArray  *images;                     // 案例图
@property (nonatomic, strong) NSString *prjPrice;                   // 造价
@property (nonatomic, strong) NSString *projectStyle;               // 风格
@property (nonatomic, strong) NSString *roomArea;                   // 面积
@property (nonatomic, strong) NSString *roomType;                   // 户型
@property (nonatomic, strong) NSString *searchTag;                  //
@property (nonatomic, strong) NSString *title;                      // 标题
@property (nonatomic, strong) NSString *caseCover;                  // 首图
@property (nonatomic, assign) BOOL isLike;                  // 是否已点赞
@property (nonatomic, strong) ESCaseDesignerInfo *designerInfo;     // 设计师信息

+ (instancetype)objFromDict:(NSDictionary *)dict;
@end


