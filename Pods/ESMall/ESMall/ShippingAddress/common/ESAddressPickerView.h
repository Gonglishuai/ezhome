//
//  ESAddressPickerView.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/10.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//
//  地址选择器

#import <UIKit/UIKit.h>

@protocol ESAddressPickerViewDelegate <NSObject>

/**
 确认地址

 @param dict @{@"province"     : @"省名称",
               @"provinceCode" : @"省编号",
               @"city"         : @"市名称",
               @"cityCode"     : @"市编号",
               @"district"     : @"区名称",
               @"districtCode" : @"区编号",
               @"zipcode"      : @"邮编"}
 */
- (void)confirmAddressWithDict:(NSDictionary *)dict;

@end

@interface ESAddressPickerView : UIView

+ (instancetype)addressPickerViewWithDelegate:(UIViewController <ESAddressPickerViewDelegate> *)delegate;

/**
 显示地址选择器

 @param provinceCode 省编号
 @param cityCode 市编号
 @param districtCode 区编号
 */
- (void)showAddrPickerWithProvinceCode:(NSString *)provinceCode
                          withCityCode:(NSString *)cityCode
                       andDistrictCode:(NSString *)districtCode;

- (void)hiddenAddrPicker;
@end
