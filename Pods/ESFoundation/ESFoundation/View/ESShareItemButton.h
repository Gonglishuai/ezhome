//
//  ESShareItemButton.h
//  Consumer
//
//  Created by jiang on 2017/10/17.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESShareView.h"

@interface ESShareItemButton : UIButton //分享按钮
- (instancetype)initWithFrame:(CGRect)frame
                 platformType:(PlatformType)platformType
                    titleFont:(CGFloat)titleFont
                   titleColor:(UIColor *)titleColor;
@end
