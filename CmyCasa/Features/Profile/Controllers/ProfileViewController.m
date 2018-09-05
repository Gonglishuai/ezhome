//
//  ProfileViewController.m
//  EZHome
//
//  Created by Eric Dong on 03/27/18.
//

#import "ProfileViewController.h"

#import "HSCollectionViewWaterfallLayout.h"

#import "ProfileCollectionViewHeader.h"
#import "ProfileCollectionViewCell_UserInfo.h"
#import "ProfileCollectionViewCell_DesignBig.h"
#import "ProfileCollectionViewCell_DesignSmall.h"

#import "GalleryStreamEmptyCell.h"

#import "ProfileUserDetailsBaseViewController.h"

#import "MessagesViewController.h"
#import "ProfileUserListViewController.h"
#import "MyDesignEditBaseViewController.h"
#import "ProfileLikesToastViewController.h"
#import "ProgressPopupViewController.h"

#import "BubbleEffectView.h"
#import "DesignItemLikeActionHelper.h"
#import "DesignItemShareActionHelper.h"
#import "NotificationsActionHelper.h"

#import "AppCore.h"
#import "ControllersFactory.h"
#import "DesignsManager.h"
#import "MessagesManager.h"
#import "UIManager.h"

#import "UserExtendedDetails.h"
#import "UserLikesDO.h"
#import "ProfileUserListFollowers.h"
#import "ProfileUserListFollowing.h"

#import "OtherUserRO.h"
#import "UserRO.h"

#import "NotificationNames.h"

#import "ServerUtils.h"

#import "HSFollowButton.h"

//#import "HSFlurry.h"

#import "UIImageView+LoadImage.h"
#import "UIImageView+ViewMasking.h"
#import "UILabel+Size.h"
#import "NSObject+Flurry.h"
#import "NSString+Contains.h"
#import "UIViewController+Helpers.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

static const CGFloat DESIGN_IMAGE_ASPECT = 9.0 / 16;

@interface ProfileViewController () <HSCollectionViewDelegateWaterfallLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, HSSharingViewControllerDelegate, MessagesViewControllerDelegate>

@property (strong, nonatomic) UIImage *backButtonImage;
@property (strong, nonatomic) UIImage *whiteBackButtonImage;
@property (strong, nonatomic) UIImage *settingsButtonImage;
@property (strong, nonatomic) UIImage *whiteSettingsButtonImage;

@property (nonatomic, strong) UIImage *notificationsImg;
@property (nonatomic, strong) UIImage *whiteNotificationsImg;
@property (nonatomic, strong) UIImage *notificationsNewImg;
@property (nonatomic, strong) UIImage *whiteNotificationsNewImg;

@property (nonatomic, weak) ProfileCollectionViewCell_UserInfo * profileUserInfoCell;
@property (nonatomic, weak) ProfileUserDetailsBaseViewController * profileEditUserDetailsVC;
@property (nonatomic, weak) MyDesignEditBaseViewController * myDesignEditViewController;
@property (nonatomic, weak) ProfileLikesToastViewController * likesToastVC;

@property (nonatomic, strong) DesignItemLikeActionHelper* likeActionHelper;
@property (nonatomic, strong) DesignItemShareActionHelper* shareActionHelper;
@property (nonatomic, strong) NotificationsActionHelper *notificationsActionHelper;

@property (nonatomic, strong) UIPopoverController* imageGalleryPopover;

@property (nonatomic) BOOL shouldAlertCloseScreen;
@property (nonatomic) BOOL didTrySilentLogin;

@property (weak, nonatomic) IBOutlet UIView *topBarContainer;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIImageView *topBarUserAvatar;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *notificationsButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@property (weak, nonatomic) IBOutlet HSFollowButton *topBarFollowButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *topBarActivityIndicator;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HSCollectionViewWaterfallLayout *collectionViewLayout;

@end

@implementation ProfileViewController
{
    BOOL _topBarIconMode;
}

#pragma mark - Overrides
- (void)viewDidLoad {
    [super viewDidLoad];

//    self.screenName = GA_PROFILE_SCREEN;

    self.shouldAlertCloseScreen = NO;

    _topBarIconMode = NO;

    self.backButtonImage = [self.backButton imageForState:UIControlStateNormal];
    self.whiteBackButtonImage = [self.backButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.backButton setImage:self.whiteBackButtonImage forState:UIControlStateNormal];
    self.backButton.tintColor = [UIColor whiteColor];

    self.settingsButtonImage = [self.settingsButton imageForState:UIControlStateNormal];
    self.whiteSettingsButtonImage = [self.settingsButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.settingsButton setImage:self.whiteSettingsButtonImage forState:UIControlStateNormal];
    self.settingsButton.tintColor = [UIColor whiteColor];

    self.notificationsImg = [UIImage imageNamed:@"notification"];
    self.notificationsNewImg = [UIImage imageNamed:@"notification_withdot"];
    self.whiteNotificationsImg = [UIImage imageNamed:@"white_notification"];
    self.whiteNotificationsNewImg = [UIImage imageNamed:@"white_notification_withdot"];

    if ([[MessagesManager sharedInstance] hasNewMessages])
    {
        [self.notificationsButton setImage:self.whiteNotificationsNewImg forState:UIControlStateNormal];
    }

    [self.topBarUserAvatar setMaskToCircleWithBorderWidth:1.5f andColor:[UIColor colorWithRed:232.0/255 green:232.0/255 blue:232.0/255 alpha:1.0]];
    self.topBarUserAvatar.image = [UIImage imageNamed:@"user_avatar"];

    self.collectionViewLayout = (HSCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    self.collectionViewLayout.delegate = self;

    self.collectionViewLayout.sectionHeadersPinToVisibleBounds = YES;

    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior  = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionViewFakeHeaderFooter"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CollectionViewFakeHeaderFooter"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ProfileDesignItemCell" bundle:nil] forCellWithReuseIdentifier:@"ProfileDesignItemCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GalleryStreamEmptyCell" bundle:nil] forCellWithReuseIdentifier:@"GalleryStreamEmptyCellID"];

    if (self.isCurrentUserProfile) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:kNotificationUserDidLogout object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showNotificationsInfoMini:)
                                                     name:@"getAllUserMessages"
                                                   object:nil];
    }

    //refresh content after sync
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUserProfileAccordingToUserID) name:@"DesignManagerSyncCycleComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserFollowingStatus:) name:kNotificationUserFollowingStatusChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAssetLikeStatus:) name:kNotificationAssetLikeStatusChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCommentFinishedNotification:) name:kNotificationAddCommentFinished object:nil];

    self.currentMode = BigMode;

    [self initDisplay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateNotificationsButtonImg];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _topBarIconMode ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

