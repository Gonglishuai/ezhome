//
//  SHStringManager.m
//  Consumer
//
//  Created by Jiao on 16/8/11.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoStringManager.h"

@implementation CoStringManager

#pragma mark - initialization
+ (NSString *)judgeNSString:(id)obj forKey:(NSString *)key {
    if ([self objectIsNull:obj forKey:key]) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@",[obj objectForKey:key]];
}

+ (BOOL)judgeBOOL:(id)obj forKey:(NSString *)key {
    if ([self objectIsNull:obj forKey:key]) {
        return NO;
    }
    return [[obj objectForKey:key] boolValue];
}

+ (NSInteger)judgeNSInteger:(id)obj forKey:(NSString *)key {
    if ([self objectIsNull:obj forKey:key]) {
        return 0;
    }
    return [[obj objectForKey:key] integerValue];
}

+ (float)judgeFloat:(id)obj forKey:(NSString *)key {
    if ([self objectIsNull:obj forKey:key]) {
        return 0.0;
    }
    return [[obj objectForKey:key] floatValue];
}

+ (double)judgeDouble:(id)obj forKey:(NSString *)key {
    if ([self objectIsNull:obj forKey:key]) {
        return 0.0000;
    }
    return [[obj objectForKey:key] doubleValue];
}

+ (BOOL)objectIsNull:(id)obj forKey:(NSString *)key {
    if (obj == nil ||
        [obj isKindOfClass:[NSNull class]] ||
        [obj objectForKey:key] == nil ||
        [[obj objectForKey:key] isKindOfClass:[NSNull class]]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isEmptyString:(NSString *)string{
    //字符串的长度为0表示空串
    if (string.length == 0) {
        return YES;
    }
    if (string == nil) {
        return YES;
    }
    
    if (string == NULL) {
        return YES;
    }
    
    if ([string isEqualToString:@""]) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    
    if([string containsString:@"null"]){
        return YES;
    }
    return NO;
}

+ (NSString *)translateDistrictName:(NSString *)district_name
{
    if ([district_name isEqualToString:@"none"])
        return @" ";
    else
        return district_name;
}

+ (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

#pragma mark - Display
+ (NSString *)displayCheckString:(NSString *)string {
    if (string == nil || [string isKindOfClass:[NSNull class]] || string.length == 0 || [string isEqualToString:@"(null)"] || [string isEqualToString:@"<null>"]) {
        return NO_DATA_STRING;
    }
        
    return string;
}

+ (NSString *)displayCheckPrice:(NSString *)price {
    if (price == nil || [price isKindOfClass:[NSNull class]] || price.length == 0 || [price isEqualToString:@"(null)"] || [price isEqualToString:@"<null>"]) {
        return @"0";
    }
    
    return price;
}

@end
