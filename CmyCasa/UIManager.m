//
//  UIManager.m
//  CmyCasa
//
//  Created by Berenson Sergei on 1/17/13.
//
//

#import "UIManager.h"
#import "AppDelegate.h"
#import "FullScreenViewController_iPad.h"
#import "MainViewController.h"
#import "ExternalLaunchManager.h"
#import "SavedDesign.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+fixOrientation.h"
#import "UIImage+Scale.h"
#import "UIImage+EXIF.h"
#import "NotificationAdditions.h"
#import "UIViewController+Helpers.h"
#import "FindFriendsBaseViewController.h"
#import "DesignRO.h"
#import "UIViewController+Helpers.h"
#import "ImageEffectsBaseViewController.h"
#import "HSSharingConstants.h"
#import "NotificationNames.h"
#import "ControllersFactory.h"
#import "ActivityStream.h"
#import "ImageFetcher.h"
#import "RetakePhotoBaseViewController.h"
#import "GalleryHomeBaseViewController.h"
#import "HSMacros.h"
#import "GenericWebViewBaseViewController.h"
#import "LandscapeDesignViewController_iPhone.h"
#import "GalleryStreamBaseController.h"
#import "FlurryDefs.h"
#import "ARViewController.h"


#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

@interface UIManager () <RetakePhotoProtocol>
{
    UIPopoverController * _imageGalleryPopover;
}

@property (nonatomic, strong) NSArray * cachedActivities;
@property (nonatomic, strong) ActivityStream * myActivityStream;
@property (nonatomic, strong) dispatch_queue_t galleryMangerQueue;


@end

@implementation UIManager

static UIManager *sharedInstance = nil;

+ (UIManager *)sharedInstance {
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[UIManager alloc] init];
    });
    
    return sharedInstance;
}

-(id)init {
    if ( self = [super init] ) {
        
        if (self.galleryMangerQueue) {
            self.galleryMangerQueue = dispatch_queue_create("com.autodesk.app.gallerybackground", NULL);
        }
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(OpenURLFromExternalLinkNotification:)
                                                    name:@"OpenURLFromExternalLinkNotification"
                                                  object:nil];
    }
    
    return self;
}

-(void)setPushDelegate:(UIViewController *)pDelegate{
    _pushDelegate = pDelegate;
}

-(void)askMainViewControllerToClose
{
    if (self.mainViewController) {
        self.mainViewController.shouldGoToRoot = YES;
        [self.mainViewController homePressed];
    }
}

-(void)askMainViewControllerToOpenCatalog
{
    if (self.mainViewController) {
        [self.mainViewController catalogPressed];
    }
}

- (FullScreenBaseViewController *)createFullScreenGallery:(NSArray *)itemsArray
                                        withSelectedIndex:(NSInteger)selectedIndex
                                              eventOrigin:(NSString *)loadOrigin {
    
    //for 3d you must provide array of nsdictionary of itemid,itemType
    
    FullScreenBaseViewController * fsbVc = [ControllersFactory instantiateViewControllerWithIdentifier:@"SelectedViewControllerID" inStoryboard:kGalleryStoryboard];
    fsbVc.eventLoadOrigin = loadOrigin;
    [fsbVc setItemIdsArray:[NSMutableArray arrayWithArray:itemsArray]];
    [fsbVc setSelectedItemIndex:selectedIndex];

    return  fsbVc;
}

- (UIViewController *)createUniversalFullScreen:(NSArray *)itemsArray withSelectedIndex:(NSInteger)selectedIndex eventOrigin:(NSString *)loadOrigin {
    
    if (IS_IPAD){
        return [self createFullScreenGallery:itemsArray withSelectedIndex:selectedIndex eventOrigin:loadOrigin];
    }else{
        return [self createIphoneFullScreenGallery:itemsArray withSelectedIndex:selectedIndex eventOrigin:loadOrigin];
    }
}

-(GenericWebViewBaseViewController*)createGenericWebBrowser:(NSString*)url{
    GenericWebViewBaseViewController* selgal=[ControllersFactory instantiateViewControllerWithIdentifier:@"GenericWebBrowser" inStoryboard:kGalleryStoryboard];
    
    [selgal setRequestedUrl:url];
    return selgal;
}

#pragma mark -

