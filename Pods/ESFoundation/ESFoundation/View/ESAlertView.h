//
//  ESAlertView.h
//  Mall
//
//  Created by jiang on 2017/9/8.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESAlertView : UIView



/**
 弹窗
 
 @param title 弹窗标题
 @param message 弹窗信息
 @param buttonTitle 按钮信息
 @param btnClickedBlock 按钮回调
 */
+ (void)showTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle withClickedBlock:(void(^)(void))btnClickedBlock;

@end
