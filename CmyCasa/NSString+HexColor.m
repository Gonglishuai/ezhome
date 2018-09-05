//
//  NSString+HexColor.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/12/13.
//
//

#import "NSString+HexColor.h"


@implementation NSString (HexColor)

- (UIColor *)hextoColorDIY {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