- (void)galleryDesignSelected:(SavedDesign*)design withOriginalDesign:(GalleryItemDO*)originalDesign withOriginEvent:(NSString*)origin{
//    [HSFlurry logAnalyticEvent:EVENT_NAME_LOAD_DESIGN_TOOL withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:origin}];
    
    if (![[[ConfigManager sharedInstance] catalogShowRoomID] isEqualToString:originalDesign._id]) {
        [[CatalogMenuLogicManger sharedInstance] setShowTopLevel:YES];
    }
    
    [[DesignsManager sharedInstance] setWorkingDesign: design];
    [[DesignsManager sharedInstance] startAutoSave];
    
    //Stop memory caching during the redesign process
    [[ImageFetcher sharedInstance] setMemoryCachingEnabled:NO];
    
    //TODO: -320 menu
    [self openDesignViewContorller:originalDesign withOriginEvent:origin];
}

-(void)openDesignViewContorller:(GalleryItemDO*)originalDesign withOriginEvent:(NSString*)origin{
    if (![_pushDelegate.navigationController.topViewController isConnectionAvailable]) {
        return;
    }

    // NOTE: to avoid _mainViewController be pushed more than once
    if (_mainViewController != nil)
        return;

    _mainViewController =  (MainViewController*)[ControllersFactory instantiateViewControllerWithIdentifier:@"MainView" inStoryboard:kRedesignStoryboard];
    [_mainViewController.view setFrame:[UIScreen mainScreen].bounds];

    if ([origin isEqualToString: EVENT_PARAM_VAL_LOAD_ORIGIN_CATALOG]) {
        [self.mainViewController setProductId:self.productId];
        [self.mainViewController setVariationId:self.variationId];
        [self.mainViewController setTimeStamp:self.timeStamp];
        [self.mainViewController setIsLoadedFromCatalogBeforeMainWasActive:YES];
    }
    
    if (originalDesign) {
        self.mainViewController.originalDesignObject = [[GalleryItemDO alloc] init];
        self.mainViewController.originalDesignObject.author = originalDesign.author;
        self.mainViewController.originalDesignObject.title = originalDesign.title;
        self.mainViewController.originalDesignObject._description = originalDesign._description;
        self.mainViewController.originalGalleryItem = originalDesign;
    }
    
    if (IS_IPAD) {
        if (![[_pushDelegate.navigationController viewControllers] containsObject:self.mainViewController]) {
            [_pushDelegate.navigationController pushViewController:self.mainViewController animated:YES];
        }
    }else{
        UIViewController * vc = [[_pushDelegate.navigationController viewControllers] lastObject];
        if (vc.presentedViewController) {
            [vc dismissViewControllerAnimated:NO completion:^{
                [_pushDelegate.parentViewController presentViewController:self.mainViewController animated:NO completion:nil];
            }];
        }else{
            [_pushDelegate presentViewController:self.mainViewController animated:YES completion:nil];
        }
    }
}

- (void) galleryDesignBGImageRecieved :(UIImage*)image andOrigImage: (UIImage*)in_OrigImage andMaskImage: (UIImage*)in_maskImage{
    [[DesignsManager sharedInstance] workingDesign].image = image;
    [[DesignsManager sharedInstance] workingDesign].originalImage = in_OrigImage;
    [[DesignsManager sharedInstance] workingDesign].maskImage = in_maskImage;
    [self.mainViewController updateBGImage];
}

- (BOOL)likePressedForItemId:(NSString *)itemId andItemType:(ItemType)type withState:(BOOL)isLiked sender:(UIViewController*)senderView  shouldUsePushDelegate:(BOOL)usePushDelegate withCompletionBlock:(ROCompletionBlock)completion
{
    DesignBaseClass *item = [[DesignsManager sharedInstance] findDesignByID:itemId];
    
    if (item == nil)
    {
        item = [[[AppCore sharedInstance] getHomeManager]findArticleByID:itemId];
    }
    
    if (item == nil)
    {
        item = [[GalleryStreamManager sharedInstance] findCustomItem:itemId];
    }
    
    if (item == nil)
    {
        GalleryItemDO *tempItem = [[GalleryItemDO alloc] createEmptyDesignWithType:type];
        tempItem._id = itemId;
        
        [[GalleryStreamManager sharedInstance] addCustomItem:tempItem];
        
        item = tempItem;
    }
    
    return [[DesignsManager sharedInstance] likeDesign:item :isLiked :senderView :usePushDelegate withCompletionBlock:completion];;
}

