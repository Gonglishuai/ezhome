//
//  JRBaseAPI.m
//  Consumer
//
//  Created by jiang on 2017/5/3.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRBaseAPI.h"
#import "JRKeychain.h"
#import "JRLocationServices.h"
#import "ESHTTPSessionManager.h"

@implementation JRBaseAPI

+ (NSDictionary *)getDefaultHeader
{
    return [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];

}

@end
