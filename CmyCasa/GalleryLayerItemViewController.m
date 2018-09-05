//
//  GalleryLayerItemViewController.m
//  CmyCasa
//
//  Created by Gil Hadas on 12/31/12.
//
//

#import "GalleryLayerItemViewController.h"
#import "GalleryItemDO.h"

#import "UIImage+Scale.h"
#import "UIManager.h"
#import "HSAnimatingView.h"
#import "HSBrokenAnimatingView.h"
#import "NotificationNames.h"
#import "ImageFetcher.h"
#import "UIImageView+ViewMasking.h"
#import "UIView+Effects.h"
#import "UILabel+NUI.h"
#import "UIView+ReloadUI.h"
#import "NSString+CommentsAndLikesNum.h"

#import <QuartzCore/QuartzCore.h>

@interface GalleryLayerItemViewController () <UIGestureRecognizerDelegate>
{
    BOOL didDoubleTap;
    BOOL isLikeRequestPending;
}

@property(nonatomic,strong) DesignBaseClass * designItemObject;
- (IBAction)doubleTapGesture:(UIButton *)sender;
- (IBAction)singleTapGesture:(UIButton *)sender;

@end

@implementation GalleryLayerItemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.userImage setMaskToCircleWithBorderWidth:1.5f andColor:[UIColor whiteColor]];
    
    [self.articleSummaryUI setHidden:YES];
    
    [self addObservers];
    
    _indexInGalleryLayout = 0;
    isLikeRequestPending = NO;
    
    // TEMP----------
    self.comments_lbl.hidden = YES;
    self.btnComments.hidden = YES;
    self.likes_lbl.hidden = YES;
    self.btnLikes.hidden = YES;
    self.btnLikesLiked.hidden = YES;
    self.shareButton.hidden = YES;
    
    // --------------
    
    [self.view reloadUI];
}



-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    NSLog(@"dealloc - GalleryLayerItemViewController");
}

-(void) clearImage{
    [self.galleryImage setImage:nil];
}

- (void) setImage : (UIImage*) image
{
    self.galleryImage.alpha=0.0;
    [self.galleryImage setImage:image];
    [UIView animateWithDuration:0.4 animations:^{
        self.galleryImage.alpha = 1.0;
    }];
}

- (IBAction)shareAction:(id)sender {
    
    if (![ConfigManager isAnyNetworkAvailable]) {
        [ConfigManager showMessageIfDisconnected];
        return;
    }
    
    //cancel share action if the image of current design is not loaded yet
    if (![self isDesignImageLoaded]) {
        return;
    }
    
    NSString *itemID = [_galleryLayerDelegate getItemID:_indexInGalleryLayout];
    GalleryItemDO *item = [[[AppCore sharedInstance] getGalleryManager] getGalleryItemByItemID:itemID];

    HSCompletionBlock updateBlock=^(id serverResponse, id error) {
        
        UIImage *screen = (UIImage*)serverResponse;

        if (self.galleryLayerDelegate && [self.galleryLayerDelegate respondsToSelector:@selector(shareButtonPressedForDesign:withDesignImage:)]) {
            [self.galleryLayerDelegate shareButtonPressedForDesign:item withDesignImage:screen];
        }
    };
    
    //load design image
    CGSize designSize = self.galleryImage.frame.size;
    NSValue *valSize = [NSValue valueWithCGSize:designSize];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (self.designItemObject.url)?self.designItemObject.url:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.galleryImage};
    
    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
               {
                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.galleryImage];
                   
                   if (currentUid == uid)
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          if(image)
                                              updateBlock(image,nil);
                                      });
                   }
               }];
}

-(void)GalleryStreamItemImageDownloaded2:(NSNotification*)notification{
    
    NSMutableDictionary * dict=[NSMutableDictionary dictionaryWithDictionary:[notification userInfo]];
    
    self.shareImagePath = [dict objectForKey:@"path"];
}