- (void)dealloc {
    NSLog(@"dealloc - ProfileViewController");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)userDidLogout {
    if (self.isCurrentUserProfile) {
        [[[UIManager sharedInstance] pushDelegate].navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)setUserId:(NSString *)userId {
    _userId = userId;

    self.isCurrentUserProfile = [[UserManager sharedInstance] isCurrentUser:userId];

    if (self.isCurrentUserProfile) {
//        [HSFlurry logAnalyticEvent:EVENT_NAME_MY_PROFILE_VISITED];
    } else {
        NSString * visitorId = [[UserManager sharedInstance] getLoggedInUserId];
//        [HSFlurry logAnalyticEvent:EVENT_NAME_PROFILE_VISITED
//                    withParameters:@{EVENT_PARAM_PROFILE_VISIT_ID:(userId)?userId:@"",
//                                     EVENT_PARAM_PROFILE_VISITOR_ID:(visitorId)?userId:@""}];
    }
}

- (void)setUserProfile:(UserProfile *)userProfile {
    _userProfile = userProfile;
    _userProfile.isCurrentUser = self.isCurrentUserProfile;
    //self.userProfile.isFollowed = [[HomeManager sharedInstance] isFollowingUser:[self getUserIDForCurrentProfile]];

    if (self.isCurrentUserProfile)
    {
        [self receiveNotificationsInfo];
    }

    [[ProgressPopupBaseViewController sharedInstance] stopLoading];

    [self updateDisplay];
}

- (void)showNotificationsInfoMini:(NSNotification *)notification
{
    [self updateNotificationsButtonImg];
    NSArray *notificationsLsit = notification.userInfo[@"messages"];
    [self.notificationsActionHelper showBubbleView:BubbleView_Profile withSourceView:self.notificationsButton withNotificationsInfo:notificationsLsit fromViewController:self];
}

- (void)loadUserProfileAccordingToUserID {
    if ([ConfigManager showMessageIfDisconnectedWithDelegate:self]) {
        self.shouldAlertCloseScreen = YES;
        return;
    }

    // Blocks
    ROCompletionBlock completionBlock = ^(id serverResponse)
    {
        UserProfile* profile = serverResponse;

        dispatch_async(dispatch_get_main_queue(), ^{
            [[ProgressPopupBaseViewController sharedInstance] stopLoading];

            // Profile loaded
            if (profile && profile.errorCode < 0) {
                [profile updateDesignUids:self.userId];

                if ([profile.userPhoto rangeOfString:@"graph.facebook.com/"].location!=NSNotFound &&
                    [profile.userPhoto rangeOfString:@"?type=large"].location==NSNotFound) {
                    profile.userPhoto=[NSString stringWithFormat:@"%@?type=large",profile.userPhoto];
                }

                self.userProfile = profile;
            } else {
                // Profile wasn't loaded
                if (self.isCurrentUserProfile && !self.didTrySilentLogin) {
                    self.didTrySilentLogin = YES;
                    [self silentLoginTry];
                } else {
                    [self showErrorWithMessage:NSLocalizedString(@"err_msg_profile_loading_other",@"An error occured while trying to load the profile")];
                    self.shouldAlertCloseScreen = YES;
                }
            }
        });
    };

    ROFailureBlock failureBlock = ^(NSError* error) {
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];

        if (self.isCurrentUserProfile) {
            [[AppCore sharedInstance] logoutUser];
        }
        [self showErrorWithMessage:NSLocalizedString(@"err_msg_profile_loading",@"An error occured while trying to load the profile")];
        self.shouldAlertCloseScreen = YES;
    };

    ROFailureBlock failureBlock2 = ^(NSError* error) {
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];

        if (self.isCurrentUserProfile) {
            [[AppCore sharedInstance] logoutUser];
        }
        [self showErrorWithMessage:NSLocalizedString(@"err_msg_profile_loading_other",@"An error occured while trying to load the profile")];
        self.shouldAlertCloseScreen = YES;
    };

    // Send my profile / public profile request
    if (self.isCurrentUserProfile) {
        [[HomeManager sharedInstance] getMyProfile:completionBlock
                                      failureBlock:failureBlock];
    } else {
        [[OtherUserRO new] getUserProfileById:self.userId
                              completionBlock:completionBlock
                                 failureBlock:failureBlock2 queue:dispatch_get_main_queue()];
    }
}

