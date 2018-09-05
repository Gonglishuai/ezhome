//
//  JRPLugin.h
//  JRPLugin
//
//  Created by 何崇 on 2017/10/26.
//  Copyright © 2017年 HeChong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JRPLugin : NSObject

/******************************************************************************/

/*居然插件初始化入口
 *录入参数：info 输入字段为以下参数
 *custId    客户编号    NOT NULL    32    设计家用户ID
 *phone     手机号     NOT NULL    32
 *prodId    产品编号    NOT NULL    20    默认值：3000
 *tokenId   会话标识    NOT NULL    32    设计家Xtoken
 *status    贷款状态    NOT NULL    10    由查询交易返回
 *entrance  插件入口    NOT NULL    20    点击钱包跳转：QBTZ  点击额度跳转：EDTZ
 *
 *返回参数：checkXTokenBlock 初始化验证XToken回调 根据返回状态码判断是验证成功活着失败
 */
+ (instancetype)shareInstance;


/*根据贷款状态进入居然插件页面
 *PS：居然金融根据 entrance（插件入口）和status（贷款状态判断跳转页面） 其余字段进行X-Token验证
 *录入参数info： 输入字段为以下参数
 *custId    客户编号    NOT NULL    32    设计家用户ID
 *phone     手机号     NOT NULL    32
 *prodId    产品编号    NOT NULL    20    默认值：3000
 *tokenId   会话标识    NOT NULL    32    设计家Xtoken
 *status    贷款状态    NOT NULL    10    由查询交易返回
 *entrance  插件入口    NOT NULL    20    点击钱包跳转/账户余额：QBTZ   点击额度跳转：EDTZ
 *occurType 发生类型
 */
+ (void)ToJRPluginWithEntranceInfo:(NSDictionary *)info loginBlock:(void(^)(NSDictionary *dict))loginBlock;


/*分期支付入口
 *支付页面点击开通走 ToJRPluginWithEntranceInfo 接口
 *录入参数：orderInfo  订单信息为以下字段
 *custId        客户编号    NOT NULL    32    设计家用户ID
 *prodId        产品编号    NOT NULL    32    默认值：3000
 *tokenId       token     NOT NULL    32    设计家Xtoken
 *amount        交易金额    NOT NULL    20
 *term          分期期数    NOT NULL    10
 *merNo         商户号    NOT NULL    32
 *storeNo       门店号    NOT NULL    32
 *boothNo      摊位号    NOT NULL    20
 *orderNo       交易单号    NOT NULL    50
 *tranDate      交易日期    NOT NULL    30
 *merchantRate  商户费率    NOT NULL    10
 *memo          备注信息        100
 *
 *返回参数：orderBlock 订单回调函数
 */
+ (NSDictionary *)ToJRStagePayOrderInfo:(NSDictionary *)orderInfo orderBlock:(void(^)(NSDictionary *dict))orderBlock;

/************************************************************************************/

@end


