//
//  JRNetEnvModel.h
//  Consumer
//
//  Created by jiang on 2017/6/13.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JRNetEnvModel : NSObject

/// 签名状态
@property (nonatomic, assign) BOOL signStatus;

///API
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *WebHost;
///图片拼接
@property (nonatomic, copy) NSString *imgHost;
@property (nonatomic, copy) NSString *mServer;
@property (nonatomic, copy) NSString *appType;
@property (nonatomic, copy) NSString *bbsURL;
@property (nonatomic, copy) NSString *envFlag;

@property (readonly, nonatomic, copy) NSString *designUrl;
@property (readonly, nonatomic, copy) NSString *transactionUrl;
@property (readonly, nonatomic, copy) NSString *casProxyUrl;
@property (readonly, nonatomic, copy) NSString *quoteUrl;
@property (readonly, nonatomic, copy) NSString *memberService;//会员服务
@property (readonly, nonatomic, copy) NSString *gatewayServer;
@property (readonly, nonatomic, copy) NSString *order;//交易服务
@property (readonly, nonatomic, copy) NSString *mdmService;//主数据服务
@property (readonly, nonatomic, copy) NSString *searchService;//搜索服务
@property (readonly, nonatomic, copy) NSString *commentService;//评论服务
@property (readonly, nonatomic, copy) NSString *nimService;//云信服务
@property (readonly, nonatomic, copy) NSString *construct;
@property (readonly, nonatomic, copy) NSString *marketing;
@property (readonly, nonatomic, copy) NSString *notification;
@property (readonly, nonatomic, copy) NSString *manufacturer;//厂商服务
@property (readonly, nonatomic, strong) NSString *searchDesign;
@property (readonly, nonatomic, strong) NSString *promotion;
@property (readonly, nonatomic, strong) NSString *memberSearch;
@property (readonly, nonatomic, strong) NSString *recommend;

//三方库key
@property (nonatomic, copy) NSString *mapServicesApiKey;//高德地图key
@property (nonatomic, copy) NSString *weiboAppKey;//微博key
@property (nonatomic, copy) NSString *weiboRedirectURI;//微博回调页中的 url
@property (nonatomic, copy) NSString *wxAppKey;//微信key
@property (nonatomic, copy) NSString *umengAppKey;//友盟key
@property (nonatomic, copy) NSString *umengChannelId;//友盟ChannelId
@property (nonatomic, copy) NSString *schemeForUPAPay;//银联支付scheme

@end