- (void)silentLoginTry {
    [[UserManager sharedInstance] userSilentLoginWithCompletionBlock:^(id serverResponse, id error) {

        BaseResponse * response=(BaseResponse*)serverResponse;
        if (error == nil && response != nil && response.errorCode == -1) {
            [self loadUserProfileAccordingToUserID];
        } else {
            [self showErrorWithMessage:NSLocalizedString(@"err_msg_profile_loading",@"An error occured while trying to load the profile")];
            self.shouldAlertCloseScreen = YES;
        }

    } queue:dispatch_get_main_queue()];
}

- (void)updateDisplay {
    self.settingsButton.hidden = !self.isCurrentUserProfile;
    self.notificationsButton.hidden = !self.isCurrentUserProfile;
    [self refreshCollectionView];
}

- (void)refreshCollectionViewOnMainThread {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshCollectionView];
    });
}

- (void)refreshCollectionView {
    self.collectionViewLayout.extraHeaderPinMarginTop = CGRectGetMaxY(self.topBarContainer.frame);

    NSString *url = _userProfile.userPhoto;
    if (![NSString isNullOrEmpty:url]) {
        [self.topBarUserAvatar loadImageFromUrl:url defaultImageName:@"user_avatar"];
    }

    [self.collectionView reloadData];
}

- (void)initDisplay {
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
    [self loadUserProfileAccordingToUserID];
    [self scrollToTopPressed:nil];
}

- (void)refreshFollowButtonStatus {
    if (self.collectionView == nil || self.profileUserInfoCell == nil)
        return;

    BOOL shouldHideFollowButton = [self shouldHideFollowButton];

    self.topBarFollowButton.hidden = shouldHideFollowButton;

    if (!self.userProfile.isCurrentUser) {
        self.topBarFollowButton.isFollowed = self.userProfile.isFollowed;
    }
}

- (void)receiveNotificationsInfo
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"getAllUserMessages"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showNotificationsInfoMini:)
                                                 name:@"getAllUserMessages"
                                               object:nil];
}

- (void)updateNotificationsButtonImg
{
    if (![[MessagesManager sharedInstance] hasNewMessages])
    {
        [self.notificationsButton setImage:(_topBarIconMode ? self.notificationsImg : self.whiteNotificationsImg) forState:UIControlStateNormal];
        return;
    }

    [self.notificationsButton setImage:(_topBarIconMode ? self.notificationsNewImg : self.whiteNotificationsNewImg) forState:UIControlStateNormal];
}

- (NotificationsActionHelper *)notificationsActionHelper
{
    if (_notificationsActionHelper == nil)
    {
        _notificationsActionHelper = [NotificationsActionHelper new];
    }
    return _notificationsActionHelper;
}

#pragma mark - MessagesViewControllerDelegate
- (void)popoverViewDidDismiss
{
    [self receiveNotificationsInfo];
}

#pragma mark - notifications
- (void)updateUserFollowingStatus:(NSNotification *)notification {
    NSString * userId = [[notification userInfo] objectForKey:kNotificationKeyUserId];

    BOOL isFollowed = NO;
    [[[notification userInfo] objectForKey:@"isFollowed"] getValue:&isFollowed];

    if (self.isCurrentUserProfile) {
        // update my following count
        self.userProfile.following += (isFollowed ? 1 : -1);
        if (self.userProfile.following < 0) {
            self.userProfile.following = 0;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshUserInfo];
        });
        return;
    }

    // update following status for target user
    if (![self.userProfile.userId isEqualToString:userId])
        return;

    self.userProfile.isFollowed = isFollowed;
    self.userProfile.followers += (isFollowed ? 1 : -1);
    if (self.userProfile.followers < 0) {
        self.userProfile.followers = 0;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshUserInfo];
    });
}

- (void)refreshUserInfo {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
}

- (void)updateAssetLikeStatus:(NSNotification *)notification {
    NSString * itemId = [[notification userInfo] objectForKey:kNotificationKeyItemId];
    DesignBaseClass *designItem = [self getDesignItemById:itemId];
    if (designItem == nil)
        return;

    BOOL isLiked = NO;
    [[[notification userInfo] objectForKey:@"isLiked"] getValue:&isLiked];

    NSInteger count = designItem.tempLikeCount.integerValue;
    count += (isLiked ? 1 : -1);
    if (count < 0) {
        count = 0;
    }
    designItem.tempLikeCount = [NSNumber numberWithInteger:count];

    if ([self.userProfile.userId isEqualToString:designItem.uid]) {
        self.userProfile.likes += (isLiked ? 1 : -1);
        if (self.userProfile.likes < 0) {
            self.userProfile.likes = 0;
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[ProfileCollectionViewCell_DesignBig class]])
            {
                ProfileCollectionViewCell_DesignBig *cell =  (ProfileCollectionViewCell_DesignBig *)obj;
                if ([cell.designModel._id isEqualToString:itemId])
                {
                    [cell updateLikeStatus];
                    *stop = YES;
                }
            }
        }];
    });
}

- (void)addCommentFinishedNotification:(NSNotification *)notification {
    NSString * itemId = [notification.userInfo objectForKey:kNotificationKeyItemId];
    DesignBaseClass *designItem = [self getDesignItemById:itemId];
    if (designItem == nil)
        return;

    DesignBaseClass *commentDesignItem = [notification.userInfo objectForKey:@"designItem"];
    if (commentDesignItem != designItem) {
        designItem.commentsCount = [NSNumber numberWithUnsignedInteger:designItem.commentsCount.integerValue + 1];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[ProfileCollectionViewCell_DesignBig class]])
            {
                ProfileCollectionViewCell_DesignBig *cell =  (ProfileCollectionViewCell_DesignBig *)obj;
                if ([cell.designModel._id isEqualToString:itemId])
                {
                    [cell updateCommentsCount];
                    *stop = YES;
                }
            }
        }];
    });
}