- (void) stopLoadingForFullScreen
{
}

#pragma mark-
#pragma mark NewDesignViewControllerDelegate
- (void)cameraPressed {
    
    if (IS_IPAD) {
        [[UIMenuManager sharedInstance] removeNewDesignViewController];
    } else {
        [[UIMenuManager sharedInstance] removeNewDesignViewControllerIPhone];
    }
    
    NSString *nibName = IS_IPAD ? @"OverlayView_iPad" : @"OverlayView";
   
    TakePictureOverlay * takePictureOverlay = [[TakePictureOverlay alloc] initWithNibName:nibName bundle:nil];
   
    [_pushDelegate.navigationController pushViewController:takePictureOverlay animated:NO];
}

- (void)arPressed {
    
    if (IS_IPAD) {
        [[UIMenuManager sharedInstance] removeNewDesignViewController];
    } else {
        [[UIMenuManager sharedInstance] removeNewDesignViewControllerIPhone];
    }
    
    ARViewController *ar = [[ARViewController alloc] init];
    [_pushDelegate.navigationController pushViewController:ar animated:NO];
}

- (void)deviceGalleryPressed:(UIViewController*)mview {
    [self startMediaBrowserFromViewController:mview usingDelegate: self forView:mview.view];
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller usingDelegate:
(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate forView:(UIView*)mview{
    
    CGRect screenRect = [UIScreen currentScreenBoundsDependOnOrientation];
    CGFloat screenWidth = screenRect.size.height;
    CGFloat screenHeight = screenRect.size.width;
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary ;
    mediaUI.allowsEditing = NO;
    mediaUI.modalPresentationStyle = UIModalPresentationFullScreen;
    mediaUI.delegate = delegate;
    if (IS_IPAD) {
        if ([_imageGalleryPopover isPopoverVisible]) {
            [_imageGalleryPopover dismissPopoverAnimated:YES];
        }
        _imageGalleryPopover = [[UIPopoverController alloc] initWithContentViewController:mediaUI];
        [_imageGalleryPopover setDelegate:self];
        
        [_imageGalleryPopover presentPopoverFromRect:CGRectMake(0, 0, screenWidth-120, screenHeight) inView:mview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [controller presentViewController:mediaUI animated:YES completion:nil];
    }
    return YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [_imageGalleryPopover dismissPopoverAnimated:YES];
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

//you get here after the user chose an image from the device's gallery
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    // Handle a still image picked from a photo album
    UIImage *galleryImage;
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        
        galleryImage = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];

        if (galleryImage) {
            
            NSDictionary* metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
            if (!metadata) {
                metadata = [UIImage imageMetadataWithAssetURL:[info objectForKey:UIImagePickerControllerReferenceURL]];
            }
            
            if (IS_IPAD) {
                [_imageGalleryPopover dismissPopoverAnimated:YES];
            }
            
            [self loadRoomWithGalleryImage:galleryImage withMatadata:metadata];
        }
    }
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

-(void)loadRoomWithGalleryImage:(UIImage*)galleryimage withMatadata:(NSDictionary*)metadata {
    
    UIImageOrientation orientation = galleryimage.imageOrientation;
    if (orientation == UIImageOrientationDown || orientation == UIImageOrientationUp )
        galleryimage = [galleryimage normalizedImage];
    
    galleryimage = [galleryimage scaleToFitLargestSide2:IMAGE_MAX_SIZE];
    
    SavedDesign* design = [SavedDesign initWithImage:galleryimage imageMetadata:nil devicePosition:nil originalOrientation:UIImageOrientationUp];
    design.originalSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
   
    design.isPortrait = (galleryimage.size.height > galleryimage.size.width) ? YES : NO;
    
    [[CatalogMenuLogicManger sharedInstance] setShowTopLevel:YES];
    [[DesignsManager sharedInstance] setWorkingDesign:design];
    [[DesignsManager sharedInstance] startAutoSave];
    
//    [HSFlurry logAnalyticEvent:EVENT_NAME_LOAD_DESIGN_TOOL withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_VAL_LOAD_ORIGIN_NEW_DESIGN}];
    
    //Stop memory caching during the redesign process
    [[ImageFetcher sharedInstance] setMemoryCachingEnabled:NO];
    
    //we only allow retake screen on portrait images from the gallery
    if (design.isPortrait){
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:NSLocalizedString(@"photo_not_in_landscape_device", @"")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"")
                          otherButtonTitles: nil] show];
    }else{
        [self openDesignViewContorller:nil withOriginEvent:EVENT_PARAM_VAL_LOAD_ORIGIN_NEW_DESIGN];
    }
}

