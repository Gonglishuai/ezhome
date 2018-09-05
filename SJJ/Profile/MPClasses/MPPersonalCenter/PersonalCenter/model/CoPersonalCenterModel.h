//
//  CoPersonalCenterModel.h
//  Consumer
//
//  Created by Jiao on 16/7/13.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoPersonalCenterModel : NSObject

@property (nonatomic, strong) NSString *headIconLink;   // 手机号
@property (nonatomic, strong) NSString *userName;       // 用户名
@property (nonatomic, strong) NSString *mobile_number;  // 手机号
@property (nonatomic, strong) NSString *pointAmount;    // 装修基金
@property (nonatomic, strong) NSString *couponsAmount;  // 优惠券

@property (nonatomic, strong) NSString *code;  // 接口code
@property (nonatomic, strong) NSString *ablAmt;  // 钱包余额
@property (nonatomic, strong) NSString *limitAmt;  // 授信额度
@property (nonatomic, strong) NSString *status;  // 贷款状态:SQZT_XTJJ 系统拒绝// SQZT_SQ 待审核//SQZT_TG 审核通过//SQZT_JJ 审核拒绝//SQZT_JH 已激活//SQZT_SPZ 审批中//SQZT_TH 退回
@property (nonatomic, strong) NSString *statusName;  // 状态名称
@property (nonatomic, strong) NSString *creditStatus;  // 调额状态:Y已调额,N未调额
@property (nonatomic, strong) NSString *creditLimitAmt;  // 调额后的额度
@property (nonatomic, strong) NSString *prodId;  // 产品编号
@property (nonatomic, strong) NSString *limitAmountInfo;  // 最终额度
@property (nonatomic, strong) NSString *statusInfo;  // 个人中心状态名称
@property (nonatomic, strong) NSString *validLimit;  // 可用额度
@property (nonatomic, assign) BOOL canRecommend;  //1、装饰公司已入驻，且为激活状态；2、登录的账号，需与该装饰公司进行了绑定
//从网络获取用户信息(当前用户)
+ (void)getMemberInfoWithSuccess:(void(^)(CoPersonalCenterModel *model))success
                  andUnreadCount:(void(^)(NSInteger count))unread
                      andFailure:(void(^)(NSError *error))failure;
@end
