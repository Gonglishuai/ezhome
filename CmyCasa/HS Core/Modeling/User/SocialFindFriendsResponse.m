//
//  SocialFindFriendsResponse.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/13/13.
//
//

#import "SocialFindFriendsResponse.h"
#import "SocialFriendDO.h"
@implementation SocialFindFriendsResponse

+ (RKObjectMapping*)jsonMapping{
    
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"regusr"
                                                 toKeyPath:@"users"
                                               withMapping:[SocialFriendDO jsonMapping]]];
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"unregusr"
                                                 toKeyPath:@"unknown"
                                               withMapping:[SocialFriendDO jsonMapping]]];
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"invusr"
                                                 toKeyPath:@"invited"
                                               withMapping:[SocialFriendDO jsonMapping]]];
    
    
    
    return entityMapping;
}
- (void)applyPostServerActions{
    [super applyPostServerActions];
    

   
}
@end
