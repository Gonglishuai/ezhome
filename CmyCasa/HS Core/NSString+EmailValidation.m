//
//  NSString+EmailValidation.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/7/13.
//
//

#import "NSString+EmailValidation.h"
#ifndef EMAIL_ADDRESS_REGEX
#define EMAIL_ADDRESS_REGEX @"^.+@.+\\..{2,}$"
#endif
@implementation NSString (EmailValidation)

-(BOOL)isStringValidEmail{
    
    if ([self rangeOfString:EMAIL_ADDRESS_REGEX options:NSRegularExpressionSearch].location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

+(BOOL)notEmpty:(NSString*)string{
    
    
    return (string!=nil && [string length]>0);
    
}
@end
