//
//  ESWxServices.m
//  Consumer
//
//  Created by jiang on 2017/10/18.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESWxServices.h"
#import "WXApiObject.h"
#import "MBProgressHUD+NJ.h"
#import "DefaultSetting.h"
#import "JRNetEnvConfig.h"

@interface ESWxServices ()
@property (strong, nonatomic)wxShareResultBlock resulrBlock;
@property (strong, nonatomic) void(^payblock)(BaseResp *);
@end

@implementation ESWxServices

+ (instancetype)sharedInstance
{
    static ESWxServices *weiboServices = nil;
    static dispatch_once_t s_predicate;
    dispatch_once(&s_predicate, ^{
        weiboServices = [[super allocWithZone:NULL]init];
    });
    
    return weiboServices;
}

- (void)setUpApiKey {
    [WXApi registerApp:[JRNetEnvConfig sharedInstance].netEnvModel.wxAppKey];
    //向微信注册支持的文件类型
    UInt64 typeFlag = MMAPP_SUPPORT_TEXT | MMAPP_SUPPORT_PICTURE | MMAPP_SUPPORT_LOCATION | MMAPP_SUPPORT_VIDEO |MMAPP_SUPPORT_AUDIO | MMAPP_SUPPORT_WEBPAGE | MMAPP_SUPPORT_DOC | MMAPP_SUPPORT_DOCX | MMAPP_SUPPORT_PPT | MMAPP_SUPPORT_PPTX | MMAPP_SUPPORT_XLS | MMAPP_SUPPORT_XLSX | MMAPP_SUPPORT_PDF;
    
    [WXApi registerAppSupportContentFlag:typeFlag];
}

///override the function of allocWithZone:.
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    return [ESWxServices sharedInstance];
}


///override the function of copyWithZone:.
- (instancetype)copyWithZone:(struct _NSZone *)zone {
    
    return [ESWxServices sharedInstance];
}

+ (BOOL)isWXAppInstalled {
    return [WXApi isWXAppInstalled];
}

/**
 处理微信客户端程序通过URL启动第三方应用时传递的数据
 
 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用
 
 - parameter url: 启动第三方应用的URL
 
 - returns: Bool
 */
+ (BOOL)handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:[ESWxServices sharedInstance]];
}

/**
 发送分享请求，进行微信分享
 
 - parameter title:   主标题
 - parameter content: 副标题
 - parameter image:   图片
 - parameter urlStr:  分享链接
 */
- (void)sendWXShareWithTitle:(NSString *)title
                     content:(NSString *)content
                       image:(UIImage *)image
                      urlStr:(NSString *)urlStr
                  shareStyle:(ShareStyle)shareStyle
                platformType:(PlatformType)platformType
                 resultBlock:(wxShareResultBlock)resultBlock {
    self.resulrBlock = resultBlock;
    
    SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
    sendReq.bText = NO;
    if (platformType == PlatformTypeWechat) {
        sendReq.scene = 0;
    } else {
        sendReq.scene = 1;
    }
    
    WXMediaMessage *urlMessage = [[WXMediaMessage alloc] init];
    
    if (shareStyle == ShareStyleTextAndImage) {
        urlMessage.title = title;
        urlMessage.description = content;
        [urlMessage setThumbImage:image];
        
        WXWebpageObject *webObj = [[WXWebpageObject alloc] init];
        webObj.webpageUrl = urlStr;
        urlMessage.mediaObject = webObj;
    } else {
        [urlMessage setThumbImage:image];
        WXImageObject *imageObject = [[WXImageObject alloc] init];
        imageObject.imageData = UIImagePNGRepresentation(image);
        urlMessage.mediaObject = imageObject;
    }
    sendReq.message = urlMessage;
    [WXApi sendReq:sendReq];
}

- (void)wxPayWithPayInfo:(NSDictionary *)payInfo block:(void(^)(BaseResp *))block {
    self.payblock = block;
    NSMutableString *stamp  = [payInfo objectForKey:@"timestamp"];
    //调起微信支付
    PayReq* req             = [[PayReq alloc] init];
    req.partnerId           = [payInfo objectForKey:@"partnerid"];
    req.prepayId            = [payInfo objectForKey:@"prepayid"];
    req.nonceStr            = [payInfo objectForKey:@"noncestr"];
    req.timeStamp           = stamp.intValue;
    req.package             = [payInfo objectForKey:@"package"];
    req.sign                = [payInfo objectForKey:@"sign"];
    [WXApi sendReq:req];
    //日志输出
    NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[payInfo objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
}

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *respose = (SendAuthResp *)resp;
        if (respose.errCode == WXSuccess) {
            NSLog(@"授权成功");
        } else {
            NSLog(@"授权失败");
        }
    } else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        SendMessageToWXResp *response = (SendMessageToWXResp *)resp;
        BOOL isSucess = NO;
        NSString *strMsg = @"分享失败";
        switch (response.errCode) {
            case WXSuccess: {
                strMsg = @"分享成功";
                isSucess = YES;
                break;
            }
            case WXErrCodeCommon: {
                strMsg = @"分享失败";
                break;
            }
            case WXErrCodeUserCancel: {
                strMsg = @"分享取消";
                break;
            }
            case WXErrCodeSentFail: {
                strMsg = @"分享失败";
                break;
            }
            case WXErrCodeAuthDeny: {
                strMsg = @"微信授权失败";
                break;
            }
            case WXErrCodeUnsupport: {
                strMsg = @"微信不支持";
                break;
            }
            default:
                break;
        }
        if (self.resulrBlock) {
            self.resulrBlock(isSucess);
        }
        [self showAleartWithTitle:strMsg];
        
    } else if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *respose = (PayResp *)resp;
        if (respose.errCode == WXSuccess) {
            NSLog(@"支付成功");
            if (self.payblock) {
                self.payblock(respose);
            }
        } else {
            NSLog(@"支付失败");
            if (self.payblock) {
                self.payblock(respose);
            }
        }
    } else  {
        
    }
}

- (void)showAleartWithTitle:(NSString *)title{
    UIWindow *window  = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = title;
    hud.margin = 30.f;
    [hud setOffset:CGPointMake(hud.offset.x, 0)];
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1];
    
}
@end
