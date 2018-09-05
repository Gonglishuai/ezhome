//
//  ESFinanceServices.m
//  Consumer
//
//  Created by jiang on 2017/12/5.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESFinanceServices.h"
#import <JRFRAMEWORK/JRFRAMEWORK.h>
#import "JRKeychain.h"
#import "DefaultSetting.h"
#import <MGJRouter/MGJRouter.h>

@interface ESFinanceServices ()
@property(nonatomic, strong)JRFinancePayResultBlock jumpBlock;
@property(nonatomic, strong)JRFinancePayResultBlock payBlock;
@property(nonatomic,strong) JRPLugin *plugin;
@end

@implementation ESFinanceServices

+ (instancetype)sharedInstance {
    
    static ESFinanceServices *financeServices = nil;
    static dispatch_once_t s_predicate;
    dispatch_once(&s_predicate, ^{
        financeServices = [[super allocWithZone:NULL]init];
#if DEBUG
#else
        financeServices.plugin = [JRPLugin shareInstance];
#endif
    });
    
    return financeServices;
}


/*根据贷款状态进入居然插件页面
 *PS：居然金融根据 entrance（插件入口）和status（贷款状态判断跳转页面） 其余字段进行X-Token验证
 *录入参数info： 输入字段为以下参数
 *custId    客户编号    NOT NULL    32    设计家用户ID
 *phone     手机号     NOT NULL    32
 *prodId    产品编号    NOT NULL    20    默认值：3000
 *tokenId   会话标识    NOT NULL    32    设计家Xtoken
 *status    贷款状态    NOT NULL    10    由查询交易返回
 *entrance  插件入口    NOT NULL    20    点击钱包跳转/账户余额：QBTZ   点击额度跳转：EDTZ
 *
 */
- (void)jumpToFinanceViewcontrollerWithInfo:(NSDictionary *)info block:(JRFinancePayResultBlock)block {
    if ([[JRKeychain loadSingleUserInfo:UserInfoCodePhone] isEqualToString:@""]) {
        [MGJRouter openURL:@"/Person/AccountSetting"];
        return;
    }
    self.jumpBlock = block;
    NSDictionary *userInfo = [JRKeychain loadAllUserInfo];
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:info];
    [tempDic setObject:[userInfo objectForKey:kUserInfoCodeJId] forKey:@"custId"];
    [tempDic setObject:[userInfo objectForKey:kUserInfoCodePhone] forKey:@"phone"];
    [tempDic setObject:[userInfo objectForKey:kUserInfoCodeXToken] forKey:@"tokenId"];
#if DEBUG
#else
    WS(weakSelf)
    [JRPLugin ToJRPluginWithEntranceInfo:tempDic loginBlock:^(NSDictionary *dict) {
        if (weakSelf.jumpBlock) {
            weakSelf.jumpBlock(dict);
        }
    }];
#endif
}


//居然金融支付
/*分期支付入口
 *支付页面点击开通走 ToJRPluginWithEntranceInfo 接口
 *录入参数：orderInfo  订单信息为以下字段
 *custId        客户编号    NOT NULL    32    设计家用户ID
 *prodId        产品编号    NOT NULL    32    默认值：3000
 *tokenId       token     NOT NULL    32    设计家Xtoken
 *Amount        交易金额    NOT NULL    20
 *Term          分期期数    NOT NULL    10
 *MerNo         商户号    NOT NULL    32
 *StoreNo       门店号    NOT NULL    32
 *BloothNo      摊位号    NOT NULL    20
 *OrderNo       交易单号    NOT NULL    50
 *TranDate      交易日期    NOT NULL    30
 *MerchantRate  商户费率    NOT NULL    10
 *Memo          备注信息        100
 *
 *返回参数：orderBlock 订单回调函数
 */
- (void)financePayWithPayInfo:(NSDictionary *)payInfo block:(JRFinancePayResultBlock)block {
    if ([[JRKeychain loadSingleUserInfo:UserInfoCodePhone] isEqualToString:@""]) {
        [MGJRouter openURL:@"/Person/AccountSetting"];
        return;
    }
    self.payBlock = block;
    NSDictionary *userInfo = [JRKeychain loadAllUserInfo];
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:payInfo];
    [tempDic setObject:[userInfo objectForKey:kUserInfoCodeJId] forKey:@"custId"];
    [tempDic setObject:[userInfo objectForKey:kUserInfoCodePhone] forKey:@"phone"];
    [tempDic setObject:[userInfo objectForKey:kUserInfoCodeXToken] forKey:@"tokenId"];
#if DEBUG
#else
    WS(weakSelf)
    [JRPLugin ToJRStagePayOrderInfo:tempDic orderBlock:^(NSDictionary *dict) {
        if (weakSelf.payBlock) {
            weakSelf.payBlock(dict);
        }
    }];
#endif
}

@end