//for Ipad UIPopoverController if there is a cancel when the user click outside the popover
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	_imageGalleryPopover = nil;
}

#pragma mark- Handling external Links

-(void)OpenURLFromExternalLinkNotification:(NSNotification*)notification{
    
    ExternalLaunchManager* deleg = [ExternalLaunchManager sharedInstance];
    
    PushDataBaseDO * push=deleg.lastPush;
    
    if (!push) {
        //Check if local
        
        if (notification) {
            BOOL isInitialReminder = (BOOL)[[notification userInfo] valueForKey:kInitialReminderKey];
            BOOL isPeriodicalReminder = (BOOL)[[notification userInfo] valueForKey:kPeriodicalReminderKey];
            
            if (isInitialReminder) {
                [[UIMenuManager sharedInstance] openGalleryStreamWithType:DesignStreamType2D andRoomType:@"" andSortBy:@"1"];
            } else if (isPeriodicalReminder) {
                if (!IS_IPAD) {
                    GenericWebViewBaseViewController * web = [[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance]localNotificationURL]];
                    [sharedInstance.pushDelegate.navigationController presentViewController:web animated:NO completion:^{}];
                } else {
                    GenericWebViewBaseViewController * web = [[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance]localNotificationURL]];
                    [sharedInstance.pushDelegate.navigationController presentViewController:web animated:NO completion:^{}];
                }
            }
        }
        
        return;
    }
    
    if (deleg.screenRequestType==eScreenTypeProfile) {
        if (push.itemID) {
            
            [[UIMenuManager sharedInstance] openProfilePageForsomeUser:push.itemID];
            
        }
        deleg.lastPush=nil;
        return;
    }
    
    
    if (deleg.screenRequestType==eScreenTypeProfessional) {
        if (push.itemID) {
            
            [[UIMenuManager sharedInstance] openProfessionalByID:push.itemID];
            
        }
        deleg.lastPush=nil;
        return;
    }
    
    if (deleg.screenRequestType == eScreenTypeFullScreen) {
        
        
        if (push.assetType!=nil && push.itemID!=nil) {
            
            
            [self openGalleryFullScreenFromDesignID:push.commentingID!=nil designid:push.itemID withType:[push.assetType  intValue]  eventOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_EXT_NOTIFICATION];
            deleg.lastPush=nil;
            
        }
        
    }
}

- (void)openGalleryFullScreenFromDesignID:(BOOL)withComments designid:(NSString *)designID withType:(ItemType)designType
                              eventOrigin:(NSString*)openOrigin  {
    GalleryItemDO * item=nil;
    BOOL foundInCustomList=YES;
    item = [[GalleryStreamManager sharedInstance] findCustomItem:designID];
    
    // (nil == item.title) is inserted to check if the item is not a dummy design object
    // TODO: There shouldn't be any dummy objects.
    if (item==nil || nil == item.title) {
        foundInCustomList=NO;
        item= [[GalleryItemDO alloc] createEmptyDesignWithType:designType];
        
        item._id=designID;
        
        [[[AppCore sharedInstance] getGalleryManager]addCustomItem:item];
    }
    
    FullScreenBaseViewController* selgal=(FullScreenBaseViewController*) [[UIManager sharedInstance] createUniversalFullScreen:[NSArray arrayWithObjects:item, nil] withSelectedIndex:0 eventOrigin:nil ];
    
    selgal.dataSourceType = eFScreenGalleryStream;
    selgal.eventLoadOrigin = openOrigin;
    selgal.itemDetailsRequestNeeded = !foundInCustomList;
    selgal.openCommentsLayer = withComments;
    
    [sharedInstance.pushDelegate.navigationController pushViewController:selgal animated:YES];
}

