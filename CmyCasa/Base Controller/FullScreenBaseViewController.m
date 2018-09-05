//
//  FullScreenBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/21/13.
//
//

#import "FullScreenBaseViewController.h"
#import "GalleryImageViewController.h"
#import "GalleryArticleBaseViewController.h"
#import "MessagesViewController.h"
#import "MyDesignEditBaseViewController.h"
#import "ProfileUserListViewController.h"
#import "ProgressPopupViewController.h"

#import "MessagesManager.h"
#import "ControllersFactory.h"
#import "HSSharingLogic.h"
#import "ProtocolsDef.h"
#import "AppDelegate.h"

#import "GalleryArticleViewController_iPhone.h"

#import "ImageFetcher.h"

#import "DesignBaseClass.h"
#import "GalleryItemDO.h"
#import "ProfileUserListDesignLikes.h"

#import <MessageUI/MessageUI.h>

#import "BubbleEffectView.h"
#import "DesignItemLikeActionHelper.h"
#import "DesignItemShareActionHelper.h"
#import "NotificationsActionHelper.h"

#import "CoreRO.h"

#import "NotificationNames.h"

//#import "HSFlurry.h"

#import "NSObject+MultiShare.h"
#import "UIView+ReloadUI.h"
#import "UIImage+Scale.h"

#define CARD_TYPE_ARTICLE   (0)
#define CARD_TYPE_IMAGE     (1)
#define CARD_MAX_CACHE      (15)

#define BOTTOM_BAR_PADDING_IPAD     50
#define BOTTOM_BAR_PADDING_IPHONE   20

@interface FullScreenBaseViewController ()<MessagesViewControllerDelegate>

@property (nonatomic, strong) DesignItemLikeActionHelper* likeActionHelper;
@property (nonatomic, strong) DesignItemShareActionHelper* shareActionHelper;
@property (nonatomic, strong) NotificationsActionHelper *notificationsActionHelper;

@property (nonatomic, strong) UIImage *notificationsImg;
@property (nonatomic, strong) UIImage *notificationsNewImg;

@property (weak, nonatomic) IBOutlet UIButton *notificationsButton;

@end

@implementation FullScreenBaseViewController
{
    CGPoint _lastContentOffset;

    __weak IBOutlet UIView *_topBar;
    __weak IBOutlet UIView *_bottomBar;
    __weak IBOutlet UIView *_emptyRoomBottomBar;

    __weak IBOutlet UIButton *_designButton;

    __weak IBOutlet UIButton *_redesignButton;
    __weak IBOutlet UIButton *_shareButton;
    __weak IBOutlet UIButton *_commentButton;
    __weak IBOutlet UIButton *_likeButton;
    __weak IBOutlet UIButton *_editInfoButton;
    __weak IBOutlet UIButton *_moreActionsButton;   // phone only

    __weak IBOutlet NSLayoutConstraint *_redesignButtonLeading;
    __weak IBOutlet NSLayoutConstraint *_shareButtonLeading;
    __weak IBOutlet NSLayoutConstraint *_commentButtonLeading;
    __weak IBOutlet NSLayoutConstraint *_likeButtonLeading;
    __weak IBOutlet NSLayoutConstraint *_editInfoButtonLeading;
    __weak IBOutlet NSLayoutConstraint *_moreActionsButtonLeading;  // phone only
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.screenName = GA_FULLSCREEN_SCREEN;

    [_designButton setTitle:NSLocalizedString(@"start_design", @"") forState:UIControlStateNormal];

    UIColor* shadowColor = [UIColor colorWithRed:74/255.0 green:77/255.0 blue:83/255.0 alpha:0.4];
    _bottomBar.layer.shadowColor = shadowColor.CGColor;
    _emptyRoomBottomBar.layer.shadowColor = shadowColor.CGColor;


    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior  = UIScrollViewContentInsetAdjustmentNever;
    }

    self.visibleLayouts = [NSMutableArray array];

    [self addObservers];

    [self receiveNotificationsInfo];

    [self setupNotificationsButton];

    [self tileLayout:NO];


    [self setupGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self receiveNotificationsInfo];

    [self.view reloadUI];
    if (self.currentItemDelegate) {
        [self.currentItemDelegate setImageRequestedFromServer:NO];
        [self.currentItemDelegate loadUI];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self.scrollView setDelegate:nil];
    self.scrollView = nil;

    [self setCurrentItemDelegate:nil];
    [self.itemIdsArray removeAllObjects];
    self.itemIdsArray = nil;

    self.productInfo = nil;

    self.likeActionHelper = nil;
    self.shareActionHelper = nil;

    NSLog(@"dealloc - FullScreenBaseViewController");
}


-(void)addObservers{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(likePressedLoginResponseNotification:)
                                                 name:@"likePressedLoginResponse"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshSelectedFromDetail:)
                                                 name:@"RefreshFullScreenAfterDataDownloadNotification"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self.view
                                             selector:@selector(reloadUI)
                                                 name:@"NetworkStatusChanged" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAssetLikeStatus:) name:kNotificationAssetLikeStatusChanged object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showNotificationsInfoMini:)
                                                 name:@"getAllUserMessages"
                                               object:nil];
}

-(void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getAllUserMessages" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.view name:@"NetworkStatusChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshFullScreenAfterDataDownloadNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"likePressedLoginResponse" object:nil];
}

