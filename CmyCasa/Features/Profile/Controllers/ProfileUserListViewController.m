//
//  ProfileUserListViewController.m
//  Homestyler
//
//  Created by Eric Dong on 04/12/2018.
//

#import "ProfileUserListViewController.h"
#import "ProfileUserListViewCell.h"

#import "ProfileUserListFollowing.h"
#import "ProfileUserListFollowers.h"
#import "ProfileUserListDesignLikes.h"

#import "UserManager.h"

#import "ControllersFactory.h"
#import "ProfileViewController.h"
#import "ProgressPopupBaseViewController.h"

#import "FollowUserActionHelper.h"

#import "ProtocolsDef.h"
#import "NotificationNames.h"

#import <MJRefresh.h>

@interface ProfileUserListViewController () <UICollectionViewDelegate>

@property (strong, nonatomic) FollowUserActionHelper *followUserActionHelper;

@property (weak, nonatomic) IBOutlet UILabel * pageTitle;
@property (weak, nonatomic) IBOutlet UICollectionView * collectionView;

@end

@implementation ProfileUserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.screenName = [self.dataSource getGAScreenName];

    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior  = UIScrollViewContentInsetAdjustmentNever;
    }

    [self.collectionView registerNib:[UINib nibWithNibName:@"ProfileUserListViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ProfileUserListViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ProfileUserListViewEmptyCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ProfileUserListViewEmptyCell"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserFollowingStatus:) name:kNotificationUserFollowingStatusChanged object:nil];

    self.pageTitle.text = [self.dataSource getDefaultTitle];

    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];

    [self setMJRefresh];

    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (IS_IPAD)
        return UIInterfaceOrientationMaskLandscape;

    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    NSLog(@"dealloc - ProfileUserListViewController");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateUserFollowingStatus:(NSNotification *)notification {
    NSString * userId = [[notification userInfo] objectForKey:@"userId"];
    FollowUserInfo * userInfo = [self getUserInfoWithId:userId];
    if (userInfo == nil)
        return;

    // reload data for my following
    if (self.dataSource.userListType == ProfileUserListTypeFollowing && [[UserManager sharedInstance] isCurrentUser:self.dataSource.userId]) {
        [self reloadData];
        return;
    }

    BOOL isFollowed = YES;
    [[[notification userInfo] objectForKey:@"isFollowed"] getValue:&isFollowed];
    userInfo.isFollowed = isFollowed;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

#pragma mark - FollowUserItemDelegate
- (void)followUser:(FollowUserInfo *)userInfo
            follow:(BOOL)follow
    preActionBlock:(nullable PreFollowUserBlock)preActionBlock
   completionBlock:(nullable FollowUserCompletionBlock)completionBlock
            sender:(nullable UIView *)sender {
    if (self.followUserActionHelper == nil) {
        self.followUserActionHelper = [FollowUserActionHelper new];
    }
    [self.followUserActionHelper followUser:userInfo
                                     follow:follow
                             preActionBlock:preActionBlock
                            completionBlock:completionBlock
                         hostViewController:self
                                     sender:sender];
}

- (FollowUserInfo *)getUserInfoWithId:(NSString *)userId {
    NSArray * users = self.dataSource.users;
    for (NSInteger i = 0; i < users.count; i++) {
        FollowUserInfo * userInfo = [users objectAtIndex:i];
        if ([userInfo.userId isEqualToString:userId])
            return userInfo;
    }
    return nil;
}

- (void)userPressed:(FollowUserInfo *)userInfo {
    if (![userInfo.userId isEqualToString:self.dataSource.userId]) {
        [self openUserProfilePageController:userInfo];
    }
}

- (void)openUserProfilePageController:(FollowUserInfo *)userInfo {
    ProfileViewController* profileViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileViewController" inStoryboard:kNewProfileStoryboard];
    profileViewController.userId = userInfo.userId;
    UserProfile *userProfile = [[UserProfile alloc] init];
    userProfile.userId = userInfo.userId;
    userProfile.userDescription = userInfo.userDescription;
    userProfile.firstName = userInfo.firstName;
    userProfile.lastName = userInfo.lastName;
    userProfile.userPhoto = userInfo.photoUrl;
    profileViewController.userProfile = userProfile;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataSource == nil)
        return 0;

    if (self.dataSource.users.count <= 0)
        return 1; // empty tip

    return self.dataSource.users.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource == nil || self.dataSource.users == nil)
        return nil;

    if (self.dataSource.users.count == 0) {
        ProfileUserListViewEmptyCell * emptyCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileUserListViewEmptyCell" forIndexPath:indexPath];
        emptyCell.messageLabel.text = [self.dataSource getEmptyMessage];
        return emptyCell;
    }

    ProfileUserListViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileUserListViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.userInfo = self.dataSource.users[indexPath.row];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource == nil || self.dataSource.users == nil)
        return CGSizeZero;

    if (self.dataSource.users.count == 0) {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, 400/*cell height*/);
    }

    UICollectionViewFlowLayout * flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGFloat height = flowLayout.itemSize.height;
    if (IS_IPAD) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing;
        width /= 2;
        return CGSizeMake(width, height);
    } else {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, height);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.dataSource == nil || self.dataSource.users == nil || self.dataSource.users.count == 0) {
        return UIEdgeInsetsZero;
    }

    if (IS_IPAD) {
        UICollectionViewFlowLayout * flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
        return UIEdgeInsetsMake(0, flowLayout.sectionInset.left, 0, flowLayout.sectionInset.right);
    }
    CGFloat bottomExtra = 0;
    if (@available(iOS 11.0, *)) {
        bottomExtra += self.view.safeAreaInsets.bottom;
    }
    return UIEdgeInsetsMake(0, 0, bottomExtra, 0);
}

