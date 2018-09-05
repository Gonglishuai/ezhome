//
//  NotificationDesignInfoDO.m
//  Homestyler
//
//  Created by liuyufei on 5/1/18.
//

#import "NotificationDesignInfoDO.h"

@implementation NotificationDesignInfoDO

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"designId" : @"designId",
       @"designName" : @"designName",
       @"userId" : @"designUserId",
       @"resultImage" : @"resultImage",
       @"foldCount" : @"foldCount"
       }];
    return entityMapping;
}

@end
