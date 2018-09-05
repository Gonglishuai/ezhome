//
//  MPAddressSelectedView.h
//  Marketplace
//
//  Created by xuezy on 15/12/8.
//  Copyright © 2015年 xuezy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MPAddressSelectedView;
@protocol MPAddressSelectedDelegate <NSObject>

-(void)selectedAddressinitWithProvince:(NSString *)province withCity:(NSString *)city withTown:(NSString *)town isCertain:(BOOL)isCertain;

@end

@interface MPAddressSelectedView : UIView
@property (weak,nonatomic) id<MPAddressSelectedDelegate>delegate;

-(instancetype)initPickview:(NSString *)titile;

-(instancetype)initPickview:(NSString *)titile provinceCode:(NSString*)provinceCode cityCode:(NSString*)cityCode townCode:(NSString*)townCode;

-(void)setPickerViewprovinceCode:(NSString*)provinceCode cityCode:(NSString*)cityCode townCode:(NSString*)townCode;

-(void)showInView:(UIView *)view;
@end