- (void)refreshUI {
    self.pageTitle.text = [self.dataSource getTitleWithNumber];
    [self.collectionView reloadData];
}

- (void)reloadData {
    __weak typeof(self) weakSelf = self;
    [self.dataSource reloadWithCompletion:^(BOOL success) {
        if (weakSelf == nil)
            return;

        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf == nil)
                return;

            __strong typeof(self) strongSelf = weakSelf;
            [[ProgressPopupBaseViewController sharedInstance] stopLoading];
            if (success) {
                [strongSelf refreshUI];
            }
            strongSelf.collectionView.mj_footer.hidden = NO;
            [strongSelf.collectionView.mj_header endRefreshing];
            if ([strongSelf.dataSource hasMoreData]) {
                [strongSelf.collectionView.mj_footer endRefreshing];
            }
        });
    }];
}

- (void)loadMoreData {
    __weak typeof(self) weakSelf = self;
    [self.dataSource loadMoreWithCompletion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf == nil)
                return;

            __strong typeof(self) strongSelf = weakSelf;
            if (success) {
                [strongSelf refreshUI];
            }
            strongSelf.collectionView.mj_footer.hidden = NO;
            [strongSelf.collectionView.mj_header endRefreshing];
            if ([strongSelf.dataSource hasMoreData]) {
                [strongSelf.collectionView.mj_footer endRefreshing];
            }
        });
    }];
}

-(void)setMJRefresh {
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self reloadData];
    }];
    header.automaticallyChangeAlpha = YES;
    [header setTitle:@"" forState:MJRefreshStateIdle];
    [header setTitle:@"" forState:MJRefreshStatePulling];
    [header setTitle:@"" forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.labelLeftInset = 0;
    self.collectionView.mj_header = header;

    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if ([self.dataSource hasMoreData]) {
            [self loadMoreData];
        } else {
            if (self.dataSource.users.count > 0) {
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [self.collectionView.mj_footer endRefreshing];
            }
        }
    }];
    footer.automaticallyChangeAlpha = YES;
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"" forState:MJRefreshStateRefreshing];
    [footer.stateLabel setValue:@"Text_Body3" forKey:@"nuiClass"];
    [footer setTitle:NSLocalizedString(@"no_more", @"No more") forState:MJRefreshStateNoMoreData];
    footer.labelLeftInset = 0;
    footer.hidden = YES;
    self.collectionView.mj_footer = footer;
}

#pragma mark - Actions

- (IBAction)navBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)scrollToTopPressed:(id)sender {
    [self.collectionView setContentOffset:CGPointZero animated:YES];
}

@end
