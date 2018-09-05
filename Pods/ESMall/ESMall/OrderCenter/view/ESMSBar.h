//
//  ESMSBar.h
//  Consumer
//
//  Created by jiang on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESMSBar : UIView
+ (instancetype)creatWithFrame:(CGRect)frame Info:(NSDictionary *)info block:(void(^)(void))block;
- (void)setOrderInfo:(NSDictionary *)info isCustom:(BOOL)isCustom;
@end
