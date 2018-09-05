//
//  ESAddressManagementCell.h
//  Consumer
//
//  Created by 焦旭 on 2017/6/28.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESAddressManagementCellDelegate <NSObject>

//获取名字
- (NSString *)getAddressName:(NSInteger)index;

//获取电话
- (NSString *)getAddressPhone:(NSInteger)index;

//获取详细地址
- (NSString *)getAddressDetail:(NSInteger)index;

//是否是默认地址
- (BOOL)isDefaultAddress:(NSInteger)index;

//设为默认地址
- (void)setDefaultAddress:(NSInteger)index;

//编辑地址
- (void)editAddress:(NSInteger)index;

//删除地址
- (void)deleteAddress:(NSInteger)index;

@end

@interface ESAddressManagementCell : UITableViewCell

@property (nonatomic, weak) id<ESAddressManagementCellDelegate> delegate;

- (void)updateAddrManagementCell:(NSInteger)index;
@end