#pragma mark - iphone Methods
- (FullScreenViewController_iPhone *)createIphoneFullScreenGallery:(NSArray *)itemsArray withSelectedIndex:(NSInteger)selectedIndex eventOrigin:(NSString *)loadOrigin {
    
    //for 3d you must provide array of nsdictionary of itemid,itemType
    FullScreenViewController_iPhone * fullScreen = [ControllersFactory instantiateViewControllerWithIdentifier:@"SelectedViewControllerID" inStoryboard:kGalleryStoryboard];
    fullScreen.eventLoadOrigin = loadOrigin;
    [fullScreen setItemIdsArray:[NSMutableArray arrayWithArray:itemsArray]];
    [fullScreen setSelectedItemIndex:selectedIndex];
    
    return  fullScreen;
}

#pragma mark - Find Friends
-(UIViewController*)createUniversalFindFriends{
    
    return [ControllersFactory instantiateViewControllerWithIdentifier:@"FindFriendsViewController" inStoryboard:kNewProfileStoryboard];
}

#pragma mark - Image Effects
-(UIViewController*)createImageEffectsViewController{
    ImageEffectsBaseViewController * ipn = [ControllersFactory instantiateViewControllerWithIdentifier:@"ImageEffectsViewController" inStoryboard:kRedesignStoryboard];
    return  ipn;
}

#pragma mark - Help Article

- (void)openHelpArticle
{
    if (![ConfigManager isWhiteLabel])
    {
        [self openHelpArticleAsAssetArticle];
    }
    else
    {
        NSString *url = [ConfigManager getAppHelpArticleUrl];
        if (IS_IPAD)
        {
            url = [url stringByAppendingString:@"/iPad.html"];
        }
        else
        {
            url = [url stringByAppendingString:@"/iPhone.html"];
        }
        
        RETURN_VOID_ON_NIL(url);
        
        GenericWebViewBaseViewController *webViewController = [[UIManager sharedInstance] createGenericWebBrowser:url];
        RETURN_VOID_ON_NIL(webViewController);
        
        [[self pushDelegate].navigationController presentViewController:webViewController
                                                animated:YES
                                              completion:nil];
    }
}

- (void)openHelpArticleAsAssetArticle
{
    BOOL foundInCustomList = YES;
    GalleryItemDO * item = nil;
    
    item = [[GalleryStreamManager sharedInstance] findCustomItem:[[ConfigManager sharedInstance] articleHelpID]];
    if (!item) {
        foundInCustomList = NO;
        item = [[GalleryItemDO alloc] init];
        [item createCustomArticle];
        item._id = [[ConfigManager sharedInstance] articleHelpID];
        
        [[GalleryStreamManager sharedInstance] addCustomItem:item];
    }
    
    FullScreenBaseViewController* fsbVc = (FullScreenBaseViewController*) [[UIManager sharedInstance] createUniversalFullScreen:[NSArray arrayWithObjects:item, nil]
                                                                                                                      withSelectedIndex:0
                                                                                                                            eventOrigin:nil];    
    fsbVc.isHelpArticle = YES;
    fsbVc.dataSourceType = eFScreenGalleryStream;
    fsbVc.itemDetailsRequestNeeded = !foundInCustomList;
    
    [[self pushDelegate].navigationController pushViewController:fsbVc animated:YES];
}

#pragma mark - Catalog
- (void)openHomeCatalog{
    [(GalleryHomeBaseViewController*)self.pushDelegate openCatalogFromViewController];
}

#pragma mark - Empty Rooms

- (BOOL)isDisplayingStreamOfEmptyRooms {
    
    UINavigationController * navigation = self.pushDelegate.navigationController;
    return [navigation.topViewController isKindOfClass:[GalleryStreamBaseController class]] && ((GalleryStreamBaseController*)navigation.topViewController).isStreamOfEmptyRooms;
}

