//
//  ProfileUserListFollowers.m
//  Homestyler
//
//  Created by Eric Dong on 04/12/2018.
//

#import "ProfileUserListFollowers.h"

#import "FlurryDefs.h"

#import "NSString+FormatNumber.h"

@implementation ProfileUserListFollowers

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _userListType = ProfileUserListTypeFollowers;
    }
    return self;
}

- (NSString *)getDefaultTitle {
    return NSLocalizedString(@"profile_tab_followers", @"Followers");
}

- (NSString *)getTitleWithNumber {
    return [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"profile_tab_followers", @"Followers"), [NSString formatNumber:_total]];
}

- (NSString *)getEmptyMessage {
    return NSLocalizedString(@"profile_no_followers", @"No followers yet");
}

- (NSString *)getGAScreenName {
    return GA_PROFILE_FOLLOWERS_SCREEN;
}

- (void)loadMoreFromOffset:(NSUInteger)offset withCompletion:(void(^)(BOOL success))completion {
    [[HomeManager sharedInstance]
     getFollowersForUser:self.userId
     offset:offset
     withCompletion:^(id serverResponse) {
         BOOL success = NO;
         if (serverResponse != nil) {
             FollowResponse* followResponse = (FollowResponse*)serverResponse;
             success = (followResponse.errorCode == -1);
             if (success) {
                 _total = followResponse.total.unsignedIntValue;
                 if (_users == nil) {
                     _users = [NSMutableArray arrayWithCapacity:0];
                 } else if (offset == 0) {
                     [_users removeAllObjects];
                 }
                 [_users addObjectsFromArray:followResponse.followList];
             } else {
             }
         }
         if (completion != nil) {
             completion(success);
         }
     }
     failureBlock:^(NSError *error) {
         if (completion != nil) {
             completion(NO);
         }
     }
     queue:nil // use main queue by default
     ];
}

@end
