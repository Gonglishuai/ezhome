//
//  ESAppConfig.h
//  Mall
//
//  Created by 焦旭 on 2017/9/18.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESAppConfig : NSObject
///申请退款(退款金额描述)
@property (nonatomic, strong) NSString *return_goods_description;
///施工合同
@property (nonatomic, strong) NSString *pay_the_contract_html;
///论坛
@property (nonatomic, strong) NSString *design_url;
@property (nonatomic, strong) NSString *diary_url;
@property (nonatomic, strong) NSString *bbs_home_url;

///控制金融是否显示的版本号
@property (nonatomic, strong) NSString *consumerVersionFinance;

+ (instancetype)objFromDict:(NSDictionary *)dict;
+ (NSDictionary *)dictFromObj:(ESAppConfig *)obj;

@end
