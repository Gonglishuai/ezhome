//
//  ESPickerView.h
//  Consumer
//
//  Created by shiyawei on 17/4/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//推荐分享--省市区联动
#import <UIKit/UIKit.h>

@class ESRecommendShareCustomer;

@class ESCityPickerView;

@protocol ESCityPickerViewDelegate <NSObject>
- (void)esCityPickerView:(ESCityPickerView *)pickerView didSelectedArea:(ESRecommendShareCustomer *)customerArea;
@end

@interface ESCityPickerView : UIView

@property (nonatomic,weak)    id <ESCityPickerViewDelegate>delegate;

- (void)showPickView;

@end