-(void)refreshSelectedFromDetail:(NSNotification*)notification {
    if ([[self.currentItemDelegate getItemID]isEqualToString:[notification object]]) {

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.currentItemDelegate respondsToSelector:@selector(reloadTable)]) {
                [self.currentItemDelegate reloadTable];
            }

            if ([self.currentItemDelegate respondsToSelector:@selector(resetImageLoading)]) {
                if ([self.currentItemDelegate isKindOfClass:[GalleryImageViewController class]]) {
                    GalleryImageViewController * imgv=(GalleryImageViewController*)self.currentItemDelegate;
                    [imgv resetImageLoading];
                }
            }

            [self presentCurrentDesign];

        });
    }
}

- (void)setupNotificationsButton
{
    self.notificationsImg = [UIImage imageNamed:@"notification"];
    self.notificationsNewImg = [UIImage imageNamed:@"notification_withdot"];
    if ([[MessagesManager sharedInstance] hasNewMessages])
    {
        [self.notificationsButton setImage:self.notificationsNewImg forState:UIControlStateNormal];
    }

    if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
    {
        self.notificationsButton.hidden = YES;
    }
}

-(void)setCurrentItemDelegate:(GalleryItemBaseViewController *)currentItemDelegate {
    _currentItemDelegate = currentItemDelegate;

    _bottomBar.hidden = self.dataSourceType == eFScreenEmptyRooms;
    _emptyRoomBottomBar.hidden = !_bottomBar.hidden;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{

    if ([alertView.message isEqualToString:NSLocalizedString(@"redesign_json_newer_alert", @"")]) {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[ConfigManager sharedInstance] versionStorelink]]];
            }
                break;
            default:

                break;
        }
    }
}

-(void)tileLayout:(BOOL)animated{

    if (self.itemIdsArray)
    {
        if (self.selectedItemIndex < [self.itemIdsArray count]) {
            [self loadImageTileAtIndex:self.selectedItemIndex iscurrent:YES];
        }

        if (self.selectedItemIndex-1 >= 0) {
            [self loadImageTileAtIndex:self.selectedItemIndex-1 iscurrent:NO];
        }

        if (self.selectedItemIndex+1 < [self.itemIdsArray count]) {
            [self loadImageTileAtIndex:self.selectedItemIndex+1 iscurrent:NO];
        }
//        if ([self.visibleLayouts count] < 3 && [self.itemIdsArray count] > 2) {
//
//            GalleryImageBaseViewController * it = [self getCardForType:CARD_TYPE_ARTICLE];
//            it.itemDetailsRequestNeeded = self.itemDetailsRequestNeeded;
//            [self addChildViewController:it];
//            [self.scrollView addSubview:it.view];
//
//            //check edges
//            if (self.selectedItemIndex==0) {
//
//                CGRect frm = it.view.frame;
//                frm.origin.x = (-1)*[self getScreenWidth];
//                frm.size.width = [self getScreenWidth];
//                frm.size.height = [self getScreenHeight];
//                it.view.frame = frm;
//
//                [self.visibleLayouts addObject:it];
//            }else if(self.selectedItemIndex == [self.itemIdsArray count]-1){
//
//                CGRect frm = it.view.frame;
//                frm.origin.x = (self.selectedItemIndex+1)*[self getScreenWidth];
//                frm.size.width = [self getScreenWidth];
//                frm.size.height = [self getScreenHeight];
//                it.view.frame = frm;
//
//                [self.visibleLayouts addObject:it];
//            }
//        }

    }

    //check oriantation before we set the scroller content size
    [self.scrollView setContentSize:CGSizeMake([self.itemIdsArray count]*[self getScreenWidth], [self getScrollViewHeight])];
    [self.scrollView setContentOffset:CGPointMake(self.currentItemDelegate.view.frame.origin.x, 0) animated:animated];
}

- (void)setupGesture
{
    NSArray *array = self.navigationController.view.gestureRecognizers;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
        {
            [self.scrollView.panGestureRecognizer requireGestureRecognizerToFail:obj];
        }
    }];
}

-(void)hideControls{
    //implement in sons
}

-(void)showControls{
    //implement in sons
}

-(void)loadImageTileAtIndex:(NSInteger)imageIndex iscurrent:(BOOL)isCurrent{

    if(imageIndex<[self.itemIdsArray count])
    {
        //what type is passed in
        DesignBaseClass* _item=[self.itemIdsArray objectAtIndex:imageIndex];

        GalleryItemBaseViewController * it = [self getCardForType:([_item isArticle] == YES) ? CARD_TYPE_ARTICLE : CARD_TYPE_IMAGE];

        it.itemDetailsRequestNeeded = self.itemDetailsRequestNeeded;
        it.eventLoadOrigin = self.eventLoadOrigin;
        it.itemDetailsPrivateURLNeeded = [_item isDesignBelongsToLoggedInUser];
        it.itemDetail.type = self.dataSourceType == eFScreenEmptyRooms ? eEmptyRoom : e3DItem;
        it.isCurrentVcDisplay = isCurrent;
        [it init:_item];

        if (self.isHelpArticle) {
            if ([it isKindOfClass:[GalleryArticleViewController_iPhone class]]) {
                GalleryArticleViewController_iPhone * gabVc = (GalleryArticleViewController_iPhone*)it;
                gabVc.hideBottomBarView = YES;
            }
        }

        [self addChildViewController:it];

        CGRect frm = it.view.frame;
        frm.origin.x = imageIndex * [self getScreenWidth];
        frm.size.width = [self getScreenWidth];
        frm.size.height = [self getScrollViewHeight];

        it.view.frame = frm;

        [self.scrollView addSubview:it.view];
        [self.visibleLayouts addObject:it];
        [it setIsCurrent:isCurrent forceUpdate:YES];

        if ([it respondsToSelector:@selector(reloadTable)]) {
            [it reloadTable];
        }

        if(isCurrent){
            [self setCurrentItemDelegate:it];
            [self presentCurrentDesign];
        }else{
            [it loadUI];
        }
    }
}

