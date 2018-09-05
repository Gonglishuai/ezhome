//
//  GalleryStreamBaseController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/9/13.
//
//

#import "GalleryStreamBaseController.h"
#import "GalleryStreamBannerCell.h"
#import "GalleryStreamItemView.h"
#import "GalleryStreamEmptyCell.h"
#import "GalleryStreamHeaderView.h"
#import "GalleryStreamEmptyRoomCell.h"
#import "GalleryStreamEmptyRoomHeaderView.h"
#import "BubbleEffectView.h"
#import "ControllersFactory.h"
#import "DesignItemLikeActionHelper.h"
#import "DesignItemShareActionHelper.h"
#import "NotificationsActionHelper.h"
#import "HSCollectionViewWaterfallLayout.h"
#import "MessagesViewController.h"
#import "MessagesCountDO.h"
#import "ProfileViewController.h"
#import "NotificationNames.h"
#import "PopOverViewController.h"
#import "ProgressPopupViewController.h"
#import "RoomTypeDO.h"

#import "MessagesManager.h"
#import "UIMenuManager.h"

//#import "HSFlurry.h"

#import "NSString+Contains.h"
#import "UIImage+Exif.h"
#import "UIImage+fixOrientation.h"
#import "UIImage+Scale.h"
#import "UIImage+Tint.h"
#import "UIView+Alignment.h"
#import "UIView+ReloadUI.h"

static NSString *const galleryStreamFakeHeaderFooterID = @"GalleryStreamFakeHeaderFooterID";
static NSString *const galleryStreamDefaultCellId = @"GalleryStreamDefaultCellId";
static NSString *const galleryStreamBannerCellID = @"GalleryStreamBannerCellID";
static NSString *const galleryStreamEmptyRoomCell = @"GalleryStreamEmptyRoomCellID";
static NSString *const galleryStreamEmptyRoomHeaderID = @"GalleryStreamEmptyRoomHeaderID";
static NSString *const galleryStreamEmptyCellID = @"GalleryStreamEmptyCellID";
static NSString *const galleryStreamHeaderViewID = @"GalleryStreamHeaderViewCellID";
static NSString *const galleryStreamItemCellID = @"GalleryStreamItemCellID";

static const CGFloat galleryStreamDesignImgAspect = 9.0/16;
static const CGFloat galleryStreamHeaderViewHeight = 50;

#define ONLY_ONE_OPTION 1
#define DROPDOWN_ICON_GAP 30

@interface GalleryStreamBaseController () <UIPopoverPresentationControllerDelegate,GalleryStreamBannerCellDelegate ,HSSharingViewControllerDelegate, GalleryStreamViewControllerDelegate, GalleryStreamEmptyCellDelegate, GalleryStreamHeaderViewDelegate, DesignItemDelegate, HSCollectionViewDelegateWaterfallLayout, MessagesViewControllerDelegate>
{
    BOOL bArticleSelected;
    BOOL b2Dselected;
    BOOL b3Dselected;
    BOOL bEmptySelected;
    NSString *sortByBaseName;
    NSString *roomTypeBaseName;

}

@property (nonatomic, strong) DesignItemLikeActionHelper* likeActionHelper;
@property (nonatomic, strong) DesignItemShareActionHelper* shareActionHelper;
@property (nonatomic, strong) NotificationsActionHelper *notificationActionHelper;

@property (nonatomic, strong) HSCollectionViewWaterfallLayout *layout;
@property (nonatomic, strong) GalleryStreamManager *sman;

@property (nonatomic, assign) GalleryStreamEmptyType galleryStreamEmptyType;

@property (nonatomic, strong) UIControl* background;

@property (nonatomic, strong) UIImage *notificationsImg;
@property (nonatomic, strong) UIImage *notificationsNewImg;

@property (nonatomic, strong) UIView *iPadFilterBottomLine;
@property (strong,nonatomic) UIVisualEffectView *shadowView;

@property (weak, nonatomic) IBOutlet UIButton *messageCenterBtn;
@property (weak, nonatomic) IBOutlet UIButton *sortButton;

@end

