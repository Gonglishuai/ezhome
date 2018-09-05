//
//  MessagesResponse.m
//  Homestyler
//
//  Created by liuyufei on 5/1/18.
//

#import "MessagesResponse.h"
#import "MessagesCountDO.h"
#import "NotificationDetailDO.h"

@implementation MessagesResponse

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping *entityMapping = [super jsonMapping];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"lastViewTime"  : @"lastViewTime"
       }];
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"countOfTypes" toKeyPath:@"countOfTypes" withMapping:[MessagesCountDO jsonMapping]]];
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"noticeList" toKeyPath:@"noticeList" withMapping:[NotificationDetailDO jsonMapping]]];
    return entityMapping;
}

@end
