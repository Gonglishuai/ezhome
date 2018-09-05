//
//  RoomTypeDO.m
//  Homestyler
//
//  Created by Ma'ayan on 11/27/13.
//
//

#import "RoomTypeDO.h"

@implementation RoomTypeDO

+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"id" : @"myId",
     @"d" :@"desc"
     }];
    
    return entityMapping;
}

@end