@implementation GalleryStreamBaseController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.screenName = GA_DESIGN_STREAM_SCREEN;

    self.hasEmptyView = NO;

    self.sman = [[AppCore sharedInstance] getGalleryManager];

    [self loadCollectionView];
    
    [self setStreamType:[GalleryStreamManager sharedInstance].getActiveGalleryFilterDO.filterType];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.roomTypesEvailable = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAssetLikeStatus:)
                                                 name:kNotificationAssetLikeStatusChanged
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addCommentFinishedNotification:)
                                                 name:kNotificationAddCommentFinished
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCollection)
                                                 name:@"refreshUI"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.view
                                             selector:@selector(reloadUI)
                                                 name:@"NetworkStatusChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setOfflineIndicatorAccordingToNetworkStatus)
                                                 name:@"NetworkStatusChanged"
                                               object:nil];

    [self receiveNotificationsInfo];

    if ([ConfigManager isAnyNetworkAvailable])
    {
        if([[ConfigManager sharedInstance] isConfigLoaded]  == NO)
        {
            [[ConfigManager sharedInstance] loadConfigData];
        }
    }

    [self createFilters];
    
    [self.view reloadUI];

    [self resetFiltersAndSortButtons];
    
    self.background = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.background addTarget:self action:@selector(backgroundTap) forControlEvents:UIControlEventTouchUpInside];

    [self setupImage];

    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamType3D])
    {
        [self removeNotifictionsInfo];
        [self receiveNotificationsInfo];
    }
    [self setOfflineIndicatorAccordingToNetworkStatus];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)dealloc
{    
    [self.roomTypesArr removeAllObjects];
    self.roomTypesArr = nil;
    
    [self.sortTypesArr removeAllObjects];
    self.sortTypesArr = nil;
    
    self.roomTypesPopover = nil;
    self.sortTypesPopover = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    NSLog(@"dealloc - GalleryStreamBaseController");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeNotifictionsInfo];
}

- (void)receiveNotificationsInfo
{
    if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
        return;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAllMessages:)
                                                 name:@"getAllUserMessages"
                                               object:nil];
}

- (void)removeNotifictionsInfo
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"getAllUserMessages"
                                                  object:nil];
}

- (void)updateNotificationsButtonImg
{
    if (![[MessagesManager sharedInstance] hasNewMessages])
    {
        [self.messageCenterBtn setImage:self.notificationsImg forState:UIControlStateNormal];
        return;
    }

    [self.messageCenterBtn setImage:self.notificationsNewImg forState:UIControlStateNormal];
}

- (NotificationsActionHelper *)notificationActionHelper
{
    if (_notificationActionHelper == nil)
    {
        _notificationActionHelper = [NotificationsActionHelper new];
    }
    return _notificationActionHelper;
}

- (void)setupImage
{
    UIImage *sortSelectedImage = [[self.sortButton imageForState:UIControlStateNormal] tintedImageWithColor:self.sortButton.tintColor];
    [self.sortButton setImage:sortSelectedImage forState:UIControlStateSelected];
    self.sortButton.selected = NO;
    self.notificationsImg = [UIImage imageNamed:@"notification"];
    self.notificationsNewImg = [UIImage imageNamed:@"notification_withdot"];
    if ([[MessagesManager sharedInstance] hasNewMessages])
    {
        [self.messageCenterBtn setImage:self.notificationsNewImg forState:UIControlStateNormal];
    }
}

#pragma mark - mask
-(UIVisualEffectView *)shadowView {
    if (_shadowView == nil) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _shadowView = [[UIVisualEffectView alloc] initWithEffect:blur];
        _shadowView.frame = self.view.bounds;
    }
    return _shadowView;
}

