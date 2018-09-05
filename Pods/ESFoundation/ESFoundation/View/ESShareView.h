//
//  ESShareView.h
//  Consumer
//
//  Created by jiang on 2017/10/17.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,PlatformType) {
    PlatformTypeWechatTimeline = 20, //朋友圈
    PlatformTypeWechat,             //微信好友
    PlatformTypeQQFriend,           //手机QQ
    PlatformTypeQZone,              //QQ空间
    PlatformTypeSinaWeibo,          //新浪微博
    PlatformTypeCopyUrl             //复制链接
};

typedef void(^ShareResultBlock)(PlatformType type,BOOL isSuccess);

typedef NS_ENUM(NSInteger,ShareStyle) {
    ShareStyleTextAndImage = 0, //图文
    ShareStyleImage     //图片
};

@interface ESShareView : UIView


/**
 分享

 @param shareTitle 分享主标题
 @param shareContent 分享副标题
 @param shareImg 分享图片
 @param shareUrl 分享链接
 @param shareStyle 分享类型(图文、只有图片)
 @param resultBlock 结果回调
 */
+ (void)showShareViewWithShareTitle:(NSString *)shareTitle
                       shareContent:(NSString *)shareContent
                           shareImg:(NSString *)shareImg
                           shareUrl:(NSString *)shareUrl
                      shareStyle:(ShareStyle)shareStyle
                             Result:(ShareResultBlock)resultBlock;

@end
