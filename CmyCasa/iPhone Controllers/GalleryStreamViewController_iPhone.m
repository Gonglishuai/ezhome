///
//  GalleryStreamViewController_iPhone.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/9/13.
//
//

#import "GalleryStreamViewController_iPhone.h"
#import "GalleryStreamHeaderView_iPhone.h"
#import "GalleryStreamEmptyRoomHeaderView.h"
#import "DesignStreamCell.h"
#import "GalleryItemDO.h"
#import "HSNUIIconLabelButton.h"
#import "MessagesViewController.h"
#import "RoomTypeDO.h"
#import "FullScreenViewController_iPhone.h"
#import "CommentsViewController_iPhone.h"
#import "ControllersFactory.h"
#import "BannerCell.h"
#import "GalleryBanner.h"
#import "ProgressPopupBaseViewController.h"
#import "NSString+Contains.h"
#import "EmptyRoomPopoverViewController.h"

static NSString *const galleryStreamHeaderCellID_iPhone = @"GalleryStreamHeaderViewCellID";

static const CGFloat galleryStreamBannerImgAspect_iPhone = 220.0/640;
static const CGFloat galleryStreamEmptyRoomDesignImgAspect_iPhone = 1.0;

#define DESIGN_STREAM_FILTER NSLocalizedString(@"design_stream_filter", @"")
#define DESIGN_STREAM_CLOSE NSLocalizedString(@"design_stream_Close", @"")
#define ANIMATION_DURATION 0.25f
#define DESIGNSTREAM_CELL_BOTTOMBAR_HEIGHT 85
#define DESIGNSTREAM_CELL_IMAGE_ASPECT_RATIO 0.5625
#define DESIGNSTREAM_CELL_BANNER_IMAGE_ASPECT_RATIO 0.343

@interface GalleryStreamViewController_iPhone () <DesignStreamCellDelegate,EmptyRoomPopoverDelegate>

@property(nonatomic) NSInteger selectedComponentIndex;

@end

@implementation GalleryStreamViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedComponentIndex = 0;
    self.bannerImgAspect = galleryStreamBannerImgAspect_iPhone;
    self.emptyRoomDesignImgAspect = galleryStreamEmptyRoomDesignImgAspect_iPhone;
    [self.collectionView registerNib:[UINib nibWithNibName:@"GalleryStreamHeaderView_iPhone" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:galleryStreamHeaderCellID_iPhone];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIMenuManager sharedInstance] setIsMenuOpenAllowed:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown;
}

