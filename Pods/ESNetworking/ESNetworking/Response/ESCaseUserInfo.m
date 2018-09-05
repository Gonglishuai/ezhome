//
//  ESCaseUserInfo.m
//  AFNetworking
//
//  Created by xiefei on 27/7/18.
//

#import "ESCaseUserInfo.h"
#import "CoStringManager.h"

@implementation ESCaseUserInfo

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.design_id            = [CoStringManager judgeNSString:dict forKey:@"id"];
        self.name        = [CoStringManager judgeNSString:dict forKey:@"name"];
        self.avatarUrl      = [CoStringManager judgeNSString:dict forKey:@"avatarUrl"];
    }
    return self;
}

+ (instancetype)objFromDict: (NSDictionary *)dict {
    ESCaseUserInfo *caseDetail = [[ESCaseUserInfo alloc] initWithDict:dict];
    return caseDetail;
}
@end
