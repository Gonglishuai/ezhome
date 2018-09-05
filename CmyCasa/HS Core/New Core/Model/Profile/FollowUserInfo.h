//
//  FollowUserInfo.h
//  Homestyler
//
//  Created by Yiftach Ringel on 20/06/13.
//
//

#import "BaseResponse.h"

typedef enum {
    FollowUserTypeNormal = 1,
    FollowUserTypProfessional = 2,
} FollowUserTypes;

@interface FollowResponse : BaseResponse

@property (nonatomic) NSNumber * total;
@property (strong, nonatomic) NSArray* followList;

@end

@interface FollowUserInfo : NSObject <RestkitObjectProtocol>

@property (strong, nonatomic) NSString* userId;
@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSString* userDescription;
@property (strong, nonatomic) NSString* userTypeName;
@property (strong, nonatomic) NSString* photoUrl;
@property (nonatomic) BOOL isFollowed;

@property (strong, nonatomic) NSString * email;

@property (nonatomic) FollowUserTypes type;

- (void)createSeparateNamesFromFullName:(NSString *)name;
- (NSString*)getUserFullName;
@end