- (NSMutableArray *)roomTypesArr
{
    if (_roomTypesArr == nil)
    {
        _roomTypesArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _roomTypesArr;
}

- (void)loadCollectionView
{
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior  = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.layout = (HSCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    self.layout.delegate = self;
    self.layout.sectionHeadersPinToVisibleBounds = YES;
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:galleryStreamFakeHeaderFooterID];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:galleryStreamFakeHeaderFooterID];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:galleryStreamDefaultCellId];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GalleryStreamEmptyRoomHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:galleryStreamEmptyRoomHeaderID];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GalleryStreamEmptyRoomCell" bundle:nil] forCellWithReuseIdentifier:galleryStreamEmptyRoomCell];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GalleryStreamEmptyCell" bundle:nil] forCellWithReuseIdentifier:galleryStreamEmptyCellID];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GalleryStreamBannerCell" bundle:nil] forCellWithReuseIdentifier:galleryStreamBannerCellID];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GalleryStreamItemView" bundle:nil] forCellWithReuseIdentifier:galleryStreamItemCellID];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
        return 1;

    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.hasEmptyView)
    {
        return 1;
    }

    NSInteger items = [[[[GalleryStreamManager sharedInstance] getActiveGalleryFilterDO] loadedItems] count];
    if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
        return items;

    if (section == 0)
    {
        return 1;
    }

    return items;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 &&
        ![[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
    {
        GalleryStreamBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:galleryStreamBannerCellID forIndexPath:indexPath];
        cell.delegate = self;
        cell.bannerItem = self.sman.getBannerArray;
        return cell;
    }

    if (self.hasEmptyView)
    {
        GalleryStreamEmptyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:galleryStreamEmptyCellID forIndexPath:indexPath];
        cell.delegate = self;
        cell.emptyType = self.galleryStreamEmptyType;
        return cell;
    }

    NSArray *items = self.sman.getActiveGalleryFilterDO.loadedItems;
    if ([items count] > 0)
    {
        UICollectionViewCell * cellTemp = [collectionView dequeueReusableCellWithReuseIdentifier:galleryStreamEmptyRoomCell forIndexPath:indexPath];;
        GalleryItemDO * item = [items objectAtIndex:indexPath.row];
        if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
        {
            GalleryStreamEmptyRoomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:galleryStreamEmptyRoomCell forIndexPath:indexPath];
            item.type = eEmptyRoom;
            cell.item = item;
            cell.delegate = self;
            cellTemp = cell;
        }
        else
        {
            GalleryStreamItemView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:galleryStreamItemCellID forIndexPath:indexPath];
            item.type = e3DItem;
            cell.delegate = self;
            cell.item = item;
            cellTemp = cell;
        }
        if (indexPath.row + [[ConfigManager sharedInstance] numCellsBeforeNextBulkGallery] > [items count]
            && [[[AppCore sharedInstance] getGalleryManager] canLoadMoreDesignItems])
        {
            [[GalleryStreamManager sharedInstance] getNextBulkOfDesignsForActiveFilter:^(id serverResponse, id error) {
                if (serverResponse) {
                    GalleryFilterDO* filter=(GalleryFilterDO*)serverResponse;

                    if(filter.errorCode==-1 && [filter.loadedItems count]>0)
                        [self refreshCollection];
                }
            } queue:dispatch_get_main_queue()];
        }
        return cellTemp;
    }
    UICollectionViewCell *defaultCell = [collectionView dequeueReusableCellWithReuseIdentifier:galleryStreamDefaultCellId forIndexPath:indexPath];
    return defaultCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath;
{
    if (![kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:galleryStreamFakeHeaderFooterID forIndexPath:indexPath];
        view.frame = CGRectZero;
        return view;
    }

    if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
    {
        self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:galleryStreamEmptyRoomHeaderID forIndexPath:indexPath];
        self.headerView.roomTypesArr = self.roomTypesArr;
        self.headerView.delegate = self;
        return self.headerView;
    }

    if (indexPath.section == 0)
    {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:galleryStreamFakeHeaderFooterID forIndexPath:indexPath];
        view.frame = CGRectZero;
        return view;
    }

    self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:galleryStreamHeaderViewID forIndexPath:indexPath];
    self.headerView.sortTypesArr = self.sortTypesArr;
    self.headerView.roomTypesArr = self.roomTypesArr;
    self.headerView.delegate = self;
    return self.headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat headerHeight = galleryStreamHeaderViewHeight;
    CGFloat margin = self.layout.sectionInset.left;
    CGFloat spacing = self.layout.minimumInteritemSpacing;
    CGFloat collectionViewWidth = [UIScreen mainScreen].bounds.size.width - margin * 2;
    CGFloat columns = [self collectionView:collectionView layout:collectionViewLayout columnCountForSection:indexPath.section];
    if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
    {
        if (self.hasEmptyView)
        {
            CGFloat height = self.collectionView.bounds.size.height - headerHeight;
            if (height < 260) {
                height = 260;
            }
            return CGSizeMake(collectionViewWidth, height);
        }
        CGFloat itemWidth = (collectionViewWidth - (columns - 1) * spacing) / columns;
        return CGSizeMake(itemWidth, itemWidth * self.emptyRoomDesignImgAspect);
    }

    if (indexPath.section == 0)
    {
        return CGSizeMake(collectionViewWidth, collectionViewWidth * self.bannerImgAspect);
    }

    if (self.hasEmptyView)
    {
        CGFloat height = self.collectionView.bounds.size.height - headerHeight - collectionViewWidth * self.bannerImgAspect - spacing * 3;
        if (height < 260) {
            height = 260;
        }
        return CGSizeMake(collectionViewWidth, height);
    }

    NSArray *items = [GalleryStreamManager sharedInstance].getActiveGalleryFilterDO.loadedItems;
    if ([items count] == 0)
        return CGSizeZero;

    CGFloat designerViewHeight = 50;
    CGFloat optionViewHeight = 44;
    CGFloat cellWidth = (collectionViewWidth - (columns - 1) * spacing) / columns;
    CGFloat cellHeight = cellWidth * galleryStreamDesignImgAspect + designerViewHeight + optionViewHeight;

    GalleryItemDO *item = [items objectAtIndex:indexPath.row];
    CGFloat extraHeight = [GalleryStreamItemView calcDesignDescrtiptionTextHeightForDesign:item cellWidth:cellWidth];
    cellHeight += extraHeight;

    return CGSizeMake(cellWidth, cellHeight);
}

