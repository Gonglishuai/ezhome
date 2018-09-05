//
//  ESBottomTableCell.h
//  Homestyler
//
//  Created by shiyawei on 25/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ESBottomBtnStyle) {
    ///底部按钮
    ESBottomBtnStyleDefault,
    ///注册按钮+找回密码
    ESBottomBtnStyleRegisterAndGetBackPassword,
    ///找回密码按钮
    ESBottomBtnStyleGetBackPassword,
    ///注册协议按钮
    ESBottomBtnStyleProtocol,
    ///其他账号登录按钮+找回密码
    ESBottomBtnStyleOtherAccountAndGetBackPassword
};

@class ESBottomTableCell;
@protocol ESBottomTableCellDelegate <NSObject>
@optional
///登录/注册按钮事件
- (void)registerBtnAction;
///进入注册/其他账号登录 事件
- (void)esBottomTableCellBottomLeftBtnAction;
///找回密码
- (void)getBackPasswordAction;
@end


@interface ESBottomTableCell : UITableViewCell

@property (nonatomic,weak)    id<ESBottomTableCellDelegate>delegate;
@property (nonatomic,assign)    ESBottomBtnStyle bottomBtnStyle;
///底部提交按钮标题
@property (nonatomic,copy)    NSString *bottomBtnTitle;

//isUserInteractionEnabled 按钮是否可以点击
- (void)resetBottomStyle:(BOOL)userInteractionEnabled;

@end
