//
//  ESAddressManagementView.h
//  Consumer
//
//  Created by 焦旭 on 2017/6/28.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESAddressManagementViewDelegate <NSObject>

//获取所有地址的条数
- (NSInteger)getAddressNums;

//点击 添加收货地址
- (void)addNewAddress;

//下拉刷新
- (void)refreshLoadNewData;

@end

@interface ESAddressManagementView : UIView

@property (nonatomic, weak) id<ESAddressManagementViewDelegate> delegate;

//设置添加地址是否可见
- (void)setNewAddressButtonVisible:(BOOL)visible;

- (void)refreshMainView;

//开始tableview头部动画
- (void)startFreshHeaderView;

//停止tableview头部动画
- (void)stopFreshHeaderView;

- (void)deleteAddressWithIndex:(NSInteger)index;
@end
