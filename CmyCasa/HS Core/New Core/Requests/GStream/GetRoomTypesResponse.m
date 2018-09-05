//
//  GetRoomTypesResponse.m
//  Homestyler
//
//  Created by Ma'ayan on 11/27/13.
//
//

#import "GetRoomTypesResponse.h"

#import "RoomTypeDO.h"

@interface GetRoomTypesResponse ()

@property (nonatomic, strong) NSArray *arrRoomTypes;

@end

@implementation GetRoomTypesResponse

+(void)initialize
{
    //[BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] actionGetRoomTypes] withMapping:[RoomTypeDO jsonMapping]];
}

+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping *entityMapping = [super jsonMapping];
    
    [entityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"lst" toKeyPath:@"arrRoomTypes" withMapping:[RoomTypeDO jsonMapping]]];
    
    return entityMapping;
}


- (NSArray *)roomTypes
{
    return [self.arrRoomTypes copy];
}


@end
