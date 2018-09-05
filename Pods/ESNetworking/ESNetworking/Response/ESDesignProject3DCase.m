//
//  ESDesignProject3DCase.m
//  Consumer
//
//  Created by 焦旭 on 2017/8/8.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESDesignProject3DCase.h"
#import "CoStringManager.h"

@implementation ESDesignProject3DCase

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.designAssetId = [CoStringManager judgeNSString:dict forKey:@"designAssetId"];
        self.designName     = [CoStringManager judgeNSString:dict forKey:@"designName"];
        self.mainImageUrl  = [CoStringManager judgeNSString:dict forKey:@"mainImageUrl"];
        if (dict[@"isNew"]
            && ![dict[@"isNew"] isKindOfClass:[NSNull class]])
        {
            self.isNew = [[NSString stringWithFormat:@"%@", dict[@"isNew"]] boolValue];
        }
    }
    return self;
}

+ (instancetype)objFromDict:(NSDictionary *)dict {
    return [[ESDesignProject3DCase alloc] initWithDict:dict];
}
@end
