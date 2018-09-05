//
//  SHStringManager.h
//  Consumer
//
//  Created by Jiao on 16/8/11.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoStringManager : NSObject

#define NO_DATA_STRING @"无"
#define NO_CHOOSE_STRING @"未选择"

///initialization
+ (NSString *)judgeNSString:(id)obj forKey:(NSString *)key;
+ (BOOL)judgeBOOL:(id)obj forKey:(NSString *)key;
+ (NSInteger)judgeNSInteger:(id)obj forKey:(NSString *)key ;
+ (float)judgeFloat:(id)obj forKey:(NSString *)key;
+ (double)judgeDouble:(id)obj forKey:(NSString *)key;
+ (BOOL)isEmptyString:(NSString *)string;
+ (BOOL)objectIsNull:(id)obj forKey:(NSString *)key;

//判断是否含有emoj
+ (BOOL)stringContainsEmoji:(NSString *)string;

///display
+ (NSString *)displayCheckString:(NSString *)string;

+ (NSString *)displayCheckPrice:(NSString *)price;
///input validation


/// 区名 如果为none，解析成空串
+ (NSString *)translateDistrictName:(NSString *)district_name;

@end
