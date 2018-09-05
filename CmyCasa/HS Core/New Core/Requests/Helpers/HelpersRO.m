//
//  HelpersRO.m
//  Homestyler
//
//  Created by Yiftach Ringel on 17/06/13.
//
//

#import "HelpersRO.h"
#import <CommonCrypto/CommonDigest.h>

@implementation HelpersRO

+ (NSDate*)getCurrentRoundedDateTime
{
    NSDate *dateTime = [NSDate date];
    
	// trunc to the last 15 minute block
	NSDateComponents *time = [[NSCalendar currentCalendar]
							  components:NSCalendarUnitHour | NSCalendarUnitMinute | kCFCalendarUnitSecond
							  fromDate:dateTime];
	NSInteger minutes = [time minute];
	NSInteger seconds = [time second];
    NSInteger roundedMinutes = (minutes / 15) * 15;
    NSInteger minutesToRemove = minutes - roundedMinutes;
	dateTime = [dateTime dateByAddingTimeInterval:60*(-minutesToRemove)];
	dateTime = [dateTime dateByAddingTimeInterval:-seconds];
    return dateTime;
}

+ (NSString *)encodeSHA256:(NSString *)inputStr
{    
    const char *cStr = [inputStr UTF8String];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256( cStr, (CC_LONG)strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}
+ (NSDate*) getMidnightUTC {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                   fromDate:[NSDate date]];
    [dateComponents setHour:0];
    [dateComponents setMinute:1];
    [dateComponents setSecond:0];
    
    NSDate *midnightUTC = [calendar dateFromComponents:dateComponents];
    return midnightUTC;
}


+ (NSString*) getUTCFormateDate:(NSDate*) dateTime {
    
    NSDateComponents *comps = [[NSCalendar currentCalendar]
                               components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth
                               fromDate:dateTime];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:[[NSTimeZone systemTimeZone] secondsFromGMT]];
    
    NSTimeInterval timeInterval = [[[NSCalendar currentCalendar] dateFromComponents:comps] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.0f", timeInterval];
}


+ (NSString*) encodeMD5:(NSString*) inputStr {
    const char *cStr = [inputStr UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

+(NSString*)getTimestampInMiliSeconds
{
    
    NSDate* roundedDateTime = [NSDate date];
    
    double timeInterval = [roundedDateTime timeIntervalSince1970];
    timeInterval = floor(timeInterval);
    NSString* unixUtcDateTimeStr =[NSString stringWithFormat:@"%.0lf", timeInterval];
    
    
    return  unixUtcDateTimeStr;
}
@end
