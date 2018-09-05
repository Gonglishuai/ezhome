//
//  ESCaseShareModel.m
//  Consumer
//
//  Created by jiang on 2017/8/21.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseShareModel.h"
#import "CoStringManager.h"

@implementation ESCaseShareModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.shareUrl          = [CoStringManager judgeNSString:dict forKey:@"shareUrl"];
        self.shareTitle          = [CoStringManager judgeNSString:dict forKey:@"shareTitle"];
        self.shareContent      = [CoStringManager judgeNSString:dict forKey:@"shareContent"];
        self.shareImg          = [CoStringManager judgeNSString:dict forKey:@"shareImg"];
        
    }
    return self;
}

+ (instancetype)objFromDict:(NSDictionary *)dict {
    return [[ESCaseShareModel alloc] initWithDict:dict];
}

@end
