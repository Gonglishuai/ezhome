//
//  ESPersonalHeaderView.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESPersonalHeaderViewDelegate <NSObject>

//是否是设计师
@optional
- (BOOL)userIsDesigner;

//获取用户头像
@optional
- (NSString *)getUserHeadIcon;

//获取用户名称
@optional
- (NSString *)getUserName;

//点击头像
@optional
- (void)tapUserHeadIcon;

//点击了右按钮
@optional
- (void)tapRightButton;

@end

@interface ESPersonalHeaderView : UIView

@property (nonatomic, weak) id<ESPersonalHeaderViewDelegate> delegate;

- (void)updateHeaderView;
@end
