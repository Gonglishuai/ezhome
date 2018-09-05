//
//  ActivityStreamDO.m
//  Homestyler
//
//  Created by Avihay Assouline on 12/23/13.
//
//

#import "ActivityStreamDO.h"

///////////////////////////////////////////////////////
//               IMPLEMENTATION                      //
///////////////////////////////////////////////////////

@implementation ActivityStreamDO

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"activityId"    : @"Id",
       @"activityType"  : @"activityName", // ActivityType is on purpose different than ActivityName as we convert afterwards to the respective enum
       @"ownerId"       : @"ownerID",
       @"ownerName"     : @"ownerName",
       @"ownerImage"    : @"ownerImageURL",
       @"actorId"       : @"actorID",
       @"actorName"     : @"actorName",
       @"actorImage"    : @"actorImageURL",
       @"assetId"       : @"assetID",
       @"assetImage"    : @"assetImageURL",
       @"assetTitle"    : @"assetTitle",
       @"assetText"     : @"assetText",
       @"heartCount"    : @"heartCount",
       @"commentCount"  : @"commentCount",
       @"timeStamp"     : @"timeStamp",
       @"lastRead"      : @"lastRead",
       @"assetType"     : @"assetTypeString"
       }];
    return entityMapping;
}

@end
