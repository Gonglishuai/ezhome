//
//  UserProfile.h
//  Homestyler
//
//  Created by Yiftach Ringel on 17/06/13.
//
//

#import "BaseResponse.h"

@class DesignMetadata;
@class MyDesignDO;
@class UserExtendedDetails;
@class UserDO;

@interface UserProfile : BaseResponse <NSCopying>

@property (nonatomic, strong) NSString* userId;

@property (nonatomic, strong) NSString* userPhoto;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* userDescription;
@property (nonatomic, strong) NSString* userTypeName;

@property (nonatomic)         NSInteger likes;
@property (nonatomic)         NSInteger followers;
@property (nonatomic)         NSInteger following;
@property (nonatomic)         NSInteger followedProfessionals;
@property (nonatomic)         NSInteger favoriteArticles;

@property (nonatomic)         BOOL isFollowed;

@property (nonatomic)         NSInteger publishedAssets;
@property (nonatomic, strong) NSMutableArray*  assets;

@property (nonatomic, strong) UserExtendedDetails * extendedDetails;

@property (nonatomic) BOOL isCurrentUser;

- (NSString *)getUserFullName;

-(void)updateDesignUids:(NSString*)userd;
-(UserDO*)generateUserDOFromProfile;
-(void)updateUserProfileAccoringToUpdatedUser:(UserDO*)updatedUser;
- (id)copyWithZone:(NSZone *)zone;

- (BOOL)updateMetadata:(DesignMetadata *)metadata forDesign:(NSString *)designId;
- (BOOL)updateDesignStatus:(DesignStatus)status forDesign:(NSString *)designId;
- (void)removeDesignById:(NSString *)designId;

- (MyDesignDO *)getDesignItemById:(NSString *)designId;

@end
