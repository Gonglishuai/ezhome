//
//  ESEditAddressView.h
//  Consumer
//
//  Created by 焦旭 on 2017/6/28.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESEditAddressViewDelegate <NSObject>

@optional
/**
 获取地址联系人姓名

 @return 姓名
 */
- (NSString *)getAddressName;


/**
 获取地址联系人电话

 @return 电话
 */
- (NSString *)getAddressPhone;


/**
 获取省市区信息

 @return 省市区字符串
 */
- (NSString *)getLocation;


/**
 获取地址详情

 @return 详情
 */
- (NSString *)getAddressDetail;

/**
 点击保存

 地址信息的字典
 */
- (void)saveAddress;

/**
 点击了地址选择
 */
- (void)tapSelectAddress;

- (void)textFieldEndEditing:(NSMutableDictionary *)info;

- (void)textFieldBeginEditing;

- (void)setDefaultAddress:(BOOL)isDefault;
@end

@interface ESEditAddressView : UIView

@property (nonatomic, weak) id<ESEditAddressViewDelegate> delegate;


/**
 更新视图
 */
- (void)updateEditView;
@end
