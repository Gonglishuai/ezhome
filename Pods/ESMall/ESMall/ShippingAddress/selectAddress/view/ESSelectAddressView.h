//
//  ESSelectAddressView.h
//  Consumer
//
//  Created by 焦旭 on 2017/6/27.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESDiyRefreshHeader.h"


@protocol ESSelectAddressViewDelegate <NSObject>

//获取组的分类数
- (NSInteger)getAddressGroupNums;

//获取所有地址的条数
- (NSInteger)getAddressNumsWithSection:(NSInteger)section;

//获取当前组是否可用
- (BOOL)getAddressValidWithSection:(NSInteger)section;

//选择了一个地址
- (void)selectAddressWithSection:(NSInteger)section
                       WithIndex:(NSInteger)index;

//点击 添加收货地址
- (void)addNewAddress;

//下拉刷新
- (void)refreshLoadNewData;
@end

@interface ESSelectAddressView : UIView

@property (nonatomic, weak) id<ESSelectAddressViewDelegate> delegate;

//设置添加地址是否可见
- (void)setNewAddressButtonVisible:(BOOL)visible;

- (void)refreshMainView;

//开始tableview头部动画
- (void)startFreshHeaderView;

//停止tableview头部动画
- (void)stopFreshHeaderView;
@end
