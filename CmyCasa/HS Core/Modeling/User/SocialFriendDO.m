//
//  SocialFriendDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/13/13.
//
//

#import "SocialFriendDO.h"

@implementation SocialFriendDO



+ (RKObjectMapping*)jsonMapping{
    
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"socialid" : @"socialId"
     }];
    
    
    
    return entityMapping;
}

- (void)applyPostServerActions{
    [super applyPostServerActions];
    self.socialFriendType=kSocialFriendFacebook;
    self.isFacebookFriend=YES;
}



@end
