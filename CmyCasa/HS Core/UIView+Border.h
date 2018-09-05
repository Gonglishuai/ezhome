//
//  UIView+Border.h
//  Homestyler
//
//  Created by Eric Dong on 02/04/18.
//  adopted from https://stackoverflow.com/questions/3330378/cocoa-touch-how-to-change-uiviews-border-color-and-thickness by spencery2
//

#import <UIKit/UIKit.h>

//IB_DESIGNABLE
@interface UIView (Border)

-(void)setBorderColor:(UIColor *)color;
-(void)setBorderWidth:(CGFloat)width;
-(void)setCornerRadius:(CGFloat)radius;

@end
