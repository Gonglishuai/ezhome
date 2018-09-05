//
//  ESPickerView.h
//  Consumer
//
//  Created by jiang on 2017/7/18.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ESPickerView;

@protocol ESPickerViewDelegate <NSObject>

@optional
-(void)toobarDonBtnHaveClick:(ESPickerView *)pickView resultString:(NSString *)resultString;
-(void)toobarCancelBtnHaveClick:(ESPickerView *)pickView resultString:(NSString *)resultString;

@end

@interface ESPickerView : UIView

@property(nonatomic,weak) id<ESPickerViewDelegate> delegate;

/**
 *  通过plistName添加一个pickView
 *
 *  @param plistName          plist文件的名字
 *
 *  @return 带有toolbar的pickview
 */
-(instancetype)initPickviewWithPlistName:(NSString *)plistName;
/**
 *  通过plistName添加一个pickView
 *
 *  @param array              需要显示的数组
 *
 *  @return 带有toolbar的pickview
 */
-(instancetype)initPickviewWithArray:(NSArray *)array;

/**
 *  通过时间创建一个DatePicker
 *
 *  @param defaulDate   默认选中时间
 *  @param minDate      最小时间
 *
 *  @return 带有toolbar的datePicker
 */
-(instancetype)initDatePickWithDate:(NSDate *)defaulDate minDate:(NSDate *)minDate datePickerMode:(UIDatePickerMode)datePickerMode;

/**
 *   移除本控件
 */
-(void)remove;
/**
 *  显示本控件
 */
-(void)show;
/**
 *  设置PickView的颜色
 */
-(void)setPickViewColer:(UIColor *)color;
/**
 *  设置toobar的文字颜色
 */
-(void)setTintColor:(UIColor *)color;
/**
 *  设置toobar的背景颜色
 */
-(void)setToolbarTintColor:(UIColor *)color;

@end