#pragma mark - HSCollectionViewWaterfallLayoutDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView
                     layout:(UICollectionViewLayout *)collectionViewLayout
      columnCountForSection:(NSInteger)section
{
    if (self.hasEmptyView)
        return 1;

    if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
    {
        return IS_IPAD ? 3 : 2;
    }

    if (section == 0)
        return 1;

    if (IS_IPAD && section == 1)
        return 2;

    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
 heightForHeaderInSection:(NSInteger)section
{
    if (section == 0
        && ![[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
        return 0;

    return galleryStreamHeaderViewHeight;
}

#pragma mark - UICollectionViewDeleagte
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 1 && ![[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
    {
        return;
    }

    if (self.hasEmptyView)
        return;

    NSArray *items = self.sman.getActiveGalleryFilterDO.loadedItems;
    if (items.count == 0)
        return;

    GalleryItemDO *item = [items objectAtIndex:indexPath.row];
    [self designPressed:item];
}


#pragma mark - GalleryStreamHeaderViewDelegate
- (void)popoverViewWithPopoverType:(PopOverType)popoverType withButton:(UIButton *)sender
{
    PopOverViewController *popoverViewController = nil;
    CGFloat tableViewHeight_iPhone = 135;
    switch (popoverType) {
        case kPopOverSort:
        {
            popoverViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"SortTypesViewController" inStoryboard:kGalleryStoryboard];
            if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
            {
                tableViewHeight_iPhone = 88;
            }
            [popoverViewController setDataArray:self.sortTypesArr];
            [popoverViewController setCurrentSelectedKey:self.selectedSortTypeKey];
            self.sortTypesPopover = popoverViewController;
            break;
        }
        case kPopOverRoom:
        {
            popoverViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"RoomTypesViewController" inStoryboard:kGalleryStoryboard];
            [popoverViewController setDataArray:self.roomTypesArr];
            [popoverViewController setCurrentSelectedKey:self.selectedRoomTypeKey];
            self.roomTypesPopover = popoverViewController;
            tableViewHeight_iPhone = 286;
            break;
        }
        default:
            break;
    }
    popoverViewController.delegate = self;
    popoverViewController.popOverType = popoverType;
    if (IS_IPAD)
    {
        if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
        {
            popoverViewController.preferredContentSize = CGSizeMake(300, tableViewHeight_iPhone);
        }
        popoverViewController.modalPresentationStyle = UIModalPresentationPopover;
        popoverViewController.popoverPresentationController.sourceView = sender;
        popoverViewController.popoverPresentationController.sourceRect = sender.bounds;
        popoverViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        popoverViewController.popoverPresentationController.delegate = self;
        [self presentViewController:popoverViewController animated:YES completion:nil];
    }
    else
    {
        CGRect rect = [self.view convertRect:sender.frame fromView:sender.superview];
        CGFloat filterViewY = rect.origin.y + sender.superview.frame.size.height;
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        [popoverViewController.view setFrame:CGRectMake(0, filterViewY, screenSize.width, tableViewHeight_iPhone)];

        UIButton *maskView = [UIButton buttonWithType:UIButtonTypeCustom];
        maskView.frame = CGRectMake(0, filterViewY + tableViewHeight_iPhone, screenSize.width, screenSize.height - filterViewY - tableViewHeight_iPhone);
        maskView.backgroundColor = [UIColor colorWithRed:69.0/255 green:69.0/255 blue:69.0/255 alpha:0.3];
        [maskView addTarget:self action:@selector(backgroundTap) forControlEvents:UIControlEventTouchUpInside];
        [self.background addSubview:maskView];

        [self.view addSubview:self.background];
        [self.view addSubview:popoverViewController.view];
    }
}

- (void)showFilterList:(UIButton *)sender
{
    [self popoverViewWithPopoverType:kPopOverSort withButton:sender];
}

- (void)showRoomTypeList:(UIButton *)sender
{
    [self popoverViewWithPopoverType:kPopOverRoom withButton:sender];
}

- (void)selectedRoomKey:(NSString *)key Value:(NSString *)value;
{
    [self roomTypeSelectedKey:key value:value];
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController; {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamType3D])
        {
            [self receiveNotificationsInfo];
        }
        self.sortButton.selected = NO;
        [self.shadowView removeFromSuperview];
        [self.headerView setFilterButtonState:NO];
        [self.headerView setRoomTypesButtonState:NO];
    });
}

