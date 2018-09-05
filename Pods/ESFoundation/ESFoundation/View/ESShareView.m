//
//  ESShareView.m
//  Consumer
//
//  Created by jiang on 2017/10/17.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESShareView.h"
#import "ESShareItemButton.h"
#import "ESWeiboServices.h"
#import "WXApi.h"
#import "SDWebImageDownloader.h"
#import "MBProgressHUD+NJ.h"
#import "ESWxServices.h"
#import <ESBasic/ESDevice.h>
#import "DefaultSetting.h"
#import "UIColor+Stec.h"

//左间距
#define SHARE_ITEM_SPACE_LEFT                 15
//间距
#define SHARE_ITEM_SPACE                      10

//高
#define SHARE_BG_HEIGHT                       (85+(SCREEN_WIDTH-2*SHARE_ITEM_SPACE_LEFT-4*SHARE_ITEM_SPACE)/5)

//item高
#define SHARE_ITEM_Height                      ((SCREEN_WIDTH-2*SHARE_ITEM_SPACE_LEFT-4*SHARE_ITEM_SPACE)/5)

//item宽
#define SHARE_ITEM_WIDTH                      ((SCREEN_WIDTH-2*SHARE_ITEM_SPACE_LEFT-2*SHARE_ITEM_SPACE)/3)


//背景view tag
#define BG_TAG                                1234

@interface ESShareView ()
{
    NSMutableArray *_ButtonTypeShareArray;
}
@property (strong, nonatomic)ShareResultBlock resultBlock;
@property (copy, nonatomic)NSString *shareTitle;
@property (copy, nonatomic)NSString *shareContent;
@property (copy, nonatomic)NSString *shareImg;
@property (copy, nonatomic)NSString *shareUrl;
@property (assign, nonatomic)ShareStyle shareStyle;
@end

@implementation ESShareView

+ (instancetype)sharedInstance
{
    static ESShareView *shareView = nil;
    static dispatch_once_t s_predicate;
    dispatch_once(&s_predicate, ^{
        shareView = [[super allocWithZone:NULL]init];
    });
    
    return shareView;
}

///override the function of allocWithZone:.
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    return [ESShareView sharedInstance];
}


///override the function of copyWithZone:.
- (instancetype)copyWithZone:(struct _NSZone *)zone {
    
    return [ESShareView sharedInstance];
}

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
                             Result:(ShareResultBlock)resultBlock {
    [[ESShareView sharedInstance] initWithShareTitle:shareTitle shareContent:shareContent shareImg:shareImg shareUrl:shareUrl shareStyle:shareStyle Result:resultBlock];
}

- (void)initWithShareTitle:(NSString *)shareTitle
              shareContent:(NSString *)shareContent
                  shareImg:(NSString *)shareImg
                  shareUrl:(NSString *)shareUrl
                shareStyle:(ShareStyle)shareStyle
                    Result:(ShareResultBlock)resultBlock {
    self.resultBlock = resultBlock;
    self.shareTitle = shareTitle;
    self.shareContent = shareContent;
    self.shareImg = shareImg;
    self.shareUrl = shareUrl;
    self.shareStyle = shareStyle;
    [self initShareUI];
    
}

/**
 *  初始化视图
 */
