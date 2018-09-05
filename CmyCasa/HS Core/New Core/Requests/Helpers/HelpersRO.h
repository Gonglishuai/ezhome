//
//  HelpersRO.h
//  Homestyler
//
//  Created by Yiftach Ringel on 17/06/13.
//
//

#import <Foundation/Foundation.h>

@interface HelpersRO : NSObject

+ (NSDate*)getCurrentRoundedDateTime;
+ (NSString *)encodeSHA256:(NSString *)inputStr;
+ (NSDate*) getMidnightUTC;
+ (NSString*) getUTCFormateDate:(NSDate*) dateTime ;

+ (NSString*) encodeMD5:(NSString*) inputStr ;
+(NSString*)getTimestampInMiliSeconds;
@end
