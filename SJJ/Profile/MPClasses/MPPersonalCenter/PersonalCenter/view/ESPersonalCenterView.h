//
//  ESPersonalCenterView.h
//  Consumer
//
//  Created by 焦旭 on 2017/6/22.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//
//  个人中心 MainView

#import <UIKit/UIKit.h>

@protocol ESPersonalCenterViewDelegate <NSObject>

//获取组数
@optional
- (NSInteger)getSectionNums;

//获取某组的item条数
@optional
- (NSInteger)getItemNums:(NSInteger)section;

//点击某一item
@optional
- (void)tapItemWithIndex:(NSInteger)index andSection:(NSInteger)section;

//用户是否为设计师
@optional
- (BOOL)userIsDesigner;
@optional
- (void)tableViewDidScrollWithContentY:(CGFloat)contentY;

@end

@interface ESPersonalCenterView : UIView

@property (nonatomic, weak) id<ESPersonalCenterViewDelegate> delegate;
- (void)setDelegate;
- (void)refreshMainView;
@end
