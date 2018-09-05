//
//  MPDateUtilities.m
//  MarketPlace
//
//  Created by Avinash Mishra on 12/02/16.
//  Copyright © 2016 xuezy. All rights reserved.
//

#import "SHDateUtility.h"

@implementation SHDateUtility

/**
 将时间戳转化为 2017-11-07 13：12
 
 @param timeInterval NSTimeInterval
 @return @“2017-11-07 13：12”
 */
+ (NSString*)formattedDateForMessage:(NSTimeInterval)timeInterval
{
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(timeInterval / 1000)];
    
    NSDateFormatter *outputFormatter= [[NSDateFormatter alloc] init];
    
    [outputFormatter setLocale:[NSLocale currentLocale]];
    
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *timeString= [outputFormatter stringFromDate:date];
    
    
    return timeString;
}

+ (NSString*)formattedDateForCreated:(NSTimeInterval)timeInterval
{
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(timeInterval / 1000)];
    
    NSDateFormatter *outputFormatter= [[NSDateFormatter alloc] init];
    
    [outputFormatter setLocale:[NSLocale currentLocale]];
    
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *timeString= [outputFormatter stringFromDate:date];
    
    
    return timeString;
}


@end