#pragma mark - GalleryStreamBannerCellDelegate
- (void)openBannerLink:(NSString *)bannerUrl
{
    if (bannerUrl == nil)
        return;

    [self removeNotifictionsInfo];
    GenericWebViewBaseViewController * web = [[UIManager sharedInstance] createGenericWebBrowser:bannerUrl];
    web.displayPortrait = YES;
    if (IS_IPHONE)
    {
        [self.navigationController pushViewController:web animated:YES];
    }else
    {
        __weak typeof(self) weakSelf = self;
        web.preferredContentSize = CGSizeMake(449, 550);
        web.modalPresentationStyle = UIModalPresentationPopover;
        web.popoverPresentationController.permittedArrowDirections = 0;
        web.popoverPresentationController.sourceView=self.view;
        web.popoverPresentationController.sourceRect = CGRectMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2, 0 , 0);
        web.popoverPresentationController.delegate = self;
        [self presentViewController:web animated:YES completion:^{
            [weakSelf.view addSubview:weakSelf.shadowView];
        }];
    }
#ifdef USE_FLURRY
//    [HSFlurry logAnalyticEvent:EVENT_BANNER_CLICKED withParameters:@{EVENT_ACTION_BANNER_NAME:bannerUrl}];
#endif
}

#pragma mark - GalleryStreamItemViewDelegate
- (void)showUserProfile:(NSString *)userId
{
    if ([NSString isNullOrEmpty:userId] || [userId isEqualToString:[ConfigManager getCompanyDesignerUid]])
        return;

    ProfileViewController* profileViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileViewController" inStoryboard:kNewProfileStoryboard];
    profileViewController.userId = userId;
    UserProfile *userProfile = [[UserProfile alloc] init];
    userProfile.userId = userId;
    profileViewController.userProfile = userProfile;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)shareDesign:(GalleryItemDO *)item withDesignImage:(UIImage *)image
{
    if (image == nil) {
        return;
    }

    if (self.shareActionHelper == nil) {
        self.shareActionHelper = [DesignItemShareActionHelper new];
    }

    [self.shareActionHelper shareDesign:item withDesignImage:image fromViewController:self withDelegate:self loadOrigin:EVENT_PARAM_VAL_UISOURCE_DESIGN_STREAM];
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

#pragma mark - GalleryStreamEmptyViewDelegate
- (void)signIn
{
    __weak typeof(self) weakSelf = self;
    [[UserManager sharedInstance] showLoginFromViewController:self
                                              eventLoadOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_FOLLOWING_FEED
                                                preLoginBlock:^{
//                                                    [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:
//                                                     @{EVENT_PARAM_SIGNUP_TRIGGER:EVENT_PARAM_VAL_LOAD_ORIGIN_FOLLOWING_FEED,
//                                                       EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_VAL_LOAD_ORIGIN_FOLLOWING_FEED}];
                                                }
                                              completionBlock:^(BOOL success) {
                                                  if (success && weakSelf != nil) {
                                                      [weakSelf refreshFiltersAfterSelection];
                                                  }
                                              }];
}

#pragma mark - PopoverDelegate
- (void)roomTypeSelectedKey:(NSString*)key value:(NSString*)value{
    [self.background removeFromSuperview];
    [self hideRoomTypesList];

    if([self.selectedRoomTypeKey isEqualToString:key])
    {
        return;
    }
    
    self.selectedRoomTypeKey = key;
    //statistics
    [[GalleryStreamManager sharedInstance] roomTypeSelected:key :value ];
    if (![[UserManager sharedInstance] isLoggedIn]
        && [[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamType3D]
        && [self.selectedSortTypeKey isEqualToString:@"2"])
    {
        self.galleryStreamEmptyType = GalleryStreamEmptyNotSignIn;
        self.hasEmptyView = YES;
        [self refreshCollection];
        return;
    }
    [self refreshFiltersAfterSelection];
}

- (void)sortTypeSelectedKey:(NSString*)key value:(NSString*)value {
    [self.background removeFromSuperview];

    if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
    {
        self.sortButton.selected = NO;
    }
    
    [[UIMenuManager sharedInstance] setCurrentSortTypeFilter:key];

    [self hideFilterList];
    if ([self.selectedSortTypeKey isEqualToString:key])
    {
        return;
    }

    self.selectedSortTypeKey = key;
    //statistics
    [[GalleryStreamManager sharedInstance] sortTypeSelected:key];
    if ([key isEqualToString:@"2"]
        && ![[UserManager sharedInstance] isLoggedIn]
        && [[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamType3D])
    {
        self.galleryStreamEmptyType = GalleryStreamEmptyNotSignIn;
        self.hasEmptyView = YES;
        [self refreshCollection];
        return;
    }

    [self refreshFiltersAfterSelection];
}

#pragma mark - Class functions
-(void) resetFiltersAndSortButtons{
    [self setStreamType:[GalleryStreamManager sharedInstance].getActiveGalleryFilterDO.filterType];
    self.selectedSortTypeKey = @"1";
}

-(void)setStreamType:(NSString*) type
{
    b2Dselected = NO;
    b3Dselected = NO;
    bArticleSelected = NO;
    bEmptySelected = NO;
    [self.sortTypesArr removeAllObjects];
    if ([type isEqualToString:DesignStreamTypeEmptyRooms] ) {
        _roomTypeTitle.text = NSLocalizedString(@"Empty_Rooms", @"");
        self.sortButton.hidden = NO;
        self.messageCenterBtn.hidden = YES;
        self.sortTypesArr = [self setupEmptySort];
    }
    if ([type isEqualToString:DesignStreamType3D]) {
        _roomTypeTitle.text =NSLocalizedString(@"Sample_Rooms", @"");
        self.sortButton.hidden = YES;
        self.messageCenterBtn.hidden = NO;
        self.sortTypesArr = [self setupCommunityFilter];
    }
    
    if( [type isEqualToString:DesignStreamTypeEmptyRooms]
       || ([type isEqualToString:DesignStreamType3D] && [[ConfigManager getTenantIdName] isEqualToString:@"ezhome"])) // TODO: Append the condition temporily
    {
        b3Dselected = YES;
    }
    
    NSRange range = [type rangeOfString:DesignStreamType3D];
    if (range.location != NSNotFound)
    {
        b3Dselected = YES;
        [[UIMenuManager sharedInstance] updateMenuOptionSelectionIndex:kMenuOptionTypeDesignStream3D];
        
    }
    range = [type rangeOfString:DesignStreamType2D];
    if (range.location != NSNotFound )
    {
        b2Dselected = YES;
        [[UIMenuManager sharedInstance] updateMenuOptionSelectionIndex:kMenuOptionTypeDesignStream2D];
        
    }
    range = [type rangeOfString:DesignStreamTypeArticles];
    if (range.location != NSNotFound )
    {
        bArticleSelected = YES;
        [[UIMenuManager sharedInstance] updateMenuOptionSelectionIndex:kMenuOptionTypeDesignStreamArticle];
    }
    range = [type rangeOfString:DesignStreamTypeEmptyRooms];
    if (range.location != NSNotFound )
    {
        bEmptySelected = YES;
    }
}

-(void)createFilters{
    [self.roomTypesArr removeAllObjects];
    [self setupRoomTypesArr:[[GalleryStreamManager sharedInstance] defaultRoomTypes]];
    __weak typeof(self) weakSelf = self;
    [[GalleryStreamManager sharedInstance] getRoomTypesWithCompletionBlock:^(NSArray *arrRoomTypes){
        [weakSelf setupRoomTypesArr:arrRoomTypes];
         dispatch_async(dispatch_get_main_queue(), ^{
             self.selectedRoomTypeKey =  @"";
             [self refreshCollection];
         });
     } failureBlock:^ (NSError *error){
         HSMDebugLog(@"ERROR %@", error);
     }];
}

- (void)setupRoomTypesArr:(NSArray *)arrRoomTypes
{
    [self.roomTypesArr removeAllObjects];
    NSArray *roomTypesArr = arrRoomTypes;
    NSMutableArray *roomTypes = [NSMutableArray array];
    self.roomTypesEvailable = YES;
    if ([arrRoomTypes count] == ONLY_ONE_OPTION) {

        [roomTypes addObjectsFromArray:roomTypesArr];
    }else{
        RoomTypeDO *room = [[RoomTypeDO alloc] init];
        room.myId = @"";
        room.desc = NSLocalizedString(@"all_filter", @"All");
        [roomTypes addObject:room];
        [roomTypes addObjectsFromArray:roomTypesArr];
    }
    self.roomTypesArr = [roomTypes mutableCopy];
}

- (NSMutableArray *)setupCommunityFilter
{
    NSMutableArray *dictTypes = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *filterTypeList = @[NSLocalizedString(@"design_published", nil), NSLocalizedString(@"profile_tab_following", nil), NSLocalizedString(@"new_sort", nil)];
    NSArray *filterTypeId = @[@"1",@"2",@"3"];
    for (NSInteger i = 0; i < filterTypeList.count; i++)
    {
         NSMutableDictionary *dictType = [[NSMutableDictionary alloc] initWithCapacity:0];
         [dictType setObject:filterTypeList[i] forKey:@"d"];
         [dictType setObject:filterTypeId[i] forKey:@"id"];
         [dictTypes addObject:dictType];
    }
    return dictTypes;
}

- (NSMutableArray *)setupEmptySort
{
    NSMutableArray *dictTypes = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *filterTypeList = @[NSLocalizedString(@"default_sort", nil), NSLocalizedString(@"popularity_sort", nil)];
    NSArray *filterTypeId = @[@"1",@"2"];
    for (NSInteger i = 0; i < filterTypeList.count; i++)
    {
        NSMutableDictionary *dictType = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dictType setObject:filterTypeList[i] forKey:@"d"];
        [dictType setObject:filterTypeId[i] forKey:@"id"];
        [dictTypes addObject:dictType];
    }
    return dictTypes;
}

-(void)onGetGalleryItemsCompletionWithState:(BOOL) state
{
    if(state == NO)
    {
        [[ProgressPopupBaseViewController sharedInstance] setServerErrorMode];
        return;
    }
    
    [[ProgressPopupBaseViewController sharedInstance] stopLoading];
    [self.collectionView setContentOffset:CGPointZero];
    GalleryFilterExtraDO *extraData = [GalleryStreamManager sharedInstance].getActiveGalleryFilterDO.extraData;
    if (extraData.followingCount == 0
        && [self.selectedSortTypeKey isEqualToString:@"2"] 
        && ![[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
    {
        self.galleryStreamEmptyType = GalleryStreamEmptyNoFollowing;
        self.hasEmptyView = YES;
        [self refreshCollection];
        return;
    }

    NSInteger count = [[GalleryStreamManager sharedInstance].getActiveGalleryFilterDO.loadedItems count];
    if (count == 0)
    {
        if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
        {
            self.galleryStreamEmptyType = GalleryStreamEmptyNoEmptyRoom;
        }
        else if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamType3D])
        {
            self.galleryStreamEmptyType = GalleryStreamEmptyNoDesign;
        }
        self.hasEmptyView = YES;
        [self refreshCollection];
        return;
    }

    self.hasEmptyView = NO;
    [self refreshCollection];
}

-(void)virtualClearObservers{
    //implement in son's
}

-(void)virtualAddObservers{
    //implement in son's
}

- (void)refreshCollection
{
    [self virtualClearObservers];
    [self.collectionView reloadData];
    [self virtualAddObservers];
}

-(BOOL) isEmptyRoomsGalleryMode{
    return self.isStreamOfEmptyRooms;
}

#pragma mark - MessagesViewControllerDelegate
- (void)popoverViewDidDismiss
{
    [self removeNotifictionsInfo];
    [self receiveNotificationsInfo];
}

#pragma mark - Actions
- (IBAction)scrollToTop:(id)sender {
    [self.collectionView setContentOffset:CGPointZero animated:YES];
}

- (IBAction)backPressed:(id)sender {
    [[UIMenuManager sharedInstance] backPressed:sender];
}

- (IBAction)checkNoticeList:(UIButton *)sender
{
    [self.messageCenterBtn setImage:self.notificationsImg forState:UIControlStateNormal];
    [self.notificationActionHelper showNotificationsListFromViewController:self withDelegate:self];
#ifdef USE_FLURRY
//    [HSFlurry logAnalyticEvent:EVENT_NAME_NOTIFICATIONS_UI_OPEN withParameters:@{EVENT_PARAM_UI_ORIGIN:EVENT_PARAM_VAL_UISOURCE_COMMUNITY}];
#endif
}

- (IBAction)sortEmptyRoomType:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self popoverViewWithPopoverType:kPopOverSort withButton:sender];
}

- (void) refreshFiltersAfterSelection
{
    NSString* tmpFilter;
    BOOL bFirst = YES;
    if(b2Dselected )
    {
        tmpFilter = @"2";
        bFirst = NO;
    }
    
    if(b3Dselected)
    {
        if(bFirst == YES){
            tmpFilter = @"1";
        }else{
            tmpFilter = [tmpFilter stringByAppendingString: @",1"];
        }
        bFirst = NO;
    }
    
    if(bArticleSelected )
    {
        if(bFirst == YES)
        {
            tmpFilter = @"3";
        }
        else
        {
            tmpFilter = [tmpFilter stringByAppendingString: @",3"];
        }
        bFirst = NO;
    }
    
    if(bEmptySelected)
    {
        tmpFilter = @"4";
        bFirst = NO;
    }
    
    //add loading to Gallery Stream
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
    
    NSString *sortBy = [[UIMenuManager sharedInstance] getSortTypeForDesignStreamType:_selectedSortTypeKey];

    for (UIViewController * vc in [[[UIManager sharedInstance] pushDelegate].navigationController viewControllers]) {
        if ([vc isKindOfClass:[GalleryStreamBaseController class]]) {
            GalleryStreamBaseController * gsbVC = (GalleryStreamBaseController*)vc;
            
            [[GalleryStreamManager sharedInstance] refreshDataStream:tmpFilter
                                                         andRoomType:_selectedRoomTypeKey
                                                           andSortBy:sortBy
                                                           galleryVC:gsbVC];
            
        }
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    if ([identifier isEqualToString:@"sortTypesSegue"] && self.roomTypesEvailable==NO) {
        return NO;
    }
    
    if ([identifier isEqualToString:@"roomTypesSegue"] && self.roomTypesEvailable==NO) {
        return NO;
    }
    return YES;
}

-(NSString*)getEventOriginForItemType:(GalleryItemDO*)item
{
    NSString * origin = nil;
    
    switch (item.type) {
        case eArticle:
            origin = EVENT_PARAM_VAL_LOAD_ORIGIN_MAGAZINE;
            break;
        case e3DItem:
            origin = EVENT_PARAM_VAL_LOAD_ORIGIN_3DSTREAM;
            break;
        case e2DItem:
            origin = EVENT_PARAM_VAL_LOAD_ORIGIN_2DSTREAM;
            break;
        case eEmptyRoom:
            origin = EVENT_PARAM_VAL_LOAD_ORIGIN_NEWDESIGN;
            break;
        default:
            break;
    }
    
    if (self.isStreamOfEmptyRooms)
    {
        origin = EVENT_PARAM_VAL_LOAD_ORIGIN_NEWDESIGN;
    }
    
    return origin;
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

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[GalleryStreamItemView class]])
            {
                GalleryStreamItemView *cell = (GalleryStreamItemView *)obj;
                if ([cell.item._id isEqualToString:designItem._id])
                {
                    [cell updateLikeStatus];
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
            if ([obj isKindOfClass:[GalleryStreamItemView class]])
            {
                GalleryStreamItemView *cell = (GalleryStreamItemView *)obj;
                if ([cell.item._id isEqualToString:designItem._id])
                {
                    [cell updateCommentsCount];
                }
            }
        }];
    });
}