-(void)dealloc{
    NSLog(@"dealloc - GalleryStreamViewController_iPhone");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - HSCollectionViewWaterfallLayoutDelegate
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 0 && ![[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
    {
        return UIEdgeInsetsMake(10, 16, 10, 16);
    }
    
    return UIEdgeInsetsMake(10, 16, 10, 16);
}

#pragma mark - DesignItemDelegate
- (void)designPressed:(GalleryItemDO *)design {
    if (IS_IPAD || ![[self getEventOriginForItemType:design] isEqualToString:EVENT_PARAM_VAL_LOAD_ORIGIN_NEWDESIGN] ) {
        [self gotoTheDesignForIpad:design];
    }else{
        [self displayEmptyRoom:design];
    }
}

-(void)gotoTheDesignForIpad:(GalleryItemDO *)design {
    NSArray *items = [GalleryStreamManager sharedInstance].getActiveGalleryFilterDO.loadedItems;
    if ([items count] == 0)
        return;

    NSString *origin = [self getEventOriginForItemType:design];
    NSInteger idx = [items indexOfObject:design];
    FullScreenViewController_iPhone *fullScreen = [[UIManager sharedInstance] createIphoneFullScreenGallery:items
                                                                                          withSelectedIndex:idx
                                                                                                eventOrigin:origin];
    fullScreen.sourceViewController = self;
    if (self.isStreamOfEmptyRooms) {
        fullScreen.dataSourceType = eFScreenEmptyRooms;
    } else {
        fullScreen.dataSourceType = eFScreenGalleryStream;
    }
    [self.navigationController pushViewController:fullScreen animated:YES];
}

-(void)displayEmptyRoom:(GalleryItemDO *)design {
    EmptyRoomPopoverViewController *emptyPopCtr = [ControllersFactory instantiateViewControllerWithIdentifier:@"EmptyRoomPopover"inStoryboard:kGalleryStoryboard];
    emptyPopCtr.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    emptyPopCtr.popoverPresentationController.sourceView = self.view;
    emptyPopCtr.delegate = self;
    emptyPopCtr.itemDetail = design;
    [self presentViewController:emptyPopCtr animated:NO completion:nil];
}

#pragma mark - EmptyRoomPopoverDelegate
-(void)startRedesignImages:(UIImage *)original background:(UIImage *)background mask:(UIImage *)mask needMask:(BOOL)needMask {
    if( original && background && needMask)
    {
        [[UIManager sharedInstance] galleryDesignBGImageRecieved:background andOrigImage:original andMaskImage:mask];
    }
}


- (IBAction)scrollToTopStream:(id)sender {
    [self.collectionView setContentOffset:CGPointZero animated:YES];
}

-(void)refreshDataStream{

    [[ProgressPopupBaseViewController sharedInstance] startLoading :self];
    [super refreshDataStream];
}

-(void)sortTypeSelectedKey:(NSString*)key value:(NSString*)value
{
    [[UIMenuManager sharedInstance] setIsUserChangedFilter:YES];
    [self.headerView setFilterType:value];
    [super sortTypeSelectedKey:key value:value];
}

-(void)roomTypeSelectedKey:(NSString*)key value:(NSString*)value
{
    if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
    {
        [((GalleryStreamEmptyRoomHeaderView *)self.headerView) updateEmptyRoomPosition:key];
    }
    else
    {
        GalleryStreamHeaderView_iPhone *iPhoneHeaderView = (GalleryStreamHeaderView_iPhone *)self.headerView;
        [iPhoneHeaderView setRoomType:value];
    }
    [super roomTypeSelectedKey:key value:value];
}

#pragma mark - GalleryStreamViewControllerDelegate
- (NSString*)getItemID:(int)itemPos{
    return nil;
}

- (int)getGalleryItemLikesCount:(int)itemPos{
    return 0;
}

- (BOOL)isEmptyRoomsGalleryMode{
    return NO;
}

-(void)likeButtonPressedForDesign:(GalleryItemDO*)item{
    
    if (![ConfigManager isAnyNetworkAvailable]) {
        [ConfigManager showMessageIfDisconnected];
        return;
    }
    
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:item._id];
    
    BOOL isLiked=likeDO.isUserLiked;
    [[DesignsManager sharedInstance] likeDesign:item : !isLiked :self :NO withCompletionBlock:^(id serverResponse) {
    }];
}

-(void)profileButtonPressedForDesign:(GalleryItemDO*)item{
    
    if (!item) return;
    if(item.type==e3DItem) {
        [[UIMenuManager sharedInstance] openProfilePageForsomeUser:item.uid];
        [[UIMenuManager sharedInstance] updateMenuSelectionIndexAccordingToUserId:item.uid];
    }
    else if (item.type==e2DItem) {
        [[UIMenuManager sharedInstance] openProfessionalByID:item.uid];
        [[UIMenuManager sharedInstance] updateMenuSelectionIndexAccordingToUserId:item.uid];
    }
}

- (void)imageUploadStarted
{
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
}

- (void)imageUploadFinished
{
    [[ProgressPopupBaseViewController sharedInstance] stopLoading];
}

- (UIViewController *)superViewContoller
{
    return self;
}

- (void)onGetGalleryItemsCompletion :(BOOL) bShowAlert withState:(BOOL) status
{
    [super onGetGalleryItemsCompletionWithState:status];
}

- (IBAction)checkMessagesDetail:(UIButton *)sender {
    if (![[UserManager sharedInstance] isLoggedIn])
    {
        [self signIn];
        return;
    }

    MessagesViewController *messageController = [[MessagesViewController alloc] init];
    [self.navigationController pushViewController:messageController animated:YES];
}


@end
