//
//  ESCaptchaTableCell.h
//  Homestyler
//
//  Created by shiyawei on 25/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//图片验证码

#import <UIKit/UIKit.h>
#import "ESLoginAPI.h"

@class ESCaptchaTableCell;

@protocol ESCaptchaTableCellDelegate <NSObject>
@optional
- (void)esCaptchaTableCell:(ESCaptchaTableCell *)cell textShouldChange:(BOOL)enable;

/**
 编辑结束

 @param cell cell
 @param text 输入框内容
 @param imageRandomCodeKey imageRandomCodeKey 目前在登录页在有验证码的时候需要填写，其他情况不填写。
 */
- (void)esCaptchaTableCell:(ESCaptchaTableCell *)cell textDidEndEditing:(NSString *)text imageRandomCodeKey:(NSString *)imageRandomCodeKey;
- (void)esCaptchaTableCellReloadCaptcha;


@end

@interface ESCaptchaTableCell : UITableViewCell
@property (nonatomic,weak)    id<ESCaptchaTableCellDelegate>delegate;
///图片验证码所在页面
@property (nonatomic,assign)    ESRegisterPageType pageType;
///显示指示器
@property (nonatomic,assign)    BOOL isShowIndicatorView;
@end
