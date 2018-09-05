//
//  FindFriendsResponse.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/6/13.
//
//

#import "FindFriendsResponse.h"
#import "AddrBookFriendDO.h"
@implementation FindFriendsResponse
-(id)init{
    self=[super init];
    self.users=[NSMutableArray arrayWithCapacity:0];
     self.invited=[NSMutableArray arrayWithCapacity:0];
    self.unknown=[NSMutableArray arrayWithCapacity:0];
    
    return self;
}

+ (RKObjectMapping*)jsonMapping{
      
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    
   /*[entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"regusr"
                                                 toKeyPath:@"users"
                                               withMapping:[AddrBookFriendDO jsonMapping]]];
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"unregusr"
                                                 toKeyPath:@"unknown"
                                               withMapping:[AddrBookFriendDO jsonMapping]]];
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"invusr"
                                                 toKeyPath:@"invited"
                                               withMapping:[AddrBookFriendDO jsonMapping]]];
    
 
    */
    return entityMapping;
}

- (void)applyPostServerActions{
   
    
    for (int i=0; i<[self.users count]; i++) {
        [[self.users objectAtIndex:i] setCurrentStatus:kFriendHSNotFollowing];
    }
    
    for (int i=0; i<[self.unknown count]; i++) {
        [[self.unknown objectAtIndex:i] setCurrentStatus:kFriendNotHomestyler];
    }
    
    for (int i=0; i<[self.invited count]; i++) {
        [[self.invited objectAtIndex:i] setCurrentStatus:kFriendInvited];
    }
    
    
    [self.users makeObjectsPerformSelector:@selector(applyPostServerActions)];
    [self.unknown makeObjectsPerformSelector:@selector(applyPostServerActions)];
    [self.invited makeObjectsPerformSelector:@selector(applyPostServerActions)];
    
    
}



@end
