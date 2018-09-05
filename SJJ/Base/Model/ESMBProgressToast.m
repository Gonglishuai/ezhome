//
//  ESMBProgressToast.m
//  EZHome
//
//  Created by shiyawei on 3/7/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESMBProgressToast.h"
#import "MBProgressHUD.h"

@interface ESMBProgressToast ()

@end

@implementation ESMBProgressToast

+ (void)showToastAddTo:(UIView*)view {
    [MBProgressHUD showHUDAddedTo:view animated:YES];
}

+ (void)showToastAddTo:(UIView*)view text:(NSString *)text {
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.label.text = text;
    hud.mode = MBProgressHUDModeText;
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:1];
    [view addSubview:hud];
}

+ (void)showToastSucceedAddTo:(UIView*)view text:(NSString *)text {}

+ (void)showToastSucceedAddTo:(UIView*)view {}

+ (void)showToastErrorAddTo:(UIView*)view text:(NSString *)text {}

+ (void)showToastErrorAddTo:(UIView*)view {}

+ (void)hideToastForView:(UIView *)view {
    [MBProgressHUD hideHUDForView:view animated:YES];
}

@end
