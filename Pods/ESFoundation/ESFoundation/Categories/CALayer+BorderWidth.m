//
//  CALayer+BorderWidth.m
//  Consumer
//
//  Created by jiang on 2017/4/25.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "CALayer+BorderWidth.h"

@implementation CALayer (BorderWidth)
- (void)setBorderColorFromUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}
@end
