//
//  UIScreen+UIScreen_Bounds.m
//  Homestyler
//
//  Created by Dan Baharir on 11/3/14.
//
//

#import "UIScreen+Bounds.h"

@implementation UIScreen (Bounds)

+(CGRect)currentScreenBoundsDependOnOrientation
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds] ;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        return screenBounds ;
    }
    CGFloat width = CGRectGetWidth(screenBounds)  ;
    CGFloat height = CGRectGetHeight(screenBounds) ;
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        screenBounds.size = CGSizeMake(width, height);
    }else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        screenBounds.size = CGSizeMake(height, width);
    }
    return screenBounds ;
}
@end
