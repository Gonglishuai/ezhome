//
//  MPDateUtilities.h
//  MarketPlace
//
//  Created by Avinash Mishra on 12/02/16.
//  Copyright © 2016 xuezy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHDateUtility : NSObject

/**
 将时间戳转化为 2017-11-07 13：12（到分级）

 @param timeInterval NSTimeInterval
 @return @“2017-11-07 13:12”
 */
+ (NSString*)formattedDateForMessage:(NSTimeInterval)timeInterval;

/**
 将时间戳转化为 2017-11-07 13:12:20 (到秒级)
 
 @param timeInterval NSTimeInterval
 @return @“2017-11-07 13:12:32”
 */
+ (NSString*)formattedDateForCreated:(NSTimeInterval)timeInterval;

@end
