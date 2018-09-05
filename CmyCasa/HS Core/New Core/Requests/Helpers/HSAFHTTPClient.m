//
//  HSAFHTTPClient.m
//  RestKit
//
//  Created by Yiftach Ringel on 01/07/13.
//  Copyright (c) 2013 RestKit. All rights reserved.
//

#import "HSAFHTTPClient.h"

@implementation HSAFHTTPClient

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest* request = [super requestWithMethod:method path:path parameters:parameters];
    request.timeoutInterval =(self.HStimeoutInterval==0)?10.0:self.HStimeoutInterval;
    return request;
}

@end