- (IBAction)openuserProfile:(id)sender {
    
    NSString* itemID = [_galleryLayerDelegate getItemID:_indexInGalleryLayout];
    GalleryItemDO * item=[[[AppCore sharedInstance] getGalleryManager] getGalleryItemByItemID:itemID];
    
    if(itemID && ![item.uid isEqualToString:[ConfigManager getCompanyDesignerUid]]){
        
        if (item) {
            if(item.type==e3DItem) {
                [[UIMenuManager sharedInstance] openProfilePageForsomeUser:item.uid];
                [[UIMenuManager sharedInstance] updateMenuSelectionIndexAccordingToUserId:item.uid];
            }
            else if (item.type==e2DItem) {
                [[UIMenuManager sharedInstance] openProfessionalByID:item.uid];
                [[UIMenuManager sharedInstance] updateMenuSelectionIndexAccordingToUserId:item.uid];
            }
        }
    }
}

-(void)adjustSize
{
    int width = self.view.bounds.size.width;
    CGRect bar_rect = _bottom_barView.frame;
    CGRect btns_rect = _bottom_bar_btnsView.frame;
    CGRect frame_rect = self.view.frame;
    _bottom_bar_btnsView.frame = CGRectMake(frame_rect.size.width-btns_rect.size.width, btns_rect.origin.y, btns_rect.size.width , btns_rect.size.height);
    _bottom_barView.frame = CGRectMake(bar_rect.origin.x, frame_rect.size.height- bar_rect.size.height,width , bar_rect.size.height);
}

-(void)setItemWithLoadRequest:(DesignBaseClass*)in_item shouldLoad:(BOOL)needLoading
{
    [self preloadGalleryItemImages:in_item needLoading:needLoading];
    [self setItem:in_item];
    
}

- (void)preloadGalleryItemImages:(DesignBaseClass *)in_item needLoading:(BOOL)needLoading
{
        CGSize designSize = self.galleryImage.frame.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (in_item.url)?in_item.url:@"",
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.galleryImage};
        
        NSInteger lastUid = -1;
        
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                   {
                       NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.galleryImage];
                       
                       if (currentUid == uid)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              if(image)
                                                  [self setImage:image];
                                              //self.galleryImage.image = image;
                                          });
                       }
                   }];
        
        
        //load user profile image
        CGSize  designSize2 = self.userImage.frame.size;

        if ([in_item.uthumb containsString:@"facebook"] && ![in_item.uthumb containsString:@"type=large"]) {
            in_item.uthumb = [NSString stringWithFormat:@"%@?type=large",in_item.uthumb];
        }
    
        NSValue *  valSize2 = [NSValue valueWithCGSize:designSize2];
        NSDictionary *dic2 = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (in_item.uthumb)?in_item.uthumb:@"",
                               IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize2,
                               IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                               IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.userImage};
        
        NSInteger lastUid2 = -1;
        lastUid2 = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic2 andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                    {
                        NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.userImage];
                        
                        if (currentUid == uid)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^
                                           {
                                               if (image) {
                                                   self.userImage.image = image;
                                                   self.userImage.hidden = NO;
                                               }
                                           });
                        }else{
                            NSLog(@"");
                        }
                    }];
}

