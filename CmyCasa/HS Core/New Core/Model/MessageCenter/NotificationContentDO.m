//
//  NotificationContentDO.m
//  Homestyler
//
//  Created by liuyufei on 5/3/18.
//

#import "NotificationContentDO.h"

@implementation NotificationContentDO

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"txt" : @"content"
       }];
    return entityMapping;
}

@end
