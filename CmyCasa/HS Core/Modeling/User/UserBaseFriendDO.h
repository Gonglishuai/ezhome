//
//  UserBaseFriendDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/6/13.
//
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>
#import "FollowUserInfo.h"
typedef enum FriendStatuses{
    
    kFriendNotHomestyler=1, //need to invite
    kFriendHSNotFollowing=2, //can follow
    kFriendHSFollowing=3, //can unfollow
    kFriendInvited=4, // invited
    kFriendUnknown=5, //not known yet
    
    
} FriendStatus;

typedef enum SocialFriendTypes{
    
    kSocialFriendNotSocial=0,
    kSocialFriendFacebook=1, 
    kSocialFriendGoogle=2, 
    kSocialFriendYahoo=3, 
    kSocialFriendTwitter=4, 
    kSocialFriendMicrosoft=5, 
    
    
} SocialFriendType;
@interface UserBaseFriendDO : BaseResponse


@property(nonatomic,strong) NSString * firstName;
@property(nonatomic,strong) NSString * lastName;
@property(nonatomic,strong) NSString * fullName;
@property(nonatomic,strong) NSString * picture;
@property(nonatomic,strong) NSString * email;
@property(nonatomic,strong) NSString * hashedEmail;
@property(nonatomic,strong) NSString * _id;
@property(nonatomic) SocialFriendType  socialFriendType;


@property(nonatomic) BOOL isFacebookFriend;
@property(nonatomic) BOOL isHSUser;
@property(nonatomic)FriendStatus currentStatus;

-(id)initWithFacebookDictionary:(NSDictionary*)dict;
-(BOOL)compareFriendToFollowingUser:(FollowUserInfo*)following;
-(UIImage*)getLocalImage;

-(NSString*)getFullName;

@end
