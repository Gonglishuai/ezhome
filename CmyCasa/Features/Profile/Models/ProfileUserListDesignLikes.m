//
//  ProfileUserListDesignLikes.m
//  Homestyler
//
//  Created by Eric Dong on 04/12/2018.
//

#import "ProfileUserListDesignLikes.h"
#import "DesignsManager.h"
#import "NSString+FormatNumber.h"

#import "FlurryDefs.h"

@implementation ProfileUserListDesignLikes

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _userListType = ProfileUserListTypeDesignLikes;
    }
    return self;
}

- (NSString *)getDefaultTitle {
    return NSLocalizedString(@"likes", @"Likes");
}

- (NSString *)getTitleWithNumber {
    return [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"likes", @"Likes"), [NSString formatNumber:_total]];
}

- (NSString *)getEmptyMessage {
    return NSLocalizedString(@"profile_no_likes", @"No likes yet");
}

- (NSString *)getGAScreenName {
    return GA_PROFILE_DESIGN_LIKES_SCREEN;
}

- (void)loadMoreFromOffset:(NSUInteger)offset withCompletion:(void(^)(BOOL success))completion {
    [[DesignsManager sharedInstance] getDesignLikes:self.assetId
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