- (void)refreshCellByItemId:(NSString *)itemId {
    if (IS_IPHONE && self.currentMode == SmallMode)
        return;

    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ProfileCollectionViewCell_DesignBig class]])
        {
            ProfileCollectionViewCell_DesignBig *cell =  (ProfileCollectionViewCell_DesignBig *)obj;
            if ([cell.designModel._id isEqualToString:itemId])
            {
                [cell refreshUI];
                *stop = YES;
            }
        }
    }];
}

- (DesignBaseClass *)getDesignItemById:(NSString *)designId {
    for (NSInteger i = 0; i < self.userProfile.assets.count; i++) {
        DesignBaseClass * designItem = [self.userProfile.assets objectAtIndex:i];
        if ([designItem._id isEqualToString:designId])
            return designItem;
    }
    return nil;
}

#pragma mark - MyDesignEditDelegate
- (void)designUpdated:(DesignMetadata *)metadata {
    if (metadata == nil) {
        [self refreshCollectionViewOnMainThread];
        return;
    }

    if (metadata.textChanged) {
        [self.userProfile updateMetadata:metadata forDesign:metadata.designId];
    }

    // might need to resize design info cell due to the update of design tile and/or description
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshCollectionView];
    });
}

- (void)designDuplicated:(NSString *)designId {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initDisplay];
    });
}

- (void)designDeleted:(NSString *)designId {
    [self.userProfile removeDesignById:designId];
    [self refreshCollectionViewOnMainThread];
}

- (void)designPublishStateChanged:(NSString *)designId status:(DesignStatus)status {
    [self.userProfile updateDesignStatus:status forDesign:designId];
    [self refreshCollectionViewOnMainThread];
}

- (void)redesign:(DesignBaseClass *)designInfo {
    [self designPressed:designInfo];
}

#pragma mark - ProfileCollectionViewHeaderDelegate
- (void)setViewDisplayMode:(ProfileViewDisplayMode)mode {
    self.currentMode = mode;
    [self refreshCollectionView];
}

- (void)setViewDataType:(ProfileViewDataType)type {
    self.currentType = type;
    [self refreshCollectionView];
}

#pragma mark - UICollectionViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.profileUserInfoCell == nil)
        return;

    CGFloat yoffset = scrollView.contentOffset.y;

    CGRect avatarFrame = [self.profileUserInfoCell getUserAvatarImageViewFrame];
    CGFloat avatarTop = CGRectGetMinY(avatarFrame);
    CGFloat avatarBottom = CGRectGetMaxY(avatarFrame);
    CGFloat topBarBottom = CGRectGetMaxY(self.topBarContainer.frame);
    CGFloat offset = yoffset + topBarBottom;

    UIColor * topBarBgColor = nil;
    BOOL topBarIconMode = NO;
    if (offset > avatarBottom) {
        topBarIconMode = YES;
        topBarBgColor = [UIColor whiteColor];
    } else {
        topBarIconMode = NO;
        if (offset > avatarTop) {
            CGFloat ratio = (offset - avatarTop) / self.topBarContainer.frame.size.height;
            topBarBgColor = [UIColor colorWithWhite:1.0 alpha:ratio];
        } else {
            topBarBgColor = [UIColor clearColor];
        }
    }

    self.topBarContainer.backgroundColor = topBarBgColor;

    BOOL hasNotifications = [[MessagesManager sharedInstance] hasNewMessages];

    if (topBarIconMode != _topBarIconMode) {
        _topBarIconMode = topBarIconMode;
        [self setNeedsStatusBarAppearanceUpdate];
        if (_topBarIconMode) {
            [self.backButton setImage:self.backButtonImage forState:UIControlStateNormal];
            [self.settingsButton setImage:self.settingsButtonImage forState:UIControlStateNormal];
            [self.notificationsButton setImage:(hasNotifications ? self.notificationsNewImg : self.notificationsImg) forState:UIControlStateNormal];
            // show top bar user avatar
        } else {
            [self.backButton setImage:self.whiteBackButtonImage forState:UIControlStateNormal];
            [self.settingsButton setImage:self.whiteSettingsButtonImage forState:UIControlStateNormal];
            [self.notificationsButton setImage:(hasNotifications ? self.whiteNotificationsNewImg : self.whiteNotificationsImg) forState:UIControlStateNormal];
            // hide top bar user avatar
        }

        if (self.topBarUserAvatar.hidden == _topBarIconMode) {
            if (_topBarIconMode) {
                [UIView transitionWithView:self.topBarUserAvatar
                                  duration:0.4
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    self.topBarUserAvatar.hidden = NO;
                                }
                                completion:NULL];
            } else {
                self.topBarUserAvatar.hidden = YES;
            }
        }
    }

    if (!self.isCurrentUserProfile) {
        // show top bar follow button
        BOOL shouldHideFollowButton = [self shouldHideFollowButton];

        if (self.topBarFollowButton.hidden != shouldHideFollowButton) {
            if (shouldHideFollowButton) {
                self.topBarFollowButton.hidden = YES;
            } else {
                [self buttonFadeInAnimation:self.topBarFollowButton];
            }
        }

        [self updateTopBarActivityIndicatorFrame];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 1)
        return;

    if (self.userProfile.assets.count == 0)
        return;

    MyDesignDO *item = self.userProfile.assets[indexPath.row];
    [self designPressed:item];
}

- (BOOL)shouldHideFollowButton {
    if (self.isCurrentUserProfile)
        return YES;

    CGFloat yoffset = self.collectionView.contentOffset.y;
    CGFloat topBarBottom = CGRectGetMaxY(self.topBarContainer.frame);
    return (yoffset + topBarBottom <= self.profileUserInfoCell.frame.size.height);
}

