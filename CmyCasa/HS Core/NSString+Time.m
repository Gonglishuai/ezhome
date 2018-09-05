//
//  NSString+Time.m
//  smartTime
//
//  Created by Gavin on 16/7/8.
//  Copyright © 2016年 Gavin. All rights reserved.
//

#import "NSString+Time.h"
#import "NSBundle+Language.h"

@implementation NSString (Time)


- (NSString *)smartTime
{
    NSString *languageCode = [[NSBundle mainBundle] getLanguageCode];

    NSLocale *locale = [NSLocale currentLocale];
    NSString* countryCode = [locale objectForKey:NSLocaleCountryCode];
    NSString *localeId = [NSString stringWithFormat:@"%@_%@", languageCode, countryCode/*locale.countryCode*/];
    locale = [NSLocale localeWithLocaleIdentifier:localeId];

    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.locale = locale;

    NSTimeInterval time=[self doubleValue] / 1000;
    NSDate *createDate=[NSDate dateWithTimeIntervalSince1970:time];

    NSDate *now = [NSDate date];// 当前时间
    NSCalendar *calendar = [NSCalendar currentCalendar];  // 日历对象（方便比较两个日期之间的差距）
    // NSCalendarUnit枚举代表想获得哪些差值
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *cmps = [calendar components:unit fromDate:createDate toDate:now options:0];// 两日期差值

    if ([createDate isThisYear]) {
        // within this year
        if ([createDate isToday]) {
            // within today
            if (cmps.hour < 1) {
                // within an hour
                if (cmps.minute < 1) {
                    // within a minute
                    return [NSString stringWithFormat:NSLocalizedString(@"just_now", @"Just now")];
                } else {
                    if (cmps.minute == 1) {
                        return NSLocalizedString(@"1_minute", @"1 min");
                    }
                    return [NSString stringWithFormat:NSLocalizedString(@"num_minutes", @"%i min"), (int)cmps.minute];
                }
            } else {
                if (cmps.hour == 1) {
                    return NSLocalizedString(@"1_hour", @"1 hr");
                }
                return [NSString stringWithFormat:NSLocalizedString(@"num_hours", @"%i hrs"), (int)cmps.hour];
            }
        } else if ([createDate isYesterday]) {
            // yesterday
            return NSLocalizedString(@"yesterday", @"Yesterday");
        } else {
            // two days ago within this year
            if ([languageCode isEqualToString:@"zh"] || [languageCode isEqualToString:@"ja"]) {
                fmt.dateFormat = @"M-dd";
            } else {
                fmt.dateFormat = @"d MMMM";
            }
            return [fmt stringFromDate:createDate];
        }
    } else {
        // before this year
        if ([languageCode isEqualToString:@"zh"] || [languageCode isEqualToString:@"ja"]) {
            fmt.dateFormat = @"yyyy-M-dd";
        } else {
            fmt.dateFormat = @"d MMMM yyyy";
        }
        return [fmt stringFromDate:createDate];
    }
}

@end





@implementation NSDate (Extension)

/**
 *  判断某个时间是否为今年
 */
- (BOOL)isThisYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 获得某个时间的年月日时分秒
    NSDateComponents *dateCmps = [calendar components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *nowCmps = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    return dateCmps.year == nowCmps.year;
}

/**
 *  判断某个时间是否为昨天
 */
- (BOOL)isYesterday
{
    NSDate *now = [NSDate date];
    
    // date ==  2014-04-30 10:05:28 --> 2014-04-30 00:00:00
    // now == 2014-05-01 09:22:10 --> 2014-05-01 00:00:00
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    
    // 2014-04-30
    NSString *dateStr = [fmt stringFromDate:self];
    // 2014-10-18
    NSString *nowStr = [fmt stringFromDate:now];
    
    // 2014-10-30 00:00:00
    NSDate *date = [fmt dateFromString:dateStr];
    // 2014-10-18 00:00:00
    now = [fmt dateFromString:nowStr];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *cmps = [calendar components:unit fromDate:date toDate:now options:0];
    
    return cmps.year == 0 && cmps.month == 0 && cmps.day == 1;
}

/**
 *  判断某个时间是否为今天
 */
- (BOOL)isToday
{
    NSDate *now = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    
    NSString *dateStr = [fmt stringFromDate:self];
    NSString *nowStr = [fmt stringFromDate:now];
    
    return [dateStr isEqualToString:nowStr];
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}
@end

