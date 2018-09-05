//
//  ESMBProgressToast.h
//  EZHome
//
//  Created by shiyawei on 3/7/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESMBProgressToast : NSObject

+ (void)showToastAddTo:(UIView*)view;

+ (void)showToastAddTo:(UIView*)view text:(NSString *)text;

+ (void)showToastSucceedAddTo:(UIView*)view text:(NSString *)text;

+ (void)showToastSucceedAddTo:(UIView*)view;

+ (void)showToastErrorAddTo:(UIView*)view text:(NSString *)text;

+ (void)showToastErrorAddTo:(UIView*)view;

+ (void)hideToastForView:(UIView*)view;

@end
