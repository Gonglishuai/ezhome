//
//  ESOrientationManager.m
//  Mall
//
//  Created by 焦旭 on 2017/8/31.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESOrientationManager.h"

@interface ESOrientationManager()
@property (nonatomic, assign) BOOL allowRotation;//允许旋转
@end

@implementation ESOrientationManager

+ (instancetype)sharedManager {
    static ESOrientationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ESOrientationManager alloc] init];
        instance.allowRotation = NO;
    });
    return instance;
}

+ (void)setAllowRotation:(BOOL)allow {
    [ESOrientationManager sharedManager].allowRotation = allow;
    if (!allow) {
        if ([[UIDevice currentDevice]   respondsToSelector:@selector(setOrientation:)]) {
            SEL selector =     NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val =UIInterfaceOrientationPortrait;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
    }
}

+ (UIInterfaceOrientationMask)getUIInterfaceOrientationMask {
    if ([ESOrientationManager sharedManager].allowRotation) {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationMaskPortrait;
}
@end