-(void)setItem:(DesignBaseClass*)in_item
{
        
    BOOL hidden = [self.galleryLayerDelegate isEmptyRoomsGalleryMode];
    self.comments_lbl.hidden = hidden;
    self.btnComments.hidden = hidden;
    self.likes_lbl.hidden = hidden;
    self.btnLikes.hidden = hidden;
    self.btnLikesLiked.hidden = hidden;
    self.shareButton.hidden = hidden;
    
    self.designItemObject=in_item;
    [self.userImage setImage:[UIImage imageNamed:@"iph_profile_settings_image.png"]];
    [self.userProfilePicView setHidden:NO];
    
    [self.articleSummaryUI setHidden:YES];
    
    _itemTypeImage.hidden=(e3DItem == in_item.type)?NO:YES;
    [self.articleSummaryUI setHidden:(eArticle == in_item.type)?NO:YES];
    
    if (!hidden) {
        [self updateLikedState];
    }
    
    if (in_item.uthumb && [in_item.uthumb length]>0) {
        [self.userProfilePicView setHidden:NO];
        CGRect frm=  self.title_lbl.frame;
        frm.origin.x=86;
        self.title_lbl.frame=frm;
        
    }else{
        [self.userImage setImage:[UIImage imageNamed:@"iph_profile_settings_image.png"]];
        [self.userProfilePicView setHidden:NO];
    }
    
    
    [self.userProfilePicView setHidden:(eArticle == in_item.type)?YES:self.userProfilePicView.hidden];
    
    //QA Compatibility Labels:
    self.view.accessibilityLabel = [self.title_lbl.text stringByAppendingString:@"_view"];
    self.galleryImage.accessibilityLabel = [self.title_lbl.text stringByAppendingString:@"_img"];
    self.likes_lbl.accessibilityLabel = [self.title_lbl.text stringByAppendingString:@"_likes"];
    self.btnLikes.accessibilityLabel = [self.title_lbl.text stringByAppendingString:@"_like"];
    self.comments_lbl.accessibilityLabel = [self.title_lbl.text stringByAppendingString:@"_comments"];
    self.btnComments.accessibilityLabel = [self.title_lbl.text stringByAppendingString:@"_comment"];
    self.userImage.accessibilityLabel = [self.title_lbl.text stringByAppendingString:@"_userimage"];
    self.userProfilePicView.accessibilityLabel = [self.title_lbl.text stringByAppendingString:@"_profileimage"];
    self.shareButton.accessibilityLabel = [self.title_lbl.text stringByAppendingString:@"_share"];

    if (self.galleryLayerDelegate &&  [self.galleryLayerDelegate isEmptyRoomsGalleryMode]) {
        [self.userProfilePicView setHidden:YES];
//        [self.userImage setImage:[UIImage imageNamed:@""]];
        
        
        CGRect frm=  self.title_lbl.frame;
        frm.origin.x=12;
        self.title_lbl.frame=frm;
        return;
    }
    
    isLikeRequestPending = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)commentsPressed:(id)sender {
    if (![ConfigManager isAnyNetworkAvailable]) {
        [ConfigManager showMessageIfDisconnected];
        return;
    }
    
    NSString* itemID = [_galleryLayerDelegate getItemID:_indexInGalleryLayout];
    [self.galleryLayerDelegate createFullScreenGalleryView: itemID  withOpenComment:YES];
}

- (IBAction)likesPressed:(id)sender
{
    if ([self isLoggedIn])
    {
        [self likePressed];
    }
    else
    {
        
        NSString *itemID = [_galleryLayerDelegate getItemID:_indexInGalleryLayout];
        GalleryItemDO *item = [[[AppCore sharedInstance] getGalleryManager] getGalleryItemByItemID:itemID];
        
        
        NSString * itemTypeKey=@"";
        switch ([item type]) {
            case e3DItem:
            {
                itemTypeKey=EVENT_PARAM_VAL_LIKE_3D;
            }
                break;
            case e2DItem:
            {
                itemTypeKey=EVENT_PARAM_VAL_LIKE_2D;
            }
                break;
            case eArticle:
            {
                itemTypeKey=EVENT_PARAM_VAL_LIKE_ARTICLE;
            }
            default:
            {
                itemTypeKey=EVENT_PARAM_VAL_UNKNOWN;
            }
                break;
        }
//        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:
//         @{EVENT_PARAM_SIGNUP_TRIGGER:itemTypeKey,
//           EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_LOAD_ORIGIN_LIKE}];
        
        
        
        [[UIMenuManager sharedInstance] loginRequestedIphone:[self.galleryLayerDelegate superViewController] withCompletionBlock:^(BOOL success) {
            if (success == YES) {
                [self likePressed];
            }
        }                                         loadOrigin:EVENT_PARAM_LOAD_ORIGIN_LIKE ];
    }
}

