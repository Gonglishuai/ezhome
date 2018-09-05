//
//  MessagesCountDO.m
//  Homestyler
//
//  Created by liuyufei on 5/1/18.
//

#import "MessagesCountDO.h"

@implementation MessagesCountDO

+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];

    // Add assets mapping
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"follow" : @"followingCount",
       @"like" : @"likeCount",
       @"comment" : @"commentsCount",
       @"feature" : @"featuredCount",
       @"other" : @"otherCount",
       @"all" : @"allCount",
       }];
    return entityMapping;
}

@end
