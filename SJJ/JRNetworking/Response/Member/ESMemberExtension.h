//
//  ESMemberExtension.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/2.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  当前用户设计师角色扩展信息

#import <Foundation/Foundation.h>

@interface ESMemberExtension : NSObject

@property (nonatomic, strong) NSString *pointAmount;        // 装修基金
@property (nonatomic, strong) NSString *couponsAmount;      // 优惠券数
@property (nonatomic, strong) NSString *experience;         // 从业年限
@property (nonatomic, strong) NSString *measurementPrice;   // 量房费
@property (nonatomic, strong) NSString *designPriceMin;     // 设计费最小值
@property (nonatomic, strong) NSString *designPriceMax;     // 设计费最大值
@property (nonatomic, strong) NSString *designPriceCode;    // 设计费编码

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

@end
