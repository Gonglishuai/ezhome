//
//  MPTranslate.h
//  MarketPlace
//
//  Created by xuezy on 16/2/25.
//  Copyright © 2016年 xuezy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPTranslate : NSObject

+ (NSString *)stringTypeEnglishToChineseWithString:(NSString *)string;
+ (NSString *)stringTypeChineseToEnglishWithString:(NSString *)string;
+ (NSString *)stringToTypeWithString:(NSString *)string;
@end
