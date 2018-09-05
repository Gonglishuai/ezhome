//
//  UserProfile.m
//  Homestyler
//
//  Created by Yiftach Ringel on 17/06/13.
//
//

#import "UserProfile.h"
#import "UserExtendedDetails.h"
#import "UserDO.h"

#import "NSString+Contains.h"

@implementation UserProfile

+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    // Add most of the mapping
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"likes" : @"likes",
     @"followerCount" : @"followers",
     @"followingCount" : @"following",
     @"favArticles" : @"favoriteArticles",
     @"followingProfCount" : @"followedProfessionals",
     @"publishedAssetsCounts" : @"publishedAssets",
     @"isFollowed" : @"isFollowed",
     @"userDescription" : @"userDescription",
     @"userTypeName" : @"userTypeName",
     @"userPhoto" : @"userPhoto",
     @"userFirstName" : @"firstName",
     @"userLastName" : @"lastName"
     }];
    
    // Add assets mapping
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"assets"
                                                 toKeyPath:@"assets"
                                               withMapping:[MyDesignDO jsonMapping]]];
     
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"rData"
                                                 toKeyPath:@"extendedDetails"
                                               withMapping:[UserExtendedDetails jsonMapping]]];
    
    return entityMapping;
}

- (NSString *)getUserFullName {
    if ([NSString isNullOrEmpty:self.firstName])
        return self.lastName;

    if ([NSString isNullOrEmpty:self.lastName])
        return self.firstName;

    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

-(void)applyPostServerActions
{
    NSString* author = [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    
    // Apply post server actions on assets
    for (MyDesignDO* asset in self.assets) {
        [asset applyPostServerActions];
        asset.author = author;
        asset.uthumb = self.userPhoto;
  
    }
}

-(void)updateDesignUids:(NSString*)userd{
    if (userd==nil) {
        return;
    }
    self.userId=userd;
    for (MyDesignDO* asset in self.assets) {
        asset.uid=self.userId;
    }
    
}
-(void)updateUserProfileAccoringToUpdatedUser:(UserDO*)updatedUser{
    if (updatedUser.firstName) {
        self.firstName=[updatedUser.firstName copy];
    }
    
    if (updatedUser.lastName) {
        self.lastName=[updatedUser.lastName copy];
    }
    if (updatedUser.userProfileImage) {
        self.userPhoto=[updatedUser.userProfileImage copy];
    }
    
    if (updatedUser.userDescription) {
        self.userDescription=[updatedUser.userDescription copy];
    }

    if (updatedUser.extendedDetails) {
        [self.extendedDetails updateLocalUserDataAfterMetaUpdate:updatedUser.extendedDetails];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    UserProfile *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.userPhoto = [self.userPhoto copy];
        copy.firstName = [self.firstName copy];
        copy.lastName = [self.lastName copy];
        copy.userDescription = [self.userDescription copy];
        copy.likes = self.likes;
        copy.followers = self.followers;
        copy.following = self.following;
        copy.publishedAssets = self.publishedAssets;
        copy.assets = [self.assets copy];
        copy.userId = [self.userId copy];
        copy.extendedDetails = [self.extendedDetails copy];
    }

    return copy;
}

-(UserDO*)generateUserDOFromProfile{
    
    UserDO * user=[UserDO new];

    user.firstName=[self.firstName copy];
    user.extendedDetails=[self.extendedDetails copy];
    user.lastName=[self.lastName copy];
    user.userDescription= [self.userDescription copy];
    user.userProfileImage=[self.userPhoto copy];
    user.userID=[self.userId copy];

    return  user;
}

- (BOOL)updateMetadata:(DesignMetadata *)metadata forDesign:(NSString *)designId {
    if (metadata == nil)
        return NO;

    MyDesignDO * designItem = [self getDesignItemById:metadata.designId];
    if (designItem == nil)
        return NO;

    designItem.title = metadata.designTitle;
    designItem._description = metadata.designDescription;

    return YES;
}

- (BOOL)updateDesignStatus:(DesignStatus)status forDesign:(NSString *)designId {
    MyDesignDO * designItem = [self getDesignItemById:designId];
    if (designItem == nil)
        return NO;

    designItem.publishStatus = status;
    return YES;
}

- (void)removeDesignById:(NSString *)designId {
    if (self.assets == nil || self.assets.count == 0)
        return;

    for (NSInteger i = 0; i < self.assets.count; ++i) {
        MyDesignDO * item = [self.assets objectAtIndex:i];
        if ([item._id isEqualToString:designId]) {
            self.likes -= item.tempLikeCount.integerValue;
            if (self.likes < 0)
                self.likes = 0;
            [self.assets removeObjectAtIndex:i];
            return;
        }
    }
}

- (MyDesignDO *)getDesignItemById:(NSString *)designId {
    if (self.assets == nil || self.assets.count == 0)
        return nil;

    for (MyDesignDO * item in self.assets) {
        if ([item._id isEqualToString:designId])
            return item;
    }

    return nil;
}

@end