- (DesignBaseClass *)getDesignItemById:(NSString *)designId {
    NSArray *items = self.sman.getActiveGalleryFilterDO.loadedItems;
    for (NSInteger i = 0; i < items.count; i++) {
        DesignBaseClass * designItem = [items objectAtIndex:i];
        if ([designItem._id isEqualToString:designId])
            return designItem;
    }
    return nil;
}

-(void)refreshDataStream
{
    [self refreshCollection];
}

#pragma mark - Messages
- (void)showAllMessages:(NSNotification *)notification
{
    if (![[MessagesManager sharedInstance] hasNewMessages])
        return;

    [self updateNotificationsButtonImg];

    NSArray *notificationsLsit = notification.userInfo[@"messages"];
    [self.notificationActionHelper showBubbleView:BubbleView_Community withSourceView:self.messageCenterBtn withNotificationsInfo:notificationsLsit fromViewController:self];
}

- (void)setOfflineIndicatorAccordingToNetworkStatus
{
    [_offlineIcon setHidden:[ConfigManager isAnyNetworkAvailable]];
}


-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

-(void)backgroundTap {
    self.sortButton.selected = NO;
    [self.background.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.background removeFromSuperview];
    [self hideFilterList];
    [self hideRoomTypesList];
}

- (void)hideFilterList {
    if (IS_IPAD) {
        [self.sortTypesPopover dismissViewControllerAnimated:NO completion:nil];
    } else {
        [self.sortTypesPopover.view removeFromSuperview];
    }

    [self.headerView setFilterButtonState:NO];
}

- (void)hideRoomTypesList {
    if (IS_IPAD) {
        [self.roomTypesPopover dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.roomTypesPopover.view removeFromSuperview];
    }
    [self.headerView setRoomTypesButtonState:NO];
}

@end

