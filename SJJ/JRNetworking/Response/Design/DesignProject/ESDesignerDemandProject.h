//
//  ESDesignerDemandProject.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  设计师项目

#import <Foundation/Foundation.h>

@interface ESDesignerDemandProject : NSObject

@property (nonatomic, strong) NSString *type;               // 项目类型 5套餐 6其它 7个性定制
@property (nonatomic, strong) NSString *avatar;             // 消费者头像
@property (nonatomic, strong) NSString *communityName;      // 小区名称
@property (nonatomic, strong) NSString *provinceName;       // 省
@property (nonatomic, strong) NSString *cityName;           // 市
@property (nonatomic, strong) NSString *districtName;       // 区
@property (nonatomic, strong) NSString *consumerMobile;     // 消费者手机号
@property (nonatomic, strong) NSString *consumerName;       // 消费者姓名
@property (nonatomic, strong) NSString *contest;            // 标识
@property (nonatomic, strong) NSString *consumerJMemberId;  // 消费者j_member_id
@property (nonatomic, strong) NSString *needsId;            // 项目编号
@property (nonatomic, strong) NSString *channel;            // 渠道
@property (nonatomic, strong) NSString *store;              // 店面
@property (nonatomic, strong) NSString *projectNum;         // 其它项目的id

+ (instancetype)objFromDict:(NSDictionary *)dict;
@end