- (void)likePressed
{
    if (isLikeRequestPending)
    {
        return;
    }
    
    if (![ConfigManager isAnyNetworkAvailable]) {
        [ConfigManager showMessageIfDisconnected];
        return;
    }
    
    isLikeRequestPending = YES;
    
    if (![self isItemLiked] && ![self isButtonLiked]) //we were in unliked state
    {
        [self setButtonLiked:YES];
        [self setLikesCountNumber:[self getLikesCountNumber]+1];
        
        [self performLikeAnimation];
    }
    else if ([self isItemLiked] && [self isButtonLiked]) //we were in liked state
    {
        [self setButtonLiked:NO];
        [self setLikesCountNumber:[self getLikesCountNumber]-1];
        [self performUnLikeAnimation];
    }
    else //ERROR: button and like item are not in sync - sync them
    {
        [self refreshLikeButton];
        isLikeRequestPending = NO;
        return;
    }
    //TODO: check why it fails
    if (([self isItemLiked] && [self isButtonLiked]) || (![self isItemLiked] && ![self isButtonLiked])) //dont do anything if the like state is already as requested
    {
        isLikeRequestPending = NO;
        //   return;
    }
    
    NSString *itemID = [_galleryLayerDelegate getItemID:_indexInGalleryLayout];
    GalleryItemDO *item = [[[AppCore sharedInstance] getGalleryManager] getGalleryItemByItemID:itemID];
    [[DesignsManager sharedInstance] likeDesign:item : ![self isItemLiked] :self :YES withCompletionBlock:^(id serverResponse)
     {
         if (serverResponse != nil)
         {
             BOOL isSuccess = ([(BaseResponse*)serverResponse errorCode] == -1);
             if (isSuccess)
             {
                 
             }
             else
             {
                 //fail
             }
         }
         else
         {
             //fail
         }
         
         [self refreshLikeButton];
         isLikeRequestPending = NO;
     }];
}


-(void) updateCommentsCount: (NSNumber*) nCount
{
    _comments_lbl.text = [NSString numberHandle:[nCount intValue]];
}

-(void) updateLikedState
{
    
    NSString* itemID = [_galleryLayerDelegate getItemID:_indexInGalleryLayout];
    
    
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:itemID];
    
    int likes =  [[likeDO likesCount]intValue];
    BOOL isLiked = [self isItemLiked];
    
    [self setButtonLiked:isLiked];
    
    if(likes ==0)
        
    {
        likes=[likeDO.likesCount intValue];
        
    }
    
    _likes_lbl.text = [NSString numberHandle:likes];
}

- (void) loginRequestEndedwithState:(BOOL) state
{
    if(state == YES)
    {
        [self updateLikedState];
    }
}

#pragma mark - Like Animation

- (void)performLikeAnimation
{
    HSAnimatingView *animView = [[HSAnimatingView alloc] initWithFrame:_btnLikes.frame andAnimationHeight:100];
    animView.image = [UIImage imageNamed:@"like_active"];
    animView.center = [self.view convertPoint:_btnLikes.center fromView:_btnLikes.superview];
    [self.view addSubview:animView];
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [animView animate];
                   });
}

-(void)performUnLikeAnimation {
    HSBrokenAnimatingView  *animView = [[HSBrokenAnimatingView alloc] initWithFrame:self.bottom_barView.frame andBrokenAnimationBtn:CGRectMake(self.bottom_bar_btnsView.frame.origin.x + self.btnLikes.frame.origin.x, self.btnLikes.frame.origin.y, self.btnLikes.frame.size.width, self.btnLikes.frame.size.height)];
    [self.view addSubview:animView];
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [animView animate];
                   });
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}

- (void)likePressedLoginResponseNotification:(NSNotification *)notification
{
    NSString* itemID = [_galleryLayerDelegate getItemID:_indexInGalleryLayout];
	Boolean isSuccess;
    
    [[[notification userInfo] objectForKey:@"isSuccess"] getValue:&isSuccess];
    DesignBaseClass* sentItem = [[notification userInfo] objectForKey:@"item"];
    
    if([[itemID uppercaseString] isEqualToString:[sentItem._id uppercaseString]])
    {
        [self loginRequestEndedwithState:isSuccess];
    }
}

