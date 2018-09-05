//
//  AddrBookFriendsResponse.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/13/13.
//
//

#import "AddrBookFriendsResponse.h"
#import "AddrBookFriendDO.h"
@implementation AddrBookFriendsResponse

+ (RKObjectMapping*)jsonMapping{
    
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    
    [entityMapping addPropertyMapping:
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
     
     
     
    return entityMapping;
}
- (void)applyPostServerActions{
    [super applyPostServerActions];
    
    
}
@end