- (void)updateTopBarActivityIndicatorFrame {
    BOOL shouldHideFollowButton = [self shouldHideFollowButton];

    CGRect followButtonFrame = CGRectZero;
    if (shouldHideFollowButton) {
        followButtonFrame = [self.profileUserInfoCell getFollowButtonFrame];
        followButtonFrame = [self.view convertRect:followButtonFrame fromView:self.profileUserInfoCell];
    } else {
        followButtonFrame = self.topBarFollowButton.frame;
        followButtonFrame = [self.view convertRect:followButtonFrame fromView:self.topBar];
    }
    CGRect activityIndicatorFrame = self.topBarActivityIndicator.frame;
    activityIndicatorFrame = CGRectMake(followButtonFrame.origin.x + (followButtonFrame.size.width - activityIndicatorFrame.size.width) * 0.5, followButtonFrame.origin.y + (followButtonFrame.size.height - activityIndicatorFrame.size.height) * 0.5, activityIndicatorFrame.size.width, activityIndicatorFrame.size.height);
    [self.topBarActivityIndicator setFrame:activityIndicatorFrame];
}

- (void)buttonFadeInAnimation:(UIButton *)button
{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [button.layer addAnimation:animation forKey:nil];

    button.hidden = NO;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.userProfile == nil)
        return 0;
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.userProfile == nil)
        return 0;

    if (section == 0)
        return 1;

    if (self.userProfile.assets == nil)
        return 0;

    NSInteger count = self.userProfile.assets.count;
    return count > 0 ? count : 1; // 1 for "no design"
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        _profileUserInfoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileUserInfoCell" forIndexPath:indexPath];
        _profileUserInfoCell.delegate = self;
        if (self.userProfile != nil) {
            _profileUserInfoCell.userProfile = self.userProfile;
        }

        [self refreshFollowButtonStatus];

        return _profileUserInfoCell;
    }

    if (self.userProfile.assets == nil)
        return nil; // should not occur

    if (self.userProfile.assets.count == 0) {
        GalleryStreamEmptyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryStreamEmptyCellID" forIndexPath:indexPath];
        cell.emptyType = GalleryStreamEmptyNoDesign;
        return cell;
    }

    ProfileCollectionViewCell_DesignItem * cell = nil;

    if (IS_IPAD || self.currentMode == BigMode) {
        ProfileCollectionViewCell_DesignBig * bigCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileDesignItemCell" forIndexPath:indexPath];
        cell = bigCell;
    } else {
        ProfileCollectionViewCell_DesignSmall * smallCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileSimpleDesignItemCell" forIndexPath:indexPath];
        cell = smallCell;
    }

    if (cell != nil) {
        cell.isOwnerProfile = self.isCurrentUserProfile;
        cell.designModel = self.userProfile.assets[indexPath.row];
        cell.delegate = self;
    }

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 1 || ![kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView * view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionViewFakeHeaderFooter" forIndexPath:indexPath];
        view.frame = CGRectZero;
        return view;
    }

    ProfileCollectionViewHeader * header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CollectionViewHeader" forIndexPath:indexPath];
    header.delegate = self;
    [header setDesignsCount:self.userProfile.assets.count];

    return header;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width;

    if (indexPath.section == 0) {
        // user info cell
        CGFloat height = viewWidth * self.backgroundImageAspect + (self.collectionViewLayout.itemSize.height - self.collectionViewLayout.itemSize.width * self.backgroundImageAspect);
        CGFloat extraHeight = [ProfileCollectionViewCell_UserInfo calcExtraUserInfoHeightForUser:self.userProfile withCellWidth:viewWidth];
        height += extraHeight;
        return CGSizeMake(viewWidth, height);
    }

    viewWidth = [UIScreen mainScreen].bounds.size.width - 2 * self.collectionViewCellMargin;

    if (self.userProfile.assets == nil || self.userProfile.assets.count == 0) {
        return CGSizeMake(viewWidth, 280); // 280 for No designs cell
    }

    MyDesignDO * design = self.userProfile.assets[indexPath.row];

    if (IS_IPAD || self.currentMode == BigMode) {
        CGFloat width = viewWidth;
        if (IS_IPAD) {
            width = (viewWidth - self.collectionViewLayout.minimumInteritemSpacing) / 2;
        }
        CGFloat height = width * DESIGN_IMAGE_ASPECT + 45;
        CGFloat descHeight = [ProfileCollectionViewCell_DesignBig calcDesignDescrtiptionTextHeightForDesign:design cellWidth:width];
        height += descHeight;

        return CGSizeMake(width, height);
    }

    // phone small card mode
    CGFloat size = (viewWidth - self.collectionViewLayout.minimumInteritemSpacing) / 2;
    return CGSizeMake(size, size);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0 || self.userProfile.assets == nil || self.userProfile.assets.count == 0)
        return UIEdgeInsetsZero;

    CGFloat bottomExtra = 0;
    if (@available(iOS 11.0, *)) {
        bottomExtra += self.view.safeAreaInsets.bottom;
    }
    return UIEdgeInsetsMake(self.collectionViewLayout.minimumLineSpacing, self.collectionViewCellMargin,
                            self.collectionViewLayout.minimumLineSpacing + bottomExtra, self.collectionViewCellMargin);
}

#pragma mark - HSCollectionViewWaterfallLayoutDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section {
    if (section == 0)
        return 1;

    if (self.userProfile.assets.count == 0)
        return 1;

    if (IS_IPAD || self.currentMode == SmallMode)
        return 2;

    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section {
    if (section == 1)
        return self.collectionViewLayout.headerReferenceSize.height;

    return 0;
}

