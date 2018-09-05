//
//  ProfileCollectionViewCell_UserInfo.m
//  EZHome
//
//  Created by xiefei on 5/3/18.
//

#import "ProfileCollectionViewCell_UserInfo.h"

#import "ImageFetcher.h"

#import "HSFollowButton.h"

#import "FlurryDefs.h"

#import "NSString+Contains.h"
#import "NSString+FormatNumber.h"

#import "UIImageView+ViewMasking.h"
#import "UIImageView+LoadImage.h"
#import "UILabel+Size.h"
#import "UIView+Border.h"

static const CGFloat DEFAULT_USER_DESCRIPTION_HEIGHT = 22;

@interface ProfileCollectionViewCell_UserInfo()

@property (weak, nonatomic) IBOutlet UIImageView *userBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *userBadge;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userDescription;
@property (weak, nonatomic) IBOutlet UILabel *following;
@property (weak, nonatomic) IBOutlet UILabel *followers;
@property (weak, nonatomic) IBOutlet UILabel *likes;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (weak, nonatomic) IBOutlet HSFollowButton *followButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userNameHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userDescriptionHeightConstraint;

@end


@implementation ProfileCollectionViewCell_UserInfo

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.userAvatar setMaskToCircleWithBorderWidth:1.5f andColor:[UIColor whiteColor]];
    [self resetData];
    self.userAvatar.image = [UIImage imageNamed:@"user_avatar"];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetData];
}

- (void)resetData {
    self.userName.text = @"";
    self.userDescription.text = @"";
    //self.userAvatar.image = nil;
    self.userBadge.hidden = YES;

    self.following.text = @"0";
    self.followers.text = @"0";
    self.likes.text = @"0";

    self.editProfileButton.hidden = YES;
    self.followButton.hidden = YES;
    self.followButton.isFollowing = NO;
}

#pragma mark -Set Data-
-(void)setUserProfile:(UserProfile *)userProfile {
    _userProfile = userProfile;
    if (_userProfile == nil)
        return;

    self.editProfileButton.hidden = !self.userProfile.isCurrentUser;
    self.followButton.hidden = self.userProfile.isCurrentUser;
    if (!self.userProfile.isCurrentUser) {
        self.followButton.isFollowed = self.userProfile.isFollowed;
    }

    BOOL needsLayout = NO;

    NSString *userName = [userProfile getUserFullName];
    CGFloat height = [ProfileCollectionViewCell_UserInfo calcUserNameLabelHeightForUser:userProfile withCellWidth:self.frame.size.width];
    if (height > DEFAULT_USER_DESCRIPTION_HEIGHT) {
        self.userNameHeightConstraint.constant = height;
        needsLayout = YES;
    }
    self.userName.text = userName;

    NSString * userDesc = [userProfile.userDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([NSString isNullOrEmpty:userDesc]) {
        self.userDescriptionHeightConstraint.constant = 0;
        needsLayout = YES;
    } else {
        height = [ProfileCollectionViewCell_UserInfo calcUserDescriptionLabelHeightForUser:userProfile withCellWidth:self.frame.size.width];
        if (height > DEFAULT_USER_DESCRIPTION_HEIGHT) {
            self.userDescriptionHeightConstraint.constant = height;
            needsLayout = YES;
        } else if (self.userDescriptionHeightConstraint.constant != DEFAULT_USER_DESCRIPTION_HEIGHT) {
            self.userDescriptionHeightConstraint.constant = DEFAULT_USER_DESCRIPTION_HEIGHT;
            needsLayout = YES;
        }
        self.userDescription.text = userDesc;
    }

    if (![NSString isNullOrEmpty:userProfile.userTypeName] && [userProfile.userTypeName isEqualToString:@"Hero"]) {
        self.userBadge.image = [UIImage imageNamed:((IS_IPAD) ? @"herostyler_pad" : @"herostyler")];
        self.userBadge.hidden = NO;
    }

    [self updateLabel:self.following withCount:userProfile.following];
    [self updateLabel:self.followers withCount:userProfile.followers];
    [self updateLabel:self.likes withCount:userProfile.likes];

    [self getUserAvatar];

    if (needsLayout) {
        [self setNeedsLayout];
    }
}

- (void)updateLabel:(UILabel *)label withCount:(NSInteger)count {
    label.text = [NSString formatNumber:count];
}

- (void)getUserAvatar {
    NSString *url = self.userProfile.userPhoto;
    if ([NSString isNullOrEmpty:url])
        return;

    [self.userAvatar loadImageFromUrl:url defaultImageName:@"user_avatar"];
}

#pragma mark - public methods

+ (CGFloat)calcExtraUserInfoHeightForUser:(UserProfile *)userProfile withCellWidth:(CGFloat)cellWidth {
    if (IS_IPAD)
        return 0;

    CGFloat userNameHeight = [ProfileCollectionViewCell_UserInfo calcUserNameLabelHeightForUser:userProfile withCellWidth:cellWidth];
    CGFloat userDescriptionHeight = [ProfileCollectionViewCell_UserInfo calcUserDescriptionLabelHeightForUser:userProfile withCellWidth:cellWidth];
    return userNameHeight + userDescriptionHeight - DEFAULT_USER_DESCRIPTION_HEIGHT - DEFAULT_USER_DESCRIPTION_HEIGHT;
}

+ (CGFloat)calcUserNameLabelHeightForUser:(UserProfile *)userProfile withCellWidth:(CGFloat)cellWidth {
    NSString * userName = [userProfile getUserFullName];
    CGFloat userNameMaxWidth = [ProfileCollectionViewCell_UserInfo getUserNameLabelMaxWidthWithCellWidth:cellWidth];
    // NOTE: use the font with style settings for this label
    UIFont * font = [UIFont fontWithName:@".SFUIText-Semibold" size:17]; // Text_Heading1 in nss
    CGFloat height = [ProfileCollectionViewCell_UserInfo textBoundingHeight:userName withFont:font width:userNameMaxWidth];
    if (height > DEFAULT_USER_DESCRIPTION_HEIGHT)
        return height;

    return DEFAULT_USER_DESCRIPTION_HEIGHT;
}

+ (CGFloat)calcUserDescriptionLabelHeightForUser:(UserProfile *)userProfile withCellWidth:(CGFloat)cellWidth {
    NSString * userDesc = [userProfile.userDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([NSString isNullOrEmpty:userDesc])
        return 0;

    CGFloat userNameMaxWidth = [ProfileCollectionViewCell_UserInfo getUserDescriptionLabelMaxWidthWithCellWidth:cellWidth];
    // NOTE: use the font with style settings for this label
    UIFont * font = [UIFont systemFontOfSize:14]; // Text_Body3 in nss
    CGFloat height = [ProfileCollectionViewCell_UserInfo textBoundingHeight:userDesc withFont:font width:userNameMaxWidth];
    if (height > DEFAULT_USER_DESCRIPTION_HEIGHT)
        return height;

    return DEFAULT_USER_DESCRIPTION_HEIGHT;
}

+ (CGFloat)textBoundingHeight:(NSString *)text withFont:(UIFont *)font width:(CGFloat)width {

    if ([NSString isNullOrEmpty:text])
        return 0;

    CGSize maxSize = CGSizeMake(width, font.lineHeight * 999);
    CGRect textRect = [text boundingRectWithSize:maxSize
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil];

    return ceil(textRect.size.height);
}

+ (CGFloat)getUserNameLabelMaxWidthWithCellWidth:(CGFloat)cellWidth {
    // margins and spacings, should be consistent with storyboard
    CGFloat left = IS_IPAD ? 164 : 16;
    CGFloat right = IS_IPAD ? (88 + 20 + 32 + 50) : (93 + 15 + 44 + 4);
    return cellWidth - left - right;
}

+ (CGFloat)getUserDescriptionLabelMaxWidthWithCellWidth:(CGFloat)cellWidth {
    // margins and spacings, should be consistent with storyboard
    CGFloat left = IS_IPAD ? 164 : 16;
    CGFloat right = IS_IPAD ? 50 : 16;
    return cellWidth - left - right;
}

- (CGRect)getUserAvatarImageViewFrame {
    return self.userAvatar.frame;
}

- (CGRect)getFollowButtonFrame {
    return self.followButton.frame;
}

#pragma mark - Actions

- (IBAction)editProfilePressed:(UIButton *)sender {
    if (!self.userProfile.isCurrentUser) // should not occur
        return;

    if (self.delegate && [self.delegate respondsToSelector:@selector(editProfile) ]) {
        [self.delegate editProfile];
    }
}

- (IBAction)followingPressed:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showFollowing)]) {
        [self.delegate showFollowing];
    }
}