-(void) resetViewsToInitialState{
    [self hideProductInfoView];
}

-(void)pageChange{

    [self hideProductInfoView];

    if (self.selectedItemIndex >= [self.itemIdsArray count]) {
        HSMDebugLog(@"Out of range CRASH PREVENT!!!");
        return;
    }

    DesignBaseClass * _item = [self.itemIdsArray objectAtIndex:self.selectedItemIndex];

    for ( int i = 0 ; i < [self.visibleLayouts count] ; i++ )
    {
        GalleryItemBaseViewController * it = [self.visibleLayouts objectAtIndex:i];

        BOOL isCurrent = [it.getItemID isEqualToString:_item._id];
        [it setIsCurrent:isCurrent forceUpdate:NO];
        if (isCurrent)
        {
            [self setCurrentItemDelegate:it];

            [self presentCurrentDesign];

#ifdef USE_FLURRY
            if(ANALYTICS_ENABLED){
                NSArray * objs=[NSArray arrayWithObjects:it.getItemID,[NSNumber numberWithInt:_item.type], nil];
                NSArray * keys=[NSArray arrayWithObjects:@"designid",@"design_type",  nil];

//                [HSFlurry logEvent:FLURRY_DESIGN_STREAM_ITEM_VIEW withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
            }
#endif
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self pageChange];
}

- (void)editDesignInfo:(MyDesignDO *)designInfo {
    MyDesignEditBaseViewController *  _myDesignEditViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"MyDesignsEditViewController" inStoryboard:kNewProfileStoryboard];

    _myDesignEditViewController.design = designInfo;
    _myDesignEditViewController.delegate = self;

    [_myDesignEditViewController presentByParentViewController:self animated:YES completion:nil];
}

- (void)updateAssetLikeStatus:(NSNotification *)notification {
    NSString * itemId = [[notification userInfo] objectForKey:kNotificationKeyItemId];
    if (![self.currentItemDelegate.itemDetail._id isEqualToString:itemId])
        return;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.currentItemDelegate restoreLikeState];
    });
}

- (void)showNotificationsInfoMini:(NSNotification *)notification
{
    [self updateNotificationsButtonImg];

    NSArray *notificationsLsit = notification.userInfo[@"messages"];
    [self.notificationsActionHelper showBubbleView:BubbleView_DesignDetail withSourceView:self.notificationsButton withNotificationsInfo:notificationsLsit fromViewController:self];
}

- (void)receiveNotificationsInfo
{

    if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
        return;

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
        [self.notificationsButton setImage:self.notificationsImg forState:UIControlStateNormal];
        return;
    }

    [self.notificationsButton setImage:self.notificationsNewImg forState:UIControlStateNormal];
}

- (NotificationsActionHelper *)notificationsActionHelper
{
    if (_notificationsActionHelper == nil)
    {
        _notificationsActionHelper = [NotificationsActionHelper new];
    }
    return _notificationsActionHelper;
}

#pragma mark - actions
- (IBAction)showNotificationsList:(UIButton *)sender
{
    [self.notificationsButton setImage:self.notificationsImg forState:UIControlStateNormal];
    [self.notificationsActionHelper showNotificationsListFromViewController:self withDelegate:self];
#ifdef USE_FLURRY
//    [HSFlurry logAnalyticEvent:EVENT_NAME_NOTIFICATIONS_UI_OPEN withParameters:@{EVENT_PARAM_UI_ORIGIN:EVENT_PARAM_VAL_UISOURCE_DESIGN_DETAIL}];
#endif
}

- (IBAction)navBack:(id)sender {
    //remove parent delegate
    [self setCurrentItemDelegate:nil];

    //clear arrays
    [self.itemIdsArray removeAllObjects];
    self.itemIdsArray = nil;

    //clear visiblelayout
    [self clearVisibleLayout];

    //remove scroller delegate
    [self.scrollView setDelegate:nil];
    self.scrollView = nil;

    [self.currentItemDelegate clearUI];

    [self removeObservers];

    //clears temp comments that were created while user scrolling in full screen.
    [[[AppCore sharedInstance] getCommentsManager]clearTempcommentsFromDiscussions];

    //finally tells the gallery stream to refresh itself.

    self.currentItemDelegate = nil;

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)redesignPressed:(id)sender {
    //Set the comments view for it's initial frame
    if ([self.currentItemDelegate respondsToSelector:@selector(canRedesign)] && [self.currentItemDelegate canRedesign]) {
        if ([self.currentItemDelegate respondsToSelector:@selector(setCommentsViewForInitialFrame)]) {
            [self.currentItemDelegate setCommentsViewForInitialFrame];
        }
    }

    [self redesign:[self.currentItemDelegate getItemItself]];
}

