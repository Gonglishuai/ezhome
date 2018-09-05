//
//  NotificationDetailDO.m
//  Homestyler
//
//  Created by liuyufei on 5/1/18.
//

#import "NotificationDetailDO.h"
#import "FollowUserInfo.h"
#import "NotificationDesignInfoDO.h"
#import "NotificationContentDO.h"

@implementation NotificationDetailDO

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"noticeType"  : @"noticeType",
       @"createTime" : @"createTime"
       }];

    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"noticeContent"
                                                 toKeyPath:@"noticeContent"
                                               withMapping:[NotificationContentDO jsonMapping]]];

    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"fromUserMini"
                                                 toKeyPath:@"fromUser"
                                               withMapping:[FollowUserInfo jsonMapping]]];

    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"designMini"
                                                 toKeyPath:@"designInfo"
                                               withMapping:[NotificationDesignInfoDO jsonMapping]]];
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"replyeeMini"
                                                 toKeyPath:@"replyeeInfo"
                                               withMapping:[FollowUserInfo jsonMapping]]];
    return entityMapping;
}

@end