- (IBAction)followersPressed:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showFollowers)]) {
        [self.delegate showFollowers];
    }
}

- (IBAction)likesPressed:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showLikesToast)]) {
        [self.delegate showLikesToast];
    }
}

- (IBAction)followPressed:(UIButton *)sender {
    if (self.userProfile.isCurrentUser)
        return;

    BOOL follow = !self.userProfile.isFollowed;

    // create follow user info
    FollowUserInfo * followUserInfo = [FollowUserInfo new];
    followUserInfo.userId = self.userProfile.userId;
    followUserInfo.firstName = self.userProfile.firstName;
    followUserInfo.lastName = self.userProfile.lastName;
    followUserInfo.photoUrl = self.userProfile.userPhoto;
    followUserInfo.type = FollowUserTypeNormal;
    followUserInfo.isFollowed = follow;

    __weak typeof(self) weakSelf = self;

    if (self.delegate && [self.delegate respondsToSelector:@selector(followUser:follow:preActionBlock:completionBlock:sender:)]) {
        [self.delegate followUser:followUserInfo
                           follow:follow
                   preActionBlock:^(NSString * _Nullable userId) {
                       if (weakSelf != nil && [weakSelf.userProfile.userId isEqualToString:userId]) {
                           // update follow button state
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (weakSelf == nil)
                                   return;

                               __strong typeof(self) strongSelf = weakSelf;
                               strongSelf.followButton.isFollowing = YES;
                           });
                       }
                   }
                  completionBlock:^(NSString * _Nullable userId, BOOL success) {
                      if (weakSelf != nil && [weakSelf.userProfile.userId isEqualToString:userId]) {
                          // restore follow button state if failed
                          dispatch_async(dispatch_get_main_queue(), ^{
                              if (weakSelf == nil)
                                  return;

                              __strong typeof(self) strongSelf = weakSelf;
                              strongSelf.followButton.isFollowing = NO;
                              // Update it by reloadData
//                              if (success) {
//                                  strongSelf.followButton.isFollowed = strongSelf.userProfile.isFollowed;
//                                  [strongSelf updateLabel:strongSelf.followers withCount:strongSelf.userProfile.followers];
//                              }
                          });
                      }
                  }
                           sender:sender];
    }
}

@end

