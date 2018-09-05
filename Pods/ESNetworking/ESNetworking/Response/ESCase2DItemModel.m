//
//  ESCase2DItemModel.m
//  AFNetworking
//
//  Created by Admin on 2018/8/6.
//

#import "ESCase2DItemModel.h"
#import "CoStringManager.h"

@implementation ESCase2DItemModel
- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.link               = [CoStringManager judgeNSString:dict forKey:@"link"];
        self.isPrimary                 = [CoStringManager judgeBOOL:dict forKey:@"isPrimary"];
    }
    return self;
}

+ (instancetype)objFromDict: (NSDictionary *)dict {
    ESCase2DItemModel *caseDetail = [[ESCase2DItemModel alloc] initWithDict:dict];
    return caseDetail;
}
@end
