//
//  ESDefaultPageView.h
//  Mall
//
//  Created by 焦旭 on 2017/8/30.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  空白缺省页

#import <UIKit/UIKit.h>

@interface ESDefaultPageView : UIView

/**
 显示缺省页
 
 @param view 父级页面
 @param image 图片名称
 @param text 描述
 @param buttonTitle 按钮文字
 @param handler 按钮响应事件
 */
+ (void)showDefaultInView:(UIView *)view
                withImage:(NSString *)image
                 withText:(NSString *)text
          withButtonTitle:(NSString *)buttonTitle
              withHandler:(void(^)(void))handler;

/**
 隐藏缺省页
 
 @param view 父级页面
 */
+ (void)hideDefaultFromView:(UIView *)view;
@end