- (IBAction)sharePressed:(id)sender {
    GalleryItemBaseViewController * imgvc = (GalleryItemBaseViewController*)self.currentItemDelegate;
    if (imgvc == nil)
        return;

    UIImage *image = [imgvc getCurrentPresentingImage];
    if (image == nil)
        return;

    if (self.shareActionHelper == nil) {
        self.shareActionHelper = [DesignItemShareActionHelper new];
    }

    [self.shareActionHelper shareDesign:imgvc.itemDetail withDesignImage:image fromViewController:self withDelegate:self loadOrigin:EVENT_PARAM_VAL_UISOURCE_FULL_SCREEN];
}

- (IBAction)commentPressed:(id)sender {
    //GalleryItemBaseViewController * imgvc = (GalleryItemBaseViewController*)self.currentItemDelegate;
    //imgvc.isTableMoved = YES;
    [self.currentItemDelegate createNewComment];
}

- (IBAction)likePressed:(id)sender {
    GalleryItemBaseViewController * imgvc = (GalleryItemBaseViewController*)self.currentItemDelegate;
    if (imgvc == nil)
        return;

    if (self.likeActionHelper == nil) {
        self.likeActionHelper = [DesignItemLikeActionHelper new];
        self.likeActionHelper.likeImage = [UIImage imageNamed:@"like_tab"];
        self.likeActionHelper.activeLikeImage = [UIImage imageNamed:@"like_active_tab"];
    }

    __weak typeof(imgvc) weakVc = imgvc;
    [self.likeActionHelper toggleLikeStateForDesign:imgvc.itemDetail
                                     withLikeButton:_likeButton
                                  andViewController:self
                                     preActionBlock:^{
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (weakVc == nil)
                                                 return;

                                             __strong typeof(imgvc) strongVc = weakVc;
                                             [strongVc toggleLikeState];
                                         });
                                     }
                                    completionBlock:^(NSString * designId, BOOL success) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if (weakVc == nil)
                                                return;

                                            __strong typeof(imgvc) strongVc = weakVc;
                                            if (success) {
                                            } else {
                                                // restore state if failed
                                                [strongVc restoreLikeState];
                                                [self setLikeButtonImage:[strongVc.itemDetail isUserLikesDesign]];
                                            }
                                        });
                                    }];
}

- (IBAction)editInfoPressed:(id)sender {
    MyDesignDO * designInfo = (MyDesignDO *)self.currentItemDelegate.itemDetail;
    [self editDesignInfo:designInfo];
}

- (IBAction)moreActionsPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Share", @"Share") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self sharePressed:nil];
    }];

    UIAlertAction *editInfoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"edit_info", @"Edit Info") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        MyDesignDO * designInfo = (MyDesignDO *)self.currentItemDelegate.itemDetail;
        [self editDesignInfo:designInfo];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"alert_msg_button_cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];

    [alert addAction:shareAction];
    [alert addAction:editInfoAction];
    [alert addAction:cancelAction];

    if (IS_IPAD) {
        [alert setModalPresentationStyle:UIModalPresentationFormSheet];

        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = _moreActionsButton;
        popPresenter.sourceRect = _moreActionsButton.bounds;
    }

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - MessagesViewControllerDelegate
- (void)popoverViewDidDismiss
{
    [self receiveNotificationsInfo];
}

#pragma mark - button state
- (void)setLikeButtonImage:(BOOL)isLiked {
    [_likeButton setImage:[UIImage imageNamed:isLiked ? @"like_active_tab" : @"like_tab"] forState:UIControlStateNormal];
}

- (void)updateLikeButtonState {
    GalleryItemBaseViewController * imgvc = (GalleryItemBaseViewController*)self.currentItemDelegate;

    [self setLikeButtonImage:[imgvc.itemDetail isUserLikesDesign]];
}

