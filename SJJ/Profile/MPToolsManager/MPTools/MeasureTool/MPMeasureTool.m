
#import "MPMeasureTool.h"

@implementation MPMeasureTool


+ (BOOL)isCurrentDataOverMeasure:(NSInteger)year
                           month:(NSInteger)month
                             day:(NSInteger)day
                            hour:(NSInteger)hour
                          minute:(NSInteger)fen
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *seletedDateStr = [NSString stringWithFormat:@"%ld-%ld-%ld %ld:%ld:%d",
                                (long)year,(long)month,(long)day,(long)hour,(long)fen,59];
    NSDate *seletedDate = [dateFormatter dateFromString:seletedDateStr];
    NSTimeInterval seletedTimeInterval = [seletedDate timeIntervalSince1970];
    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval currentTimeInterval = [currentDate timeIntervalSince1970];

    if (seletedTimeInterval - currentTimeInterval >= 3600 * 3)
        return YES;
    
    return NO;
}


+ (NSDictionary *)getCurrentDate {

    NSDate *currentDate = [NSDate date];
    NSTimeInterval currentTimeInterval = [currentDate timeIntervalSince1970];
    NSTimeInterval returnTimeInterval = currentTimeInterval + 3600 * 3;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY MM dd HH mm"];
    NSDate *returnDate = [NSDate dateWithTimeIntervalSince1970:returnTimeInterval];
    NSString *returnTimeStr = [dateFormatter stringFromDate:returnDate];
    NSArray *arrTime = [returnTimeStr componentsSeparatedByString:@" "];
    if (arrTime.count >= 4)
    {
        NSDictionary *dict = @{@"year"  : arrTime[0],
                               @"month" : arrTime[1],
                               @"day"   : arrTime[2],
                               @"hour"  : arrTime[3],
                               @"minute": arrTime[4]
                               };
        return dict;
    }
    
    return nil;
    
//    NSDate *date = [NSDate date];
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSDateComponents *comps = [[NSDateComponents alloc] init];
//    NSInteger unitFlags = NSCalendarUnitYear |
//    NSCalendarUnitMonth |
//    NSCalendarUnitDay |
//    NSCalendarUnitHour |
//    NSCalendarUnitMinute |
//    NSCalendarUnitSecond;
//    comps = [calendar components:unitFlags fromDate:date];
//    
//    NSDictionary *dict = @{@"year"  : @([comps year]),
//                           @"month" : @([comps month]),
//                           @"day"   : @([comps day]),
//                           @"hour"  : @([comps hour]),
//                           @"minute": @([comps minute])
//                           };
//    return dict;
}

@end