- (void)commentsUpdateCountNotification:(NSNotification *)notification
{
    NSString* itemID = [_galleryLayerDelegate getItemID:_indexInGalleryLayout];
    NSString* sentItemID = [[notification userInfo] objectForKey:@"itemID"];
    NSNumber* sentCommentsCount = [[notification userInfo] objectForKey:@"commentsCount"];
    
    if([itemID isEqualToString:sentItemID])
    {
        [self updateCommentsCount:sentCommentsCount];
    }
}

-(void) clearObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLikeDesignDOLikeStatusChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GalleryStreamItemImageDownloaded2" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.view name:@"NetworkStatusChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"likePressedLoginResponse" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"commentsUpdateCount" object:nil];
}

-(void) addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(likeStatusChanged:)
                                                 name:kNotificationLikeDesignDOLikeStatusChanged
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(GalleryStreamItemImageDownloaded2:)
                                                 name:@"GalleryStreamItemImageDownloaded2"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.view
                                             selector:@selector(reloadUI)
                                                 name:@"NetworkStatusChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(likePressedLoginResponseNotification:)
                                                 name:@"likePressedLoginResponse"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commentsUpdateCountNotification:)
                                                 name:@"commentsUpdateCount"
                                               object:nil];
}

-(BOOL)likesPressedWithResponseOK:(NSString*)designID
{
    BOOL bRetVal = NO;
    NSString* itemID = [_galleryLayerDelegate getItemID:_indexInGalleryLayout];
    
    if([[itemID uppercaseString] isEqualToString:[designID uppercaseString]])
    {
        [self updateLikedState];
        bRetVal = YES;
    }
    return bRetVal;
}

#pragma mark - Sharing Logic

- (BOOL)isDesignImageLoaded
{
    return (self.galleryImage.image != nil);
}

#pragma mark - Double tap recognition
- (IBAction)doubleTapGesture:(UIButton *)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didSingleTap) object:sender];
    didDoubleTap = YES;
    
    if ([self isLoggedIn])
    {
        if (![self isButtonLiked])
        {
            [self likePressed];
        }
    }
}

- (IBAction)singleTapGesture:(UIButton *)sender
{
    if (didDoubleTap)
    {
        didDoubleTap = NO;
    }
    else
    {
        [self performSelector:@selector(didSingleTap) withObject:sender afterDelay:0.2];
    }
}

- (void)didSingleTap
{
    if ((self.galleryLayerDelegate != nil) && ([self.galleryLayerDelegate respondsToSelector:@selector(fullScreenGalleryViewClickedForItemNumber:)]))
    {
        [self.galleryLayerDelegate fullScreenGalleryViewClickedForItemNumber:self.itemNumber];
    }
}

#pragma mark - Like Flow

- (BOOL)isLoggedIn
{
    return [[UserManager sharedInstance] isLoggedIn];
}

- (void)setButtonLiked:(BOOL)liked
{
    self.btnLikesLiked.hidden = !liked;
    self.btnLikes.hidden = liked;
}

- (void)setLikesCountNumber:(int)likesCountNum
{
    _likes_lbl.text = [NSString numberHandle:likesCountNum];
}

- (int)getLikesCountNumber
{
    NSString* itemID = [_galleryLayerDelegate getItemID:_indexInGalleryLayout];
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:itemID];
    int likes =  [[likeDO likesCount] intValue];
    return likes;
}

- (void)refreshLikeButton
{
    [self setButtonLiked:[self isItemLiked]];
    [self setLikesCountNumber:[self getLikesCountNumber]];
}

- (BOOL)isButtonLiked
{
    return (self.btnLikesLiked.isHidden == NO);
}

- (BOOL)isItemLiked
{
    NSString* itemID = [_galleryLayerDelegate getItemID:_indexInGalleryLayout];
    
    
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:itemID];
    
    return [likeDO isUserLiked];
}

- (void)likeStatusChanged:(NSNotification *)notificaiton
{
    NSString *itemId = [[notificaiton userInfo] objectForKey:kNotificationKeyItemId];
    NSString *myItemId = [_galleryLayerDelegate getItemID:_indexInGalleryLayout];
    
    if ([itemId isEqualToString:myItemId])
    {
        [self refreshLikeButton];
    }
}

@end
