//
//  ProfileUserListViewCell.m
//  EZHome
//
//  Created by Eric Dong on 04/12/18.
//

#import "ProfileUserListViewCell.h"
#import "ProfileProtocols.h"

#import "HSFollowButton.h"

#import "UIImageView+LoadImage.h"
#import "UIImageView+ViewMasking.h"

#import "UIView+Border.h"

@interface ProfileUserListViewCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet HSFollowButton *followButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ProfileUserListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.userAvatar setMaskToCircleWithBorderWidth:1.0f andColor:[UIColor colorWithRed:232.0/255 green:232.0/255 blue:232.0/255 alpha:1.0]];
    [self resetData];
    self.userAvatar.image = [UIImage imageNamed:@"user_avatar"];

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnAvatar:)];
    tap.delegate = self;
    [self.userAvatar addGestureRecognizer:tap];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetData];
}

- (void)resetData {
    self.userName.text = @"";
    //self.userAvatar.image = nil;
    self.followButton.hidden = YES;
    self.followButton.isFollowing = NO;
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
}

- (void)setUserInfo:(FollowUserInfo *)userInfo {
    _userInfo = userInfo;
    self.userName.text = [userInfo getUserFullName];
    [self.userAvatar loadImageFromUrl:userInfo.photoUrl defaultImageName:@"user_avatar"];
    self.followButton.hidden = [[UserManager sharedInstance] isCurrentUser:self.userInfo.userId];
    self.followButton.isFollowed = userInfo.isFollowed;
}

#pragma mark - actions

- (void)tappedOnAvatar:(UITapGestureRecognizer *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userPressed:)]) {
        [self.delegate userPressed:self.userInfo];
    }
}

- (IBAction)followPressed:(UIButton *)sender {
    BOOL follow = !self.userInfo.isFollowed;

    __weak typeof(self) weakSelf = self;

    if (self.delegate && [self.delegate respondsToSelector:@selector(followUser:follow:preActionBlock:completionBlock:sender:)]) {
        [self.delegate followUser:self.userInfo
                           follow:follow
                   preActionBlock:^(NSString * _Nullable userId) {
                       if (weakSelf != nil && [weakSelf.userInfo.userId isEqualToString:userId]) {
                           // update follow button state
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (weakSelf == nil)
                                   return;

                               __strong typeof(self) strongSelf = weakSelf;
                               strongSelf.followButton.isFollowing = YES;
                               strongSelf.activityIndicator.hidden = NO;
                               [strongSelf.activityIndicator startAnimating];
                           });
                       }
                   }
                  completionBlock:^(NSString * _Nullable userId, BOOL success) {
                      if (weakSelf != nil && [weakSelf.userInfo.userId isEqualToString:userId]) {
                          // restore follow button state if failed
                          dispatch_async(dispatch_get_main_queue(), ^{
                              if (weakSelf == nil)
                                  return;

                              __strong typeof(self) strongSelf = weakSelf;
                              strongSelf.activityIndicator.hidden = YES;
                              [strongSelf.activityIndicator stopAnimating];
                              strongSelf.followButton.isFollowing = NO;
                              // Update it by reloadData
//                              if (success) {
//                                  strongSelf.followButton.isFollowed = strongSelf.userInfo.isFollowed;
//                              }
                          });
                      }
                  }
                           sender:sender];
    }
}

@end


////////////////////////////////////////////////////////////
@implementation ProfileUserListViewEmptyCell

@end