- (void)initShareUI{
    
    _ButtonTypeShareArray = [NSMutableArray array];
    /***************************** 添加底层bgView ********************************************/
    UIWindow *window  = [UIApplication sharedApplication].keyWindow;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    bgView.tag = BG_TAG;
    [window addSubview:bgView];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissShareView)];
    [bgView addGestureRecognizer:tap1];
    
    /***************************** 添加分享shareBGView ***************************************/
    
    UIView *shareBGView = [[UIView alloc] init];
    CGRect finaRect = CGRectMake(0, SCREEN_HEIGHT-SHARE_BG_HEIGHT, SCREEN_WIDTH, SHARE_BG_HEIGHT);;
    shareBGView.frame = finaRect;
    shareBGView.userInteractionEnabled = YES;
    shareBGView.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:shareBGView];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapNoe)];
    [shareBGView addGestureRecognizer:tap2];
    
    /****************************** 添加item ************************************************/
    //按钮数组
    CGFloat itemHeight        = SHARE_ITEM_Height;
    CGFloat itemY             = SHARE_ITEM_SPACE_LEFT;
    NSInteger index = 0;
    CGFloat font = 10;
    UIColor *titleColor = [UIColor stec_subTitleTextColor];
    if ([WXApi isWXAppInstalled]) {
        ESShareItemButton *wechat = [[ESShareItemButton alloc] initWithFrame:CGRectMake(SHARE_ITEM_SPACE_LEFT+index*(SHARE_ITEM_WIDTH+10), itemY+SHARE_ITEM_Height, SHARE_ITEM_WIDTH, itemHeight) platformType:PlatformTypeWechat titleFont:font titleColor:titleColor];
        
        [wechat addTarget:self
                   action:@selector(shareTypeClickIndex:)
         forControlEvents:UIControlEventTouchUpInside];
        
        [shareBGView addSubview:wechat];
        [_ButtonTypeShareArray addObject:wechat];
        index++;
        ESShareItemButton *wechatTimeline = [[ESShareItemButton alloc] initWithFrame:CGRectMake(SHARE_ITEM_SPACE_LEFT+index*(SHARE_ITEM_WIDTH+10), itemY+SHARE_ITEM_Height, SHARE_ITEM_WIDTH, itemHeight) platformType:PlatformTypeWechatTimeline titleFont:font titleColor:titleColor];
        
        [wechatTimeline addTarget:self
                           action:@selector(shareTypeClickIndex:)
                 forControlEvents:UIControlEventTouchUpInside];
        
        [shareBGView addSubview:wechatTimeline];
        [_ButtonTypeShareArray addObject:wechatTimeline];
        index++;
    }
    
    ESShareItemButton *weibo = [[ESShareItemButton alloc] initWithFrame:CGRectMake(SHARE_ITEM_SPACE_LEFT+index*(SHARE_ITEM_WIDTH+10), itemY+SHARE_ITEM_Height, SHARE_ITEM_WIDTH, itemHeight) platformType:PlatformTypeSinaWeibo titleFont:font titleColor:titleColor];
    
    [weibo addTarget:self
              action:@selector(shareTypeClickIndex:)
    forControlEvents:UIControlEventTouchUpInside];
    
    [shareBGView addSubview:weibo];
    [_ButtonTypeShareArray addObject:weibo];
    index++;
    
    //    ESShareItemButton *copy = [[ESShareItemButton alloc] initWithFrame:CGRectMake(SHARE_ITEM_SPACE_LEFT+index*(SHARE_ITEM_WIDTH+10), itemY+SHARE_ITEM_Height, SHARE_ITEM_WIDTH, itemHeight) platformType:PlatformTypeCopyUrl titleFont:font titleColor:titleColor];
    //
    //    [copy addTarget:self
    //              action:@selector(shareTypeClickIndex:)
    //    forControlEvents:UIControlEventTouchUpInside];
    //
    //    [shareBGView addSubview:copy];
    //    [_ButtonTypeShareArray addObject:copy];
    //    index++;
    
    /****************************** 取消 ********************************************/
    
    UIButton *cancleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, SHARE_BG_HEIGHT-45, SCREEN_WIDTH, 45)];
    [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    cancleButton.titleLabel.font = [UIFont systemFontOfSize:16];
    cancleButton.backgroundColor = [UIColor whiteColor];
    [cancleButton setTitleColor:[UIColor stec_subTitleTextColor] forState:UIControlStateNormal];
    cancleButton.enabled = YES;
    [cancleButton addTarget:self action:@selector(dismissShareView) forControlEvents:UIControlEventTouchUpInside];
    [shareBGView addSubview:cancleButton];
    
    
    /****************************** 动画 ********************************************/
    shareBGView.alpha = 0;
    [UIView animateWithDuration:0.35
                     animations:^{
                         bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
                         shareBGView.frame = finaRect;
                         shareBGView.alpha = 1;
                     } completion:^(BOOL finished) {
                         
                     }];
    
    
    for (ESShareItemButton *button in _ButtonTypeShareArray) {
        NSInteger idx = [_ButtonTypeShareArray indexOfObject:button];
        
        [UIView animateWithDuration:0.9+idx*0.1 delay:0 usingSpringWithDamping:0.52 initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            CGRect buttonFrame = [button frame];
            buttonFrame.origin.y -= SHARE_ITEM_Height;
            button.frame = buttonFrame;
        } completion:^(BOOL finished) {
            
        }];
    }
    
    
}