- (void)updateButtonsState {
    GalleryItemBaseViewController * imgvc = (GalleryItemBaseViewController*)self.currentItemDelegate;
    DesignBaseClass* designData = imgvc.itemDetail;

    CGFloat margin = (IS_IPAD) ? BOTTOM_BAR_PADDING_IPAD : BOTTOM_BAR_PADDING_IPHONE;
    NSInteger buttonCount = 4;
    if ([imgvc isOwner]) {
        if (designData.publishStatus == STATUS_PUBLIC) {
            buttonCount = (IS_IPAD) ? 5 : 4;
        } else if (designData.publishStatus == STATUS_PRIVATE) {
            buttonCount = 3;
        }
    }
    CGFloat buttonSpace = ([self getScreenWidth] - margin * 2) / buttonCount;
    CGFloat buttonLeading = (buttonSpace - _redesignButton.frame.size.width) * 0.5 + margin;
    CGFloat button1X = buttonLeading;
    CGFloat button2X = buttonLeading + buttonSpace;
    CGFloat button3X = buttonLeading + buttonSpace * 2;
    CGFloat button4X = buttonLeading + buttonSpace * 3;
    _redesignButtonLeading.constant = button1X;

    if ([imgvc isOwner] && designData.publishStatus == STATUS_PUBLIC) {
        // my public design
        _commentButton.hidden = NO;
        _likeButton.hidden = NO;
        if (IS_IPAD) {
            // redesign, edit info, share, comment, like
            CGFloat button5X = buttonLeading + buttonSpace * 4;
            _editInfoButton.hidden = NO;
            _shareButton.hidden = NO;
            _editInfoButtonLeading.constant = button2X;
            _shareButtonLeading.constant = button3X;
            _commentButtonLeading.constant = button4X;
            _likeButtonLeading.constant = button5X;
        } else {
            // redesign, comment, like, more
            _shareButton.hidden = YES;
            _editInfoButton.hidden = YES;
            _moreActionsButton.hidden = NO;
            _commentButtonLeading.constant = button2X;
            _likeButtonLeading.constant = button3X;
            _moreActionsButtonLeading.constant = button4X;
        }
    } else if ([imgvc isOwner] && designData.publishStatus == STATUS_PRIVATE) {
        // my private: redesign, edit info, share
        _commentButton.hidden = YES;
        _likeButton.hidden = YES;
        if (IS_IPHONE) {
            _moreActionsButton.hidden = YES;
        }
        _editInfoButton.hidden = NO;
        _shareButton.hidden = NO;
        _editInfoButtonLeading.constant = button2X;
        _shareButtonLeading.constant = button3X;
    } else {
        // other's public or my featured: redesign, share, comment, like
        _editInfoButton.hidden = YES;
        _commentButton.hidden = NO;
        _likeButton.hidden = NO;
        _shareButton.hidden = NO;
        if (IS_IPHONE) {
            _moreActionsButton.hidden = YES;
        }
        _shareButtonLeading.constant = button2X;
        _commentButtonLeading.constant = button3X;
        _likeButtonLeading.constant = button4X;
    }

    [_bottomBar setNeedsLayout];

    [self updateLikeButtonState];
}

#pragma mark --

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {

    if (error) {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@""
                                                      message:NSLocalizedString(@"save_image_failed_msg", @"Image save failed.") delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];


        [alert show];
    }else{
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@""
                                                      message:NSLocalizedString(@"save_image_success_msg", @"Image successfully saved.") delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
        [alert show];
    }

}

//Used for new ImageFetcher
-(void)getFullImages{

    NSString * bgImgURL = [self.currentItemDelegate getBGImageURL];
    NSString * origImgURL = [self.currentItemDelegate getOrigImageURL];
    __block NSString * maskImgURL = [self.currentItemDelegate getMaskImageURL];

    __block UIImage * imgBG = nil;
    __block UIImage * origImg = nil;
    __block UIImage * maskImg = nil;

    NSValue *valSize = [NSValue valueWithCGSize:CGSizeZero];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (bgImgURL)?bgImgURL:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_URL_FORMATING:IMAGE_FETCHER_INFO_KEY_URL_FORMATING_NO_RESIZING};

    [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
     {

         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            BOOL maskExist = !(maskImgURL!=nil && maskImg==nil);

                            imgBG = image;
                            [self validateRedesignImages:origImg background:imgBG mask:maskImg needMask:maskExist ];
                        });
     }];

    dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (origImgURL)?origImgURL:@"",
            IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
            IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
            IMAGE_FETCHER_INFO_KEY_URL_FORMATING:IMAGE_FETCHER_INFO_KEY_URL_FORMATING_NO_RESIZING};


    [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            origImg = image;
                            BOOL maskExist = !(maskImgURL!=nil && maskImg==nil);


                            [self validateRedesignImages:origImg background:imgBG mask:maskImg needMask:maskExist ];
                        });
     }];


    dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (maskImgURL)?maskImgURL:@"",
            IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
            IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
            IMAGE_FETCHER_INFO_KEY_URL_FORMATING:IMAGE_FETCHER_INFO_KEY_URL_FORMATING_NO_RESIZING};


    [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             maskImg = image;
             //clear maskUrl if returned image is null, so that other images could finish normaly
             if (image==nil) {
                 maskImgURL=nil;
             }
             [self validateRedesignImages:origImg background:imgBG mask:maskImg needMask:YES ];
         });
     }];
}

- (void)validateRedesignImages:(UIImage *)original background:(UIImage *)background mask:(UIImage *)mask needMask:(BOOL)needMask {
    if( original && background && needMask)
    {
        [[UIManager sharedInstance] galleryDesignBGImageRecieved:background andOrigImage:original andMaskImage:mask];
    }
}


#pragma mark- Cards management
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    _lastContentOffset = scrollView.contentOffset;
}

