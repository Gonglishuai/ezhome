//
//  JRNetEnvModel.m
//  Consumer
//
//  Created by jiang on 2017/6/13.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRNetEnvModel.h"

@interface JRNetEnvModel ()

@end

@implementation JRNetEnvModel

- (NSString *)designUrl
{
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/jrdesign-sign/api/v1/";
    }
    else
    {
        format = @"%@/jrdesign/api/v1/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)designerUrl
{
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/member-app-sign/v1/api/";
    }
    else
    {
        format = @"%@/member-app/v1/api/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)designerV2Url
{
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/member-app-sign/v2/api/";
    }
    else
    {
        format = @"%@/member-app/v2/api/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)transactionUrl
{
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/transaction-app-sign/v1/api/";
    }
    else
    {
        format = @"%@/transaction-app/v1/api/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)casProxyUrl {
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/cas-proxy-sign/auth_user_account/api/v1/";
    }
    else
    {
        format = @"%@/cas-proxy/auth_user_account/api/v1/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)quoteUrl {
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/quote-app-sign/api/";
    }
    else
    {
        format = @"%@/quote-app/api/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)gatewayServer {
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/gateway-sign/api/v1/";
    }
    else
    {
        format = @"%@/gateway/api/v1/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)order {
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/order-sign/api/v1/";
    }
    else
    {
        format = @"%@/order/api/v1/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)memberService {
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/member-sign/api/v1/";
    }
    else
    {
        format = @"%@/member/api/v1/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)mdmService {
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/mdm-sign/api/v1/";
    }
    else
    {
        format = @"%@/mdm/api/v1/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)searchService {
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/search-design-sign/api/v1/";
    }
    else
    {
        format = @"%@/search/api/v1/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)commentService {
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/comments-sign/api/v1/";
    }
    else
    {
        format = @"%@/comments/api/v1/";
    }
    return [NSString stringWithFormat:format, self.host];
}



- (NSString *)nimService {
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/nim-sign/api/v1/";
    }
    else
    {
        format = @"%@/nim/api/v1/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)construct
{
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/construct-sign/api/v1/";
    }
    else
    {
        format = @"%@/construct/api/v1/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)marketing
{
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/marketing-sign/api/v1/";
    }
    else
    {
        format = @"%@/marketing/api/v1/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)notification
{
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/notification-sign/api/v1/";
    }
    else
    {
        format = @"%@/notification/api/v1/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)manufacturer {
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/manufacturer-sign/api/v1/";
    }
    else
    {
        format = @"%@/manufacturer/api/v1/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)searchDesign {
    NSString *format = nil;
    if (self.signStatus) {
        format = @"%@/search-design-sign/api/v1/";
    }else {
        format = @"%@/search-design/api/v1/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)promotion {
    NSString *format = nil;
    if (self.signStatus) {
        format = @"%@/promotion-sign/api/v1/";
    }else {
        format = @"%@/promotion/api/v1/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)memberSearch {
    NSString *format = nil;
    if (self.signStatus) {
        format = @"%@/member-search-app-sign/api/";
    }else {
        format = @"%@/member-search-app/api/";
    }
    return [NSString stringWithFormat:format, self.host];
}

- (NSString *)recommend {
    NSString *format = nil;
    if (self.signStatus)
    {
        format = @"%@/recommend-sign/api/v1/";
    }
    else
    {
        format = @"%@/recommend/api/v1/";
    }
    return [NSString stringWithFormat:format, self.host];
}

@end