- (void)shareTypeClickIndex:(UIButton *)btn{
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window];
    PlatformType platformType = (PlatformType)btn.tag;
    WS(weakSelf)
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD showHUDAddedTo:window animated:YES];
    if (platformType == PlatformTypeCopyUrl) {//复制链接
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.shareUrl;
        [MBProgressHUD showSuccess:@"复制成功!"];
        [weakSelf dismissShareView];
    } else {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:self.shareImg] options:SDWebImageDownloaderProgressiveDownload progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (finished) {
                [MBProgressHUD hideHUDForView:window animated:YES];
                switch (platformType) {
                    case PlatformTypeWechatTimeline: { //朋友圈
                        [[ESWxServices sharedInstance] sendWXShareWithTitle:self.shareTitle content:self.shareContent image:[self zipImageWithImage:image] urlStr:self.shareUrl shareStyle:self.shareStyle platformType:PlatformTypeWechatTimeline resultBlock:^(BOOL isSuccess) {
                            self.resultBlock(PlatformTypeSinaWeibo, isSuccess);
                        }];
                        break;
                    }
                    case PlatformTypeWechat: {            //微信好友
                        [[ESWxServices sharedInstance] sendWXShareWithTitle:self.shareTitle content:self.shareContent image:[self zipImageWithImage:image] urlStr:self.shareUrl shareStyle:self.shareStyle platformType:PlatformTypeWechat resultBlock:^(BOOL isSuccess) {
                            self.resultBlock(PlatformTypeSinaWeibo, isSuccess);
                        }];
                        break;
                    }
                    case PlatformTypeQQFriend:           //手机QQ
                        
                        break;
                    case PlatformTypeQZone:              //QQ空间
                        
                        break;
                    case PlatformTypeSinaWeibo: {          //新浪微博
                        [[ESWeiboServices sharedInstance] sendSinaShareWithTitle:self.shareTitle content:self.shareContent image:image urlStr:self.shareUrl shareStyle:self.shareStyle resultBlock:^(BOOL isSuccess) {
                            self.resultBlock(PlatformTypeSinaWeibo, isSuccess);
                        }];
                        break;
                    }
                    case PlatformTypeCopyUrl: {           //复制链接
                        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                        pasteboard.string = self.shareUrl;
                        [MBProgressHUD showSuccess:@"复制成功!"];
                        break;
                    }
                    default:
                        break;
                }
            }
        }];
        [self dismissShareView];
    }
    
    
}

- (void)dismissShareView{
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *blackView = [window viewWithTag:BG_TAG];
    [UIView animateWithDuration:0.3
                     animations:^{
                         blackView.alpha = 0;
                         CGRect blackFrame = [blackView frame];
                         blackFrame.origin.y = 0;
                         blackView.frame = blackFrame;
                     }
                     completion:^(BOOL finished) {
                         [blackView removeFromSuperview];
                     }];
    
}


- (void)tapNoe{
}

- (UIImage *)zipImageWithImage:(UIImage *)sourceImage
{
    CGFloat  maxFileSize = 32.0;
    CGFloat maxImageSize = 512.0;
    
    //先调整分辨率
    CGSize newSize = CGSizeMake(sourceImage.size.width, sourceImage.size.height);
    
    CGFloat tempHeight = newSize.height / maxImageSize;
    CGFloat tempWidth = newSize.width / maxImageSize;
    
    if (tempWidth > 1.0 || tempHeight > 1.0) {
        if (tempWidth >= tempHeight) {
            newSize = CGSizeMake(sourceImage.size.width / tempWidth, sourceImage.size.height / tempWidth);
        }else {
            newSize = CGSizeMake(sourceImage.size.width / tempHeight, sourceImage.size.height / tempHeight);
        }
    }
    
    UIGraphicsBeginImageContext(newSize);
    [sourceImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //调整大小
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    CGFloat sizeOriginKB = imageData.length / 1024.0;
    
    CGFloat resizeRate = 0.9;
    while (sizeOriginKB > maxFileSize && resizeRate > 0.1) {
        imageData = UIImageJPEGRepresentation(newImage,resizeRate);
        sizeOriginKB = imageData.length / 1024.0;
        resizeRate -= 0.1;
    }
    
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    return compressedImage;
}

@end

