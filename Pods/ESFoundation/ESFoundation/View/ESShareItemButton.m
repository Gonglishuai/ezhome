//
//  ESShareItemButton.m
//  Consumer
//
//  Created by jiang on 2017/10/17.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESShareItemButton.h"
#import "ESDevice.h"
#import "UIFont+Stec.h"
#import "ESFoundationAssets.h"
@implementation ESShareItemButton


- (UIEdgeInsets)imageEdgeInsets {
    
    float width_Scale = SCREEN_WIDTH/375.0;
    return UIEdgeInsetsMake(0,
                            15*width_Scale,
                            30*width_Scale,
                            15*width_Scale);
}

- (instancetype)initWithFrame:(CGRect)frame
                 platformType:(PlatformType)platformType
                    titleFont:(CGFloat)titleFont
                   titleColor:(UIColor *)titleColor {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpShareButtonPlatformType:platformType
                                 titleFont:titleFont
                                titleColor:titleColor];
        self.tag = platformType;
    }
    return self;
}

- (void)setUpShareButtonPlatformType:(PlatformType)platformType
                           titleFont:(CGFloat)titleFont
                          titleColor:(UIColor *)titleColor
{
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2.5,0,self.frame.size.width-5,self.frame.size.height-12.5)];
    imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame)+5, self.frame.size.width, 10)];
    label.textColor = titleColor;
    label.font = [UIFont fontWithSize:titleFont];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
    switch (platformType) {
        case PlatformTypeWechatTimeline: //朋友圈
            imageView.image = [ESFoundationAssets bundleImage:@"share_wx_circle"];
            label.text = @"微信朋友圈";
            break;
        case PlatformTypeWechat:             //微信好友
            imageView.image = [ESFoundationAssets bundleImage:@"share_wx_friend"];
            label.text = @"微信好友";
            break;
        case PlatformTypeQQFriend:           //手机QQ
            imageView.image = [ESFoundationAssets bundleImage:@"share_qq_friend"];
            label.text = @"QQ好友";
            break;
        case PlatformTypeQZone:              //QQ空间
            imageView.image = [ESFoundationAssets bundleImage:@"share_qq_zone"];
            label.text = @"QQ空间";
            break;
        case PlatformTypeSinaWeibo:           //新浪微博
            imageView.image = [ESFoundationAssets bundleImage:@"share_weibo"];
            label.text = @"微博";
            break;
        case PlatformTypeCopyUrl:           //复制链接
            imageView.image = [ESFoundationAssets bundleImage:@"share_copy_url"];
            label.text = @"复制链接";
            break;
        default:
            break;
    }
    
}


@end