#pragma mark -ProfileInstanceDelegate

- (NSString*)getUserIDForCurrentProfile {

    if (self.userProfile) {
        return self.userProfile.userId;
    }

    if (_userId) {
        return _userId;
    }

    return nil;
}

- (UserProfile*)getUserProfileObject {
    return self.userProfile;
}

#pragma mark - ProfileUserInfoDelegate

- (void)editProfile {
    self.profileEditUserDetailsVC = [ControllersFactory instantiateViewControllerWithIdentifier:@"profileUserDetailsViewController" inStoryboard:kNewProfileStoryboard];

    self.profileEditUserDetailsVC.isLoggedInUserProfile = self.isCurrentUserProfile;
    self.profileEditUserDetailsVC.rootUserDelegate = self;
    self.profileEditUserDetailsVC.isEditingPresentation = YES;

    [self.profileEditUserDetailsVC presentByParentViewController:self animated:YES completion:nil];
}

- (void)showFollowing {
    ProfileUserListViewController * followingVC = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileUserListViewController" inStoryboard:kNewProfileStoryboard];

    ProfileUserListFollowing * dataSource = [[ProfileUserListFollowing alloc] init];
    dataSource.userId = [self getUserIDForCurrentProfile];
    followingVC.dataSource = dataSource;

    [[[UIManager sharedInstance] pushDelegate].navigationController pushViewController:followingVC animated:YES];
}

- (void)showFollowers {
    ProfileUserListViewController * followersVC = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileUserListViewController" inStoryboard:kNewProfileStoryboard];

    ProfileUserListFollowers * dataSource = [[ProfileUserListFollowers alloc] init];
    dataSource.userId = [self getUserIDForCurrentProfile];
    followersVC.dataSource = dataSource;

    [[[UIManager sharedInstance] pushDelegate].navigationController pushViewController:followersVC animated:YES];
}

- (void)showLikesToast {
    if (self.likesToastVC != nil)
        return;

    self.likesToastVC = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileLikesToastViewController" inStoryboard:kNewProfileStoryboard];
    self.likesToastVC.userProfile = self.userProfile;
    [self.likesToastVC presentByParentViewController:self animated:YES completion:nil];
}

#pragma mark - FollowUserItemDelegate
- (void)followUser:(FollowUserInfo *)userInfo
            follow:(BOOL)follow
    preActionBlock:(nullable PreFollowUserBlock)preActionBlock
   completionBlock:(nullable FollowUserCompletionBlock)completionBlock
            sender:(nullable UIView *)sender {
    if (!follow) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"unfollow_user", @""), [userInfo getUserFullName]];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *unfollowAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"unfollow", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self followUser:userInfo follow:follow preActionBlock:preActionBlock completionBlock:completionBlock];
        }];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"alert_msg_button_cancel", @"") style:UIAlertActionStyleCancel handler:nil];

        [alert addAction:unfollowAction];
        [alert addAction:cancelAction];

        if (IS_IPAD) {
            [alert setModalPresentationStyle:UIModalPresentationFormSheet];

            UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
            popPresenter.sourceView = sender;
            popPresenter.sourceRect = sender.bounds;
        }

        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    [self followUser:userInfo follow:follow preActionBlock:preActionBlock completionBlock:completionBlock];
}

- (void)followUser:(FollowUserInfo *)info
            follow:(BOOL)follow
    preActionBlock:(nullable PreFollowUserBlock)preActionBlock
   completionBlock:(nullable FollowUserCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;

    if (![[UserManager sharedInstance] isLoggedIn]) {
        [[UserManager sharedInstance] showLoginFromViewController:self
                                                  eventLoadOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_FOLLOW
                                                    preLoginBlock:^{
//                                                        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:
//                                                         @{EVENT_PARAM_SIGNUP_TRIGGER: EVENT_PARAM_VAL_FOLLOW_USER,
//                                                           EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_VAL_LOAD_ORIGIN_FOLLOW}];
                                                    }
                                                  completionBlock:^(BOOL success) {
                                                      if (weakSelf != nil) {
                                                          if (success) {
                                                              [weakSelf followUser:info follow:follow preActionBlock:preActionBlock completionBlock:completionBlock];
                                                          }
                                                      }
                                                  }];
        return;
    }

    NSString * userId = info.userId;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf == nil)
            return;

        __strong typeof(self) strongSelf = weakSelf;
        // update activity indicator frame
        [self updateTopBarActivityIndicatorFrame];

        strongSelf.topBarActivityIndicator.hidden = NO;
        [strongSelf.topBarActivityIndicator startAnimating];
    });

    if (preActionBlock != nil) {
        preActionBlock(userId);
    }

    [[HomeManager sharedInstance] followUser:info.userId
                                      follow:follow
                              withCompletion:^(id serverResponse) {
                                  BaseResponse * response = (FollowResponse *)serverResponse;
                                  BOOL success = (response != nil && response.errorCode == -1);
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      if (weakSelf == nil)
                                          return;

                                      __strong typeof(self) strongSelf = weakSelf;
                                      [strongSelf.topBarActivityIndicator stopAnimating];
                                      //strongSelf.topBarActivityIndicator.hidden = YES;
                                  });
                                  if (completionBlock != nil) {
                                      completionBlock(userId, success);
                                  }
                              }
                                failureBlock:^(NSError * err) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (weakSelf == nil)
                                            return;

                                        __strong typeof(self) strongSelf = weakSelf;
                                        [strongSelf.topBarActivityIndicator stopAnimating];
                                        //strongSelf.topBarActivityIndicator.hidden = YES;
                                    });
                                    if (completionBlock != nil) {
                                        completionBlock(userId, NO);
                                    }
                                }
                                       queue:nil];
}

