//
//  MessagesViewController.m
//  Homestyler
//
//  Created by liuyufei on 5/1/18.
//

#import "MessagesViewController.h"
#import "MessagesCell.h"
#import "MessagesHeaderView.h"
#import "MessagesNoNotificationsCell.h"

#import "MessagesManager.h"
#import "FollowUserInfo.h"
#import "NotificationDetailDO.h"
#import "NotificationDesignInfoDO.h"

#import "ControllersFactory.h"
#import "ProfileViewController.h"
#import "FullScreenBaseViewController.h"
#import "ProgressPopupBaseViewController.h"

#import "FollowUserActionHelper.h"

#import "NotificationNames.h"

//#import "HSFlurry.h"

#import "NSString+Contains.h"

#import <MJRefresh.h>

static NSString *const MessagesCellID = @"MessagesCellID";
static NSString *const MessagesNoNotificationsCellID = @"MessagesNoNotificationsCellID";

@interface MessagesViewController () <FollowUserItemDelegate, DesignItemDelegate>

@property (strong, nonatomic) FollowUserActionHelper *followUserActionHelper;

@property (nonatomic, assign) NSInteger offSet;

@property (weak, nonatomic) IBOutlet UILabel *notifyListViewControllerTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MessagesViewController
{
    BOOL _showProgress;
}

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.screenName = GA_NOTIFICATIONS_SCREEN;

    self.offSet = 0;
    [self setupTableView];
    [self setupMJRefresh];

    self.notifyListViewControllerTitle.text = NSLocalizedString(@"notify_title", nil);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserFollowingStatus:) name:kNotificationUserFollowingStatusChanged object:nil];

    [self loadData];
    _showProgress = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    if (_showProgress) {
        _showProgress = NO;
        [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
    }
}

#pragma mark - Orientation
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    NSLog(@"dealloc - MessagesViewController");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"MessagesCell" bundle:nil] forCellReuseIdentifier:MessagesCellID];
    [self.tableView registerNib:[UINib nibWithNibName:@"MessagesNoNotificationsCell" bundle:nil] forCellReuseIdentifier:MessagesNoNotificationsCellID];
}

- (void)setupMJRefresh
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData];
    }];
    header.automaticallyChangeAlpha = YES;
    [header setTitle:@"" forState:MJRefreshStateIdle];
    [header setTitle:@"" forState:MJRefreshStatePulling];
    [header setTitle:@"" forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.labelLeftInset = 0;
    self.tableView.mj_header = header;

    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if ([MessagesManager sharedInstance].hasMoreData)
        {
            [self loadMoreData];
        }
        else
        {
            if ([MessagesManager sharedInstance].unreadList.count == 0 && [MessagesManager sharedInstance].viewedList.count == 0) {
                [self.tableView.mj_footer endRefreshing];
            } else {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    }];
    footer.automaticallyChangeAlpha = YES;
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"" forState:MJRefreshStateRefreshing];
    [footer.stateLabel setValue:@"Text_Body3" forKey:@"nuiClass"];
    [footer setTitle:NSLocalizedString(@"no_more", @"No more") forState:MJRefreshStateNoMoreData];
    footer.labelLeftInset = 0;
    self.tableView.mj_footer = footer;
}

- (void)loadData
{
    __weak typeof(self) weakSelf = self;
    [[MessagesManager sharedInstance] getMessagesDetailWithCompletion:^(id response, id error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ProgressPopupBaseViewController sharedInstance] stopLoading];
            if (response != nil)
            {
                [weakSelf.tableView reloadData];
            }
            [weakSelf.tableView.mj_header endRefreshing];
        });
    } queue:dispatch_get_main_queue()];
}

- (void)loadMoreData
{
    self.offSet = [MessagesManager sharedInstance].currentOffset;
    __weak typeof(self) weakSelf = self;
    [[MessagesManager sharedInstance] getMoreMessagesDetailWithOffset:self.offSet Completion:^(id response, id error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil)
            {
                [weakSelf.tableView reloadData];
            }
            [weakSelf.tableView.mj_footer endRefreshing];
        });
    } queue:dispatch_get_main_queue()];
}

- (void)presentByParentViewController:(UIViewController*)parentViewController
                             animated:(BOOL)animated
                           completion:(void (^ __nullable)(void))completion
{

}


- (void)updateUserFollowingStatus:(NSNotification *)notification {
    NSString * userId = [[notification userInfo] objectForKey:@"userId"];
    BOOL isFollowed = YES;
    [[[notification userInfo] objectForKey:@"isFollowed"] getValue:&isFollowed];

    BOOL userFound = [self updateFollowingStatusForUser:userId followed:isFollowed];
    if (!userFound)
        return;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
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

- (BOOL)updateFollowingStatusForUser:(NSString *)userId followed:(BOOL)followed {
    NSArray * users = [MessagesManager sharedInstance].unreadList;
    BOOL userFound = [self updateFollowingStatusForUser:userId followed:followed inUserList:users];
    users = [MessagesManager sharedInstance].viewedList;
    userFound = [self updateFollowingStatusForUser:userId followed:followed inUserList:users] || userFound;
    return userFound;
}

- (BOOL)updateFollowingStatusForUser:(NSString *)userId followed:(BOOL)followed inUserList:(NSArray *)users {
    BOOL userFound = NO;
    for (NSInteger i = 0; i < users.count; i++) {
        NotificationDetailDO * message = [users objectAtIndex:i];
        FollowUserInfo * userInfo = message.fromUser;
        if (userInfo == nil)
            continue;

        if ([userInfo.userId isEqualToString:userId]) {
            userInfo.isFollowed = followed;
            userFound = YES;
        }
    }
    return userFound;
}

- (void)userPressed:(FollowUserInfo *)userInfo {
    [self openUserProfilePageController:userInfo];
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

- (void)showDesignDetailById:(nonnull NSString *)designId {
    MyDesignDO *design = [MyDesignDO new];
    design._id = designId;
    design.type = e3DItem;

    __weak typeof(self) weakSelf = self;
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];

    [design virtualGalleryItemExtraInfo:NO completionBlock:^(NSString *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ProgressPopupBaseViewController sharedInstance] stopLoading];
            if (weakSelf == nil)
                return;

            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf designPressed:design];
        });
    }];
}

