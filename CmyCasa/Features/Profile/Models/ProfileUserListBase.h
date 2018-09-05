//
//  ProfileUserListBase.h
//  Homestyler
//
//  Created by Eric Dong on 04/12/2018.
//

#ifndef ProfileUserListBase_h
#define ProfileUserListBase_h

#import <Foundation/Foundation.h>

typedef enum _ProfileUserListType {
    ProfileUserListTypeFollowing,
    ProfileUserListTypeFollowers,
    ProfileUserListTypeDesignLikes
} ProfileUserListType;

@interface ProfileUserListBase : NSObject
{
@protected
    ProfileUserListType _userListType;
    NSMutableArray * _users;
    NSUInteger _total;
}

@property (nonatomic, copy) NSString * userId;
@property (nonatomic, readonly) ProfileUserListType userListType;
@property (nonatomic, strong) NSArray * users;

- (NSString *)getDefaultTitle;
- (NSString *)getTitleWithNumber;
- (NSString *)getEmptyMessage;

- (NSString *)getGAScreenName;

- (BOOL)hasMoreData;
- (void)reloadWithCompletion:(void(^)(BOOL success))completion;
- (void)loadMoreWithCompletion:(void(^)(BOOL success))completion;

@end

#endif /* ProfileUserListBase_h */