- (void)userPressed:(FollowUserInfo *)info {
    if (![info.userId isEqual:self.userId])
    {
        [self openUserProfilePageController:info.userId];
    }
}

- (void)openUserProfilePageController:(NSString *)infoUserID {
    ProfileViewController* profileViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileViewController" inStoryboard:kNewProfileStoryboard];
    [profileViewController setUserId:infoUserID];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)startRedesignTool {
    SavedDesign * saveDesign = [[DesignsManager sharedInstance] workingDesign];

    GalleryItemDO * gido = (GalleryItemDO*)self.tempDesignPressed;
    [[UIManager sharedInstance] galleryDesignSelected:saveDesign withOriginalDesign:gido  withOriginEvent:EVENT_PARAM_VAL_LOAD_ORIGIN_REDESIGN];
    [[UIManager sharedInstance] galleryDesignBGImageRecieved:saveDesign.image andOrigImage:saveDesign.originalImage andMaskImage:saveDesign.maskImage];
}

- (void)openGalleryFullScreen:(NSArray *)designs selectedDesignIdx:(NSInteger)selectedDesignIdx {
    FullScreenBaseViewController* fsbVc = [[UIManager sharedInstance] createFullScreenGallery:designs
                                                                            withSelectedIndex:(int)selectedDesignIdx
                                                                                  eventOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_USER_PROFILE ];
    fsbVc.sourceViewController = self;
    fsbVc.dataSourceType = eFScreenUserDesigns;
    [self.navigationController pushViewController:fsbVc animated:YES];
}

#pragma mark - ActivityTableCellDelegate

- (void)openHelpEmailPage {

}

- (void)openUserProfilePage:(NSString *)profileId {
    [self openUserProfilePageController:profileId];
}

- (BOOL)isCurrentCellOfLoggedInUser {
    return self.isCurrentUserProfile;
}

//returns a view controller to peresent login view etc on it, in case of need.
- (UIViewController *)delegateViewController {
    return self;
}

#pragma mark - DesignItemDelegate

- (void)designPressed:(DesignBaseClass*)design {
    self.tempDesignPressed = design;
    NSMutableArray * designs = [self.userProfile.assets mutableCopy];

    if (design.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {

        [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"ask_to_redesign_auto_Save_from_mydesigns", @"Please Redesign and Save this design in order to make any changes")
                                   delegate:self cancelButtonTitle:NSLocalizedString(@"resume_alert_button", @"")
                          otherButtonTitles:NSLocalizedString(@"alert_msg_button_cancel", @""), nil] show];
        return;
    }

    for (int i = 0; i< designs.count; i++) {
        MyDesignDO * md = [designs objectAtIndex:i];
        if (md.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
            [designs removeObject:md];
            i--;
        }
    }

    NSInteger selectedDesignIdx = [designs indexOfObject:design];
    //Fix getmyProfile twice bug
    [self openGalleryFullScreen:designs selectedDesignIdx:selectedDesignIdx];
}

- (void)toggleLikeStateForDesign:(nonnull DesignBaseClass *)design
                  withLikeButton:(nonnull UIButton *)likeButton
                    preActionBlock:(nullable PreDesignLikeBlock)preActionBlock
                 completionBlock:(nullable DesignLikeCompletionBlock)completionBlock {
    if (self.likeActionHelper == nil) {
        self.likeActionHelper = [DesignItemLikeActionHelper new];
    }
    [self.likeActionHelper toggleLikeStateForDesign:design
                                     withLikeButton:likeButton
                                  andViewController:self
                                     preActionBlock:^{
                                         if (preActionBlock != nil) {
                                             preActionBlock();
                                         }
                                     }
                                    completionBlock:^(NSString * designId, BOOL success) {
                                        if (completionBlock != nil) {
                                            completionBlock(designId, success);
                                        }
                                    }];
}

- (void)shareDesign:(nonnull DesignBaseClass *)design withDesignImage:(nonnull UIImage *)designImage {
    if (designImage == nil)
        return;

    if (self.shareActionHelper == nil) {
        self.shareActionHelper = [DesignItemShareActionHelper new];
    }

    [self.shareActionHelper shareDesign:design withDesignImage:designImage fromViewController:self withDelegate:self loadOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_USER_PROFILE];
}

- (void)designEditPressed:(MyDesignDO *)design {
    _myDesignEditViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"MyDesignsEditViewController" inStoryboard:kNewProfileStoryboard];

    _myDesignEditViewController.design = design;
    _myDesignEditViewController.delegate = self;

    [_myDesignEditViewController presentByParentViewController:self animated:YES completion:nil];
}

#pragma mark - ProfileUserDetailsDelegate

- (void)askToLeaveWithoutSave {
    if (self.profileEditUserDetailsVC != nil) {
        [self.profileEditUserDetailsVC dismissSelf];
    } else {
        [self closeScreen];
    }
}

- (void)askToLeaveWithSaveAction {
    [self.profileEditUserDetailsVC leaveProfileEditingWithSaveChanges:nil];
}

- (void)leaveProfileEditingWithoutChanges {
    [self.profileEditUserDetailsVC dismissSelf];
}