- (void)designPressed:(DesignBaseClass*)design {
    NSArray * designs = [NSArray arrayWithObject:design];

    if (design.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {

        [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"ask_to_redesign_auto_Save_from_mydesigns", @"Please Redesign and Save this design in order to make any changes")
                                   delegate:self cancelButtonTitle:NSLocalizedString(@"resume_alert_button", @"")
                          otherButtonTitles:NSLocalizedString(@"alert_msg_button_cancel", @""), nil] show];
        return;
    }

    NSInteger selectedDesignIdx = [designs indexOfObject:design];
    FullScreenBaseViewController* fsVc = [[UIManager sharedInstance] createFullScreenGallery:designs
                                                                           withSelectedIndex:(int)selectedDesignIdx
                                                                                 eventOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_USER_PROFILE ];
    fsVc.sourceViewController = self;
    fsVc.dataSourceType = eFScreenUserDesigns;
    [self.navigationController pushViewController:fsVc animated:YES];
}


#pragma mark - Action
- (IBAction)scrollToTop:(UIButton *)sender {
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger unreadSection = [MessagesManager sharedInstance].unreadList.count > 0 ? 1 : 0;
    NSInteger viewedSection = [MessagesManager sharedInstance].viewedList.count > 0 ? 1 : 0;
    if (unreadSection == 0 && viewedSection == 0)
        return 1;

    return unreadSection + viewedSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![MessagesManager sharedInstance].isLoaded)
    {
        return 0;
    }

    if ([MessagesManager sharedInstance].unreadList.count == 0 && [MessagesManager sharedInstance].viewedList.count == 0)
    {
        return 1;
    }

    if (section == 0 && [MessagesManager sharedInstance].unreadList.count > 0)
    {
        return [MessagesManager sharedInstance].unreadList.count;
    }

    return [MessagesManager sharedInstance].viewedList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([MessagesManager sharedInstance].unreadList.count == 0 && [MessagesManager sharedInstance].viewedList.count == 0)
    {
        MessagesNoNotificationsCell *cell = [tableView dequeueReusableCellWithIdentifier:MessagesNoNotificationsCellID forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    MessagesCell *cell = [tableView dequeueReusableCellWithIdentifier:MessagesCellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    if ([MessagesManager sharedInstance].unreadList.count > 0 && indexPath.section == 0)
    {
        cell.detail = [[MessagesManager sharedInstance].unreadList objectAtIndex:indexPath.row];
    }
    else
    {
        cell.detail = [[MessagesManager sharedInstance].viewedList objectAtIndex:indexPath.row];
    }
    cell.followUserDelegate = self;
    cell.designItemDelegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([MessagesManager sharedInstance].unreadList.count == 0 && [MessagesManager sharedInstance].viewedList.count == 0)
        return;

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NotificationDetailDO *detail = nil;
    if ([MessagesManager sharedInstance].unreadList.count > 0 && indexPath.section == 0)
    {
        detail = [[MessagesManager sharedInstance].unreadList objectAtIndex:indexPath.row];
    }
    else
    {
        detail = [[MessagesManager sharedInstance].viewedList objectAtIndex:indexPath.row];
    }

    if (!detail)
        return;
    
    if ([detail.noticeType isEqualToString:@"LIKE"] ||
        [detail.noticeType isEqualToString:@"COMMENT"] ||
        [detail.noticeType isEqualToString:@"FEATURE"])
    {
        if ([NSString isNullOrEmpty:detail.designInfo.designId])
            return;

        [self showDesignDetailById:detail.designInfo.designId];
    }
    else if ([detail.noticeType isEqualToString:@"FOLLOW"])
    {
         [self openUserProfilePageController:detail.fromUser];
    }
}

#pragma mark - UITableViewDelegate
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([MessagesManager sharedInstance].unreadList.count > 0 && section == 0)
    {
        MessagesHeaderView *newView = [[UINib nibWithNibName:@"MessagesHeaderView" bundle:nil] instantiateWithOwner:nil options:nil].firstObject;
        newView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 40);
        return newView;
    }
    UIView *earilyView = [[UIView alloc] init];
    earilyView.frame = CGRectMake(0, 0, tableView.frame.size.width, 1);
    earilyView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    return earilyView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([MessagesManager sharedInstance].unreadList.count > 0 && section == 0)
        return 40;

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([MessagesManager sharedInstance].unreadList.count == 0
        && [MessagesManager sharedInstance].viewedList.count == 0)
    {
        return self.tableView.bounds.size.height;
    }
    return UITableViewAutomaticDimension;
}

@end