- (void)scrollViewDidScroll:(UIScrollView *)in_scrollView {

    if (in_scrollView.contentOffset.y != 0) {
        in_scrollView.contentOffset = CGPointMake(in_scrollView.contentOffset.x, 0);
    }
    // WORKAROUND: use screen width here since view size is not determined in the moment viewDidLoad
    NSInteger width = [self getScreenWidth]; //self.scrollView.bounds.size.width;
    if ((floor(self.scrollView.contentOffset.x/width) != self.selectedItemIndex && self.scrollView.contentOffset.x > _lastContentOffset.x) ||
        ( ceil(self.scrollView.contentOffset.x/width) != self.selectedItemIndex && self.scrollView.contentOffset.x < _lastContentOffset.x)) {

        [UIManager dismissKeyboard:in_scrollView];

        //hotfix to close comment + keyboard if open (iphone only)
        for (GalleryItemBaseViewController * it in self.visibleLayouts) {
            if ([it respondsToSelector:@selector(moveTableViewForInitialFrame)]) {
                [it moveTableViewForInitialFrame];
            }
        }

        int tempItemIndex=self.scrollView.contentOffset.x/width;

        if (self.selectedItemIndex!=tempItemIndex) {

            //moving forward
            if (self.selectedItemIndex+1<=tempItemIndex) {
                self.selectedItemIndex++;
                [self swapCardsForward:self.selectedItemIndex + 1];
            }
            //moving backward
            else if (self.selectedItemIndex-1>=tempItemIndex) {
                self.selectedItemIndex--;
                [self swapCardsBackward:self.selectedItemIndex - 1];
            }

            NSLog(@"SELECTED PAGE CHANGE ---------------> %ld",(long)self.selectedItemIndex);
        }
    }
}

-(void)swapCardsForward:(NSInteger)index{

    if ([[self itemIdsArray] count]<3 || index>=[[self itemIdsArray] count]) {
        return;
    }

    DesignBaseClass * item = [self.itemIdsArray objectAtIndex:index];
    item.type = self.dataSourceType == eFScreenEmptyRooms ? eEmptyRoom : e3DItem;
    for (GalleryItemBaseViewController * gibVc in self.visibleLayouts) {
        gibVc.isCurrentVcDisplay = NO;
        if ([gibVc.itemDetail isEqual:item]) {
            gibVc.isCurrentVcDisplay = YES;
            return;
        }
    }

    GalleryItemBaseViewController * newcard = [self getCardForType:[item isArticle] ? CARD_TYPE_ARTICLE : CARD_TYPE_IMAGE];
    newcard.isCurrentVcDisplay = YES;
    [newcard init:item];

    //position the card correctly
    CGRect frm = newcard.view.frame;
    frm.origin.x = index*[self getScreenWidth];
    frm.size.width = [self getScreenWidth];
    frm.size.height = [self getScrollViewHeight];
    newcard.view.frame = frm;

    if ([self getScreenWidth] > [self getScreenHeight]) {
        if(!IS_IPAD)
            [self hideControls];
    }else{
        [self showControls];
    }

    if ([[self visibleLayouts] count] > CARD_MAX_CACHE) {
        UIViewController* vc = [self visibleLayouts].firstObject;
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
        [self.visibleLayouts removeObject:vc];
    }

    [self addChildViewController:newcard];
    [self.scrollView addSubview:newcard.view];
    [self.visibleLayouts addObject:newcard];

    if ([newcard respondsToSelector:@selector(reloadTable)]) {
        [newcard reloadTable];
    }
}

-(void)swapCardsBackward:(NSInteger)index{

    if ([[self itemIdsArray] count]<3 || index < 0) {
        return;
    }

    DesignBaseClass * item = [self.itemIdsArray objectAtIndex:index];
    item.type = self.dataSourceType == eFScreenEmptyRooms ? eEmptyRoom : e3DItem;
    for (GalleryItemBaseViewController * gibVc in self.visibleLayouts) {
        gibVc.isCurrentVcDisplay = NO;
        if ([gibVc.itemDetail isEqual:item]) {
            gibVc.isCurrentVcDisplay = YES;
            return;
        }
    }

    GalleryItemBaseViewController *newcard = [self getCardForType:[item isArticle] ? CARD_TYPE_ARTICLE : CARD_TYPE_IMAGE];

    if (index<0 || index==[self.itemIdsArray count]-1) {
        [newcard clearUI];
    }else{
        [newcard init:item];
    }

    //position the card correctly
    CGRect frm=newcard.view.frame;
    frm.origin.x=index*[self getScreenWidth];
    frm.size.width = [self getScreenWidth];
    frm.size.height = [self getScrollViewHeight];
    newcard.view.frame=frm;

    if ([self getScreenWidth] > [self getScreenHeight]) {
        [self hideControls];
    }else{
        [self showControls];
    }

    if ([[self visibleLayouts] count] > CARD_MAX_CACHE) {
        UIViewController* vc = [self visibleLayouts].lastObject;
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
        [self.visibleLayouts removeObject:vc];
    }

    [self addChildViewController:newcard];
    [self.scrollView addSubview:newcard.view];
    [self.visibleLayouts insertObject:newcard atIndex:0];

    if ([newcard respondsToSelector:@selector(reloadTable)]) {
        [newcard reloadTable];
    }
}

- (void)scrollToLastVisibleItemInDirection:(BOOL)isForwardDirection {

    GalleryItemBaseViewController * newcard = [self getCardForType:CARD_TYPE_IMAGE];
    //Decide what is the last visible item index
    NSInteger lastVisibleItemIndex = isForwardDirection ? self.selectedItemIndex + 1 : self.selectedItemIndex - 1;
    CGRect frm = newcard.view.frame;
    frm.origin.x = lastVisibleItemIndex*[self getScreenWidth];
    newcard.view.frame = frm;
    [self.scrollView scrollRectToVisible:frm animated:NO];
}

