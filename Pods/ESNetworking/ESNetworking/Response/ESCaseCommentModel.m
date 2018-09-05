//
//  ESCaseCommentModel.m
//  Consumer
//
//  Created by jiang on 2017/8/21.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseCommentModel.h"
#import "CoStringManager.h"

@implementation ESCaseCommentModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.commentId       = [CoStringManager judgeNSInteger:dict forKey:@"commentId"];
        self.resourceId   = [CoStringManager judgeNSInteger:dict forKey:@"resourceId"];
        self.resourceName = [CoStringManager judgeNSString:dict forKey:@"resourceName"];
        self.regionId     = [CoStringManager judgeNSString:dict forKey:@"regionId"];
        self.comment      = [CoStringManager judgeNSString:dict forKey:@"comment"];
        self.createTime   = [CoStringManager judgeNSString:dict forKey:@"createTime"];
        self.type         = [CoStringManager judgeNSInteger:dict forKey:@"type"];
        self.createId     = [CoStringManager judgeNSString:dict forKey:@"createId"];
        self.avatar       = [CoStringManager judgeNSString:dict forKey:@"avatar"];
        self.nickName     = [CoStringManager judgeNSString:dict forKey:@"nickName"];
        self.phone        = [CoStringManager judgeNSString:dict forKey:@"phone"];

        
    }
    return self;
}

+ (instancetype)objFromDict: (NSDictionary *)dict {
    ESCaseCommentModel *comment = [[ESCaseCommentModel alloc] initWithDict:dict];
    return comment;
}


@end