#pragma mark - Cached Activities
//Not called anymore= Server constraint
- (void)fetchCachedActivities
{
    NSString *strUserId = [[[UserManager sharedInstance] currentUser] userID];
    
    if (strUserId == nil)
    {
        return;
    }
    
    HSCompletionBlock activitiesLoadSuccess = ^(NSArray *activities, NSError *error)
    {
        self.cachedActivities = activities;
        self.myActivityStream = nil;
    };
    
    HSFailureBlock activitiesLoadFail = ^(NSError *error)
    {
        self.cachedActivities = nil;
        self.myActivityStream = nil;
    };
    
    self.myActivityStream = [[ActivityStream alloc] initWithUser:strUserId isPrivate:YES];
    
    [self.myActivityStream getItemsFromActivityStreamWithSuccessAndFailureBlock:activitiesLoadSuccess failureBlock:activitiesLoadFail offset:@0 count:@5 queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
}

- (NSArray *)getCachedActivities
{
    return self.cachedActivities;
}

#pragma mark - Redesign

- (void)willEnterRedesignScreen {
    //Stop memory caching during the redesign process
    [[ImageFetcher sharedInstance] setMemoryCachingEnabled:NO];
}

#pragma mark - RetakePhotoProtocol
- (void)retakePhotoRetakeRequested
{
    if (IS_IPAD) {
        [_pushDelegate.navigationController popViewControllerAnimated:NO];
         [self cameraPressed];
    }else{
        UIViewController * vc = [[_pushDelegate.navigationController viewControllers] lastObject];
        if (vc.presentedViewController) {
            [_pushDelegate.navigationController dismissViewControllerAnimated:NO completion:^{
                [self cameraPressed];
            }];
        }else{
            [self cameraPressed];
        }
    }
}

- (void)retakePhotoApproved
{
    [self saveWorkingDesignToPhotoAlbum];
//    [HSFlurry logAnalyticEvent:EVENT_NAME_LOAD_DESIGN_TOOL withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_VAL_LOAD_ORIGIN_NEW_DESIGN}];
    
    if (IS_IPAD) {
        [_pushDelegate.navigationController popToRootViewControllerAnimated:NO];
        [self willEnterRedesignScreen];
        [self openDesignViewContorller:nil withOriginEvent:EVENT_PARAM_VAL_LOAD_ORIGIN_NEW_DESIGN];
    }else{
        UIViewController * vc = [[_pushDelegate.navigationController viewControllers] lastObject];
        if (vc.presentedViewController) {
            [_pushDelegate.navigationController dismissViewControllerAnimated:NO completion:^{
                [_pushDelegate.navigationController popToRootViewControllerAnimated:NO];
                [self willEnterRedesignScreen];
                [self openDesignViewContorller:nil withOriginEvent:EVENT_PARAM_VAL_LOAD_ORIGIN_NEW_DESIGN];
            }];
        }else{
            [_pushDelegate.navigationController popToRootViewControllerAnimated:NO];
            [self willEnterRedesignScreen];
            [self openDesignViewContorller:nil withOriginEvent:EVENT_PARAM_VAL_LOAD_ORIGIN_NEW_DESIGN];
        }
    }
}

- (void)showRetakePhotoScreen
{
    SavedDesign *design = [[DesignsManager sharedInstance] workingDesign];
    UIImage *img = design.originalImage;
    
    if (img != nil)
    {
        //open retake photo screen
        RetakePhotoBaseViewController *retakeVC = [ControllersFactory instantiateViewControllerWithIdentifier:@"RetakePhotoBaseViewController" inStoryboard:kRedesignStoryboard];
        retakeVC.delegate = self;
        retakeVC.image = img;
        retakeVC.allowZooming = design.isPortrait;
        
        if (IS_IPAD) {
            [_pushDelegate.navigationController pushViewController:retakeVC animated:NO];
        }else{
            [_pushDelegate.navigationController presentViewController:retakeVC animated:NO completion:nil];
        }
    }
}

#pragma mark - Save Image To Photo Album
- (void)saveWorkingDesignToPhotoAlbum
{
    SavedDesign *design = [[DesignsManager sharedInstance] workingDesign];
    if (design.originalImage)
    {
        UIImageWriteToSavedPhotosAlbum(design.originalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error){
        NSLog(@"Camera ERROR: %@", error);
    }
}

////////////////////////////////////////////////////////////////////

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _pushDelegate = nil;
    _mainViewController = nil;
}

+ (BOOL)dismissKeyboard:(UIView *)view
{
    if (view.isFirstResponder) {
        [view resignFirstResponder];
        return YES;
    }
    for (UIView *subView in view.subviews) {
        if ([UIManager dismissKeyboard:subView]) // It's calling itself, just to be perfectly clear
            return YES;
    }
    return NO;
}


@end