-(GalleryItemBaseViewController*)getCardForType:(int)type
{
    if(CARD_TYPE_ARTICLE == type)
    {
        GalleryArticleBaseViewController * gabvc = [ControllersFactory instantiateViewControllerWithIdentifier:@"GalleryArticleBaseViewController" inStoryboard:kGalleryStoryboard];
        gabvc.eventLoadOrigin = self.eventLoadOrigin;
        gabvc.itemDetailsRequestNeeded = self.itemDetailsRequestNeeded;
        return gabvc;
    }
    else if(CARD_TYPE_IMAGE == type)
    {
        GalleryImageViewController * gibvc = [ControllersFactory instantiateViewControllerWithIdentifier:@"GalleryImageViewController" inStoryboard:kGalleryStoryboard];
        gibvc.itemDetailsRequestNeeded = self.itemDetailsRequestNeeded;
        return gibvc;
    }else{
        return nil;
    }
}

#pragma mark - GalleryImageDesignInfoCellDelegate
- (void)showDesignLikes:(DesignBaseClass*)design {
    ProfileUserListViewController * likesVC = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileUserListViewController" inStoryboard:kNewProfileStoryboard];

    ProfileUserListDesignLikes * dataSource = [[ProfileUserListDesignLikes alloc] init];
    dataSource.assetId = design._id;
    likesVC.dataSource = dataSource;

    [[[UIManager sharedInstance] pushDelegate].navigationController pushViewController:likesVC animated:YES];
}

#pragma mark - MyDesignEditDelegate
- (void)designUpdated:(DesignMetadata *)metadata {
    // update parent view controller
    if (self.sourceViewController && [[self.sourceViewController class] conformsToProtocol:@protocol(MyDesignEditDelegate)]) {
        UIViewController<MyDesignEditDelegate>* delegate = (UIViewController<MyDesignEditDelegate>*)self.sourceViewController;
        if ([delegate respondsToSelector:@selector(designUpdated:)]) {
            [delegate designUpdated:metadata];
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.currentItemDelegate refreshDesignInfo];
        [self updateButtonsState];
    });
}

- (void)designDuplicated:(NSString *)designId {
    // update parent view controller
    if (self.sourceViewController && [[self.sourceViewController class] conformsToProtocol:@protocol(MyDesignEditDelegate)]) {
        UIViewController<MyDesignEditDelegate>* delegate = (UIViewController<MyDesignEditDelegate>*)self.sourceViewController;
        if ([delegate respondsToSelector:@selector(designDuplicated:)]) {
            [delegate designDuplicated:designId];
        }
    }
}

- (void)designDeleted:(NSString *)designId {
    // update parent view controller
    if (self.sourceViewController && [[self.sourceViewController class] conformsToProtocol:@protocol(MyDesignEditDelegate)]) {
        UIViewController<MyDesignEditDelegate>* delegate = (UIViewController<MyDesignEditDelegate>*)self.sourceViewController;
        if ([delegate respondsToSelector:@selector(designDeleted:)]) {
            [delegate designDeleted:designId];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:NO];
    });
}

- (void)redesign:(DesignBaseClass *)designInfo {
    NSAssert(self.currentItemDelegate.itemDetail == designInfo, @"unexpected design data!");

    if (![ConfigManager isAnyNetworkAvailableOrOffline]) {
        [ConfigManager showMessageIfDisconnected];
        return;
    }

    [[ProgressPopupBaseViewController sharedInstance] stopLoading];

    NSString* strDesign = [self.currentItemDelegate getItemContent];

    if (![NSString notEmpty:strDesign]) {
        self.currentItemDelegate.itemDetailsPrivateURLNeeded = [designInfo isDesignBelongsToLoggedInUser];

        [[ProgressPopupBaseViewController sharedInstance] startLoading:self];

        [self.currentItemDelegate loadItemDetailFromServer:^(BOOL status) {
            if (status) {
                [self performSelectorOnMainThread:@selector(redesign:) withObject:designInfo waitUntilDone:NO];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{

                    [[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"failed_load_models", @"We couldn't load the design")
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"")
                                     otherButtonTitles: nil] show];

                });
            }
        }];

        return;
    }

    if ([designInfo isKindOfClass:[MyDesignDO class]]) {
        MyDesignDO * md = (MyDesignDO*)designInfo;
        if (md.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {

            SavedDesign* designData = [[DesignsManager sharedInstance] workingDesign];

            GalleryItemDO * gido = (GalleryItemDO*)md;

            [self validateRedesignImages:designData.originalImage background:designData.image mask:designData.maskImage needMask:designData.maskImage == Nil ];

            [[UIManager sharedInstance] galleryDesignSelected:designData withOriginalDesign:gido  withOriginEvent:EVENT_PARAM_VAL_LOAD_ORIGIN_REDESIGN];

        } else {
            [self prepareDesignData:designInfo];
        }

    } else {
        [self prepareDesignData:designInfo];
    }
}

