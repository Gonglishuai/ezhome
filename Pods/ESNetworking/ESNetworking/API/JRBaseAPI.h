//
//  JRBaseAPI.h
//  Consumer
//
//  Created by jiang on 2017/5/3.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESHTTPSessionManager.h"
#import "SHHttpRequestManager.h"

#define HEADER_AUTHORIZATION_KEY @"Authorization"
#define ERROR(NSString_messageId, NSInteger_code, NSString_message) [NSError errorWithDomain:NSString_messageId code:NSInteger_code userInfo:@{NSLocalizedDescriptionKey : NSString_message}]

@interface JRBaseAPI : NSObject
+ (NSDictionary *)getDefaultHeader;
@end
