//
//  ESSelectAddressCell.h
//  Consumer
//
//  Created by 焦旭 on 2017/6/27.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESSelectAddressCellDelegate <NSObject>

//获取名字
- (NSString *)getAddressNameWithSection:(NSInteger)section andIndex:(NSInteger)index;

//获取电话
- (NSString *)getAddressPhoneWithSection:(NSInteger)section andIndex:(NSInteger)index;

//获取详细地址
- (NSString *)getAddressDetailWithSection:(NSInteger)section andIndex:(NSInteger)index;

//是否是默认地址
- (BOOL)isDefaultAddressWithSection:(NSInteger)section andIndex:(NSInteger)index;

//选择的地址
- (BOOL)isSelectedAddressWithSection:(NSInteger)section andIndex:(NSInteger)index;

@end

@interface ESSelectAddressCell : UITableViewCell

@property (nonatomic, assign) BOOL enabel;
@property (nonatomic, weak) id<ESSelectAddressCellDelegate> delegate;

- (void)updateSelectAddrCellWithSection:(NSInteger)section andIndex:(NSInteger)index;
@end
