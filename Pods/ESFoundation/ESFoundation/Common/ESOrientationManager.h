//
//  ESOrientationManager.h
//  Mall
//
//  Created by 焦旭 on 2017/8/31.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESOrientationManager : NSObject

+ (instancetype)sharedManager;

/**
 设置允许旋转

 @param allow 允许
 */
+ (void)setAllowRotation:(BOOL)allow;

+ (UIInterfaceOrientationMask)getUIInterfaceOrientationMask;
@end