- (void)leaveProfileEditingWithSaveChanges:(UserDO *)deltaUser{
    //TODO: make save request , including image update

    if ([NSString isNullOrEmpty:deltaUser.firstName] || [NSString isNullOrEmpty:deltaUser.lastName])
    {
        [self showErrorWithMessage:NSLocalizedString(@"err_msg_enter_new_full_name",@"Please enter you first/last name")];
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        return ;
    }

    HSCompletionBlock updateBlock = ^(id serverResponse, id error) {

        //will update image url for the profile
        if(serverResponse && [serverResponse isKindOfClass:[NSString class]]) {
            deltaUser.userProfileImage = serverResponse;
        }

        [[UserManager sharedInstance] updateUserInfoWithDO:deltaUser completionBlock:^(id serverResponse, id error) {
            if (error) {
                [self showErrorWithMessage:NSLocalizedString(@"err_msg_update_user_info",@"Failed to update user info")];
            } else {
                BaseResponse * response = (BaseResponse*)serverResponse;

                if (response.errorCode==-1) {

                    //update was successful

                    //update profile data
                    [self.userProfile updateUserProfileAccoringToUpdatedUser:deltaUser];
                    // refresh data
                    [self refreshCollectionView];
                    [self.profileEditUserDetailsVC dismissSelf];
                } else {
                    [self showErrorWithMessage:NSLocalizedString(@"err_msg_update_user_info",@"Failed to update user info")];
                    [self.profileEditUserDetailsVC disregardChangesOnProfileObject];
                }
            }
            [[ProgressPopupBaseViewController sharedInstance] stopLoading];

        } queue:dispatch_get_main_queue()];
    };

    //if photo changed upload it
    if (deltaUser.tempEditProfileImage) {
        [self uploadImage:deltaUser.tempEditProfileImage withCompletionBlock:updateBlock];
    } else {
        updateBlock(nil, nil);
    }
}

- (UIView*)getParentView {
    return self.view;
}

- (void)changeUserProfileImageRequestedForRect:(UIView*)mview {
    [self logFlurryEvent:FLURRY_PROFILE_EDIT_IMAGE_CLICK];
    CGRect rect=[self.view convertRect:mview.frame fromView:mview.superview];
    [self startMediaBrowser:rect];
}

- (BOOL)startMediaBrowser:(CGRect)rect {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.allowsEditing = NO;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    picker.delegate = self;
    // Check which device
    if (IS_IPAD) {
        self.imageGalleryPopover = [[UIPopoverController alloc] initWithContentViewController:picker];
        [self.imageGalleryPopover setDelegate:self];
        [self.imageGalleryPopover presentPopoverFromRect:rect
                                                  inView:self.view
                                permittedArrowDirections:UIPopoverArrowDirectionUp
                                                animated:YES];
    } else {
        [self presentViewController:picker animated:YES completion:nil];
    }
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    // Get media type
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];

    // Check media type
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {

        // Clear the image
        self.userProfile.userPhoto = nil;

        [self.profileEditUserDetailsVC updateProfileImage:(UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage]];
    }

    // Close the popover / modal VC
    if (IS_IPAD) {
        [self.imageGalleryPopover dismissPopoverAnimated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [picker dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.imageGalleryPopover = nil;
}

- (void)uploadImage:(UIImage*)image withCompletionBlock:(HSCompletionBlock)completion {
    //imgmaayan
    [self logFlurryEvent:FLURRY_CHANGE_PROFILE_IMAGE];

    NSString * profileImage= [[[UserManager sharedInstance] currentUser] userProfileImage];

    // Clear local file before update
    if (profileImage) {
        NSString * filename=[profileImage lastPathComponent];
        NSString* imagePath =[NSString stringWithFormat:@"%@/profileView%@",[[ConfigManager sharedInstance] getStreamsPath]
                              ,filename];

        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        imagePath =[NSString stringWithFormat:@"%@/menuView%@",[[ConfigManager sharedInstance] getStreamsPath]
                    ,filename];

        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];

        imagePath =[NSString stringWithFormat:@"%@/comment_%@",[[ConfigManager sharedInstance] getStreamsPath]
                    ,filename];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];


        imagePath =[NSString stringWithFormat:@"%@/commentrep_%@",[[ConfigManager sharedInstance] getStreamsPath]
                    ,filename];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    }

    [[ServerUtils sharedInstance] uploadNewPhoto:image completion:completion];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.shouldAlertCloseScreen) {
        [self closeScreen];
    }
}

#pragma mark - Actions

- (IBAction)showNotificationsList:(UIButton *)sender {
    [self.notificationsButton setImage:(_topBarIconMode ? self.notificationsImg : self.whiteNotificationsImg) forState:UIControlStateNormal];
    [self.notificationsActionHelper showNotificationsListFromViewController:self withDelegate:self];
#ifdef USE_FLURRY
//    [HSFlurry logAnalyticEvent:EVENT_NAME_NOTIFICATIONS_UI_OPEN withParameters:@{EVENT_PARAM_UI_ORIGIN:EVENT_PARAM_VAL_UISOURCE_PROFILE}];
#endif
}

- (IBAction)backPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationUserDidLogout  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DesignManagerSyncCycleComplete" object:nil];

    self.tempDesignPressed = nil;
    self.delegate = nil;
    self.profileEditUserDetailsVC = nil;

    [self closeScreen];
}

- (IBAction)scrollToTopPressed:(id)sender {
    [self.collectionView setContentOffset:CGPointZero animated:YES];
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

    [self followUser:followUserInfo follow:follow preActionBlock:^(NSString * _Nullable userId) {
        if (weakSelf != nil && [weakSelf.userProfile.userId isEqualToString:userId]) {
            // update follow button state
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf == nil)
                    return;

                __strong typeof(self) strongSelf = weakSelf;
                strongSelf.topBarFollowButton.isFollowing = YES;
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
                 strongSelf.topBarFollowButton.isFollowing = NO;
                 strongSelf.topBarFollowButton.userInteractionEnabled = YES;
             });
         }
     }
              sender:sender];
}

- (void)closeScreen{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