- (void)prepareDesignData:(DesignBaseClass *)designInfo {
    NSString* strDesign = [self.currentItemDelegate getItemContent];

    if ([strDesign length ] == 0) {
        [self.currentItemDelegate getMyItemDetail];
        return;
    }

    if ([[self.currentItemDelegate getItemItself] isUpdateRequeredForRedesign]) {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@""
                                                      message:NSLocalizedString(@"redesign_json_newer_alert", @"")
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"alert_view_dont_remind", @"") otherButtonTitles: NSLocalizedString(@"Update Now", @"Update"),nil];
        [alert show];
        return;
    }

    SavedDesign* designData = [SavedDesign designWithJSONString:strDesign];

    if (designData == nil) {
        UIImage * image = [self.currentItemDelegate getCurrentPresentingImage];
        designData = [SavedDesign initWithImage:image
                                  imageMetadata:nil
                                 devicePosition:nil
                            originalOrientation:image.imageOrientation];
    }

    [designData updateLockingStateAccordingToDesignType:self.dataSourceType];

    //get design id

    if ([designInfo isDesignBelongsToLoggedInUser]) {
        designData.designID=[self.currentItemDelegate getItemID];

        designData.designDescription=[self.currentItemDelegate getDesignDescription];
        designData.designRoomType=[self.currentItemDelegate getRoomType];
        designData.name=[self.currentItemDelegate getDesignTitle];
    }

    BOOL bUpdateParent = ![designData.UniqueID isEqualToString:[self.currentItemDelegate getItemID]];
    BOOL bUpdateParent2 = ![designData.designID isEqualToString:[self.currentItemDelegate getItemID]];

    if (bUpdateParent && bUpdateParent2) {
        designData.parentID = [self.currentItemDelegate getItemID];
    }

    if ([designInfo isPublicOrPublished]) {
        designData.publicDesignID=[self.currentItemDelegate getItemID];
    }

    if ([[self.currentItemDelegate getItemItself] isDesignPublished] || [designInfo isDesignBelongsToLoggedInUser]==NO) {
        designData.mustSaveAsNewDesign=YES;
    }

    GalleryItemDO * gido = (GalleryItemDO*)designInfo;

    [[UIManager sharedInstance] galleryDesignSelected:designData
                                   withOriginalDesign:gido
                                      withOriginEvent:EVENT_PARAM_VAL_LOAD_ORIGIN_REDESIGN];
    [self getFullImages];
}

- (void)hideProductInfoView
{
    if ([self.productInfo.view superview])
    {
        [self.productInfo closeProductInfoView:nil];
    }
}


#pragma mark -

- (void)likePressedLoginResponseNotification:(NSNotification *)notification {
    NSString* itemID = [self.currentItemDelegate getItemID];
    Boolean isSuccess;

    [[[notification userInfo] objectForKey:@"isSuccess"] getValue:&isSuccess];
    DesignBaseClass* sentItem = [[notification userInfo] objectForKey:@"item"];

    if([itemID isEqualToString:sentItem._id])
    {
        if(isSuccess == YES)
        {
            [self likesPressedAfterLogin];
        }
    }
}

- (void)loginRequestEndedwithState:(BOOL) state {
    if (state) {
        [self pageChange];
    }
}

- (void)likesPressedAfterLogin {
    [self updateLikeButtonState];
}

-(NSInteger)getScreenWidth{
    return [UIScreen currentScreenBoundsDependOnOrientation].size.width;
}

-(NSInteger)getScreenHeight{
    return [UIScreen currentScreenBoundsDependOnOrientation].size.height;
}

-(void)presentCurrentDesign {
    if (self.currentItemDelegate == nil)
        return;

    [self updateButtonsState];
    [self.currentItemDelegate loadUI];
}

-(void)clearVisibleLayout{
    for (UIViewController * vc in self.visibleLayouts) {
        [vc removeFromParentViewController];
        [vc.view removeFromSuperview];
    }

    [self.visibleLayouts removeAllObjects];
    self.visibleLayouts = nil;
}

#pragma mark - GenericWebViewDelegate
-(void)openInteralWebViewWithUrl:(NSString *)url{
    GenericWebViewBaseViewController * web = [[UIManager sharedInstance]createGenericWebBrowser:url];
    [self presentViewController:web animated:YES completion:nil];
}

-(CGFloat)getScrollViewHeight {
    CGFloat barHeight = 100;// TODO: _topBar.frame.size.height + _bottomBar.frame.size.height;
    CGFloat scrollViewHeight = [self getScreenHeight] - barHeight;
//    if (@available(iOS 11, * )) {
//        scrollViewHeight -= (self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom);
//    }
    // TODO: use hard-coded value as workaround since the insets values are not ready within viewDidLoad
    if (IS_IPHONE) {
        scrollViewHeight -= ([ConfigManager deviceTypeisIPhoneX] ? 78 : 20); // NOTE: 78 is the total height beyond safe area, 20 is the top margin for status bar
    } else {
        scrollViewHeight -= 20;
    }
    return scrollViewHeight;
}

- (NSString *)eventTypeStringFromItemType:(ItemType)type {
    NSString * itemType=@"";
    switch (type) {
        case e3DItem:
            itemType = EVENT_PARAM_VAL_3D;
            break;
        case e2DItem:
            itemType = EVENT_PARAM_VAL_2D;
            break;
        case eArticle:
            itemType = EVENT_PARAM_VAL_ARTICLE;
            break;
        default:
            itemType = EVENT_PARAM_VAL_UNKNOWN;
            break;
    }
    return itemType;
}

- (IBAction)scrollToTopPressed:(id)sender {
    if (self.currentItemDelegate == nil)
        return;

    if ([self.currentItemDelegate respondsToSelector:@selector(scrollToTop)]) {
        [self.currentItemDelegate scrollToTop];
    }
}

@end

