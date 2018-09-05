//
//  MPTranslate.m
//  MarketPlace
//
//  Created by xuezy on 16/2/25.
//  Copyright © 2016年 xuezy. All rights reserved.
//

#import "MPTranslate.h"

@implementation MPTranslate

+ (NSString *)stringTypeEnglishToChineseWithString:(NSString *)string
{
    //确保小写
    string = [string lowercaseString];
    
    if ([string isEqualToString:@" _toilet"] ||
        [string isEqualToString:@" _living"] ||
        [string isEqualToString:@" "])
        return @" ";
    
    string = [string stringByReplacingOccurrencesOfString:@"(null)" withString:@"其他"];

    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MPSearchChinese" ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSString *stringChinese = [dictionary objectForKey:string];
    stringChinese = [stringChinese stringByReplacingOccurrencesOfString:@"(null)" withString:@""];

    if (stringChinese == nil) {
        return @"";
    }
    return stringChinese;
}

+ (NSString *)stringTypeChineseToEnglishWithString:(NSString *)string {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MPSearchEnglish" ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSString *stringEnglish = [NSString stringWithFormat:@"%@",dictionary[string]];
    
    if ([stringEnglish isEqualToString:@"(null)"])
    {
        if ([string isEqualToString:@" "])
            return @" ";
        else
            return @"";
    }
        
    return stringEnglish;
    
}

+ (NSString *)stringToTypeWithString:(NSString *)string {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MPSearchType" ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSString *stringType = [NSString stringWithFormat:@"%@",dictionary[string]];
    return stringType;
}

@end
