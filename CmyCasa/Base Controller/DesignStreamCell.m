//
//  DesignStreamCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/10/13.
//
//

#import "DesignStreamCell.h"
#import "UILabel+Size.h"
#import <QuartzCore/QuartzCore.h>
#import "LikeDesignDO.h"
#import "UIImageView+ViewMasking.h"
#import "HSAnimatingView.h"
#import "HSBrokenAnimatingView.h"
#import "NSObject+MultiShare.h"
#import "UIMenuManager.h"
#import "HSSharingLogic.h"
#import "NotificationNames.h"
#import "GalleryItemDO.h"
#import "UIView+Effects.h"
#import "ImageFetcher.h"
#import "UILabel+NUI.h"
#import "UIView+ReloadUI.h"
#import "NSString+CommentsAndLikesNum.h"

@interface DesignStreamCell ()
{
    BOOL didDoubleTap;
    
    int iLikeRequestCount;
    BOOL isLikeRequestPending;
    
    __weak IBOutlet NSLayoutConstraint *_itemTitleWidth;
    __weak IBOutlet NSLayoutConstraint *_authorTitleLeading;
    __weak IBOutlet NSLayoutConstraint *_authorTitleWidth;
}

@property (nonatomic, strong) UITapGestureRecognizer *grSingleTap;
@property (nonatomic, strong) UITapGestureRecognizer *grDoubleTap;

@end

@implementation DesignStreamCell
@synthesize shareImageUrl;
@synthesize shareImagePath;

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self clearImages];
    isLikeRequestPending = NO;
    [self reloadUI];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)clearImages{
    self.designImage.image=nil;
    self.userImage.image=nil;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    didDoubleTap = NO;
    iLikeRequestCount = 0;
    isLikeRequestPending = NO;
    
    [self.userImage setMaskToCircleWithBorderWidth:1.0 andColor:[UIColor whiteColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(likeStatusChanged:)
                                                 name:kNotificationLikeDesignDOLikeStatusChanged
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(GalleryStreamItemImageDownloaded2:)
                                                 name:@"GalleryStreamItemImageDownloaded2"
                                               object:nil];
    
    [self reloadUI];
}

-(void)showUserProfileImage {
    [self.userProfilePicView setHidden:NO];
    
    static const CGFloat SPACING = 3.0;
    // TODO: itemTitle's frame won't be up-to-date before layout is done
    //CGFloat availableLength = self.commentButton.frame.origin.x - self.itemTitle.frame.origin.x - SPACING;
    CGFloat availableLength = [UIScreen mainScreen].bounds.size.width - 156/* space between 'comment' button and right border */  - self.itemTitle.frame.origin.x;

    _itemTitleWidth.constant = availableLength;
    
    _authorTitleLeading.constant = SPACING;
    _authorTitleWidth.constant = availableLength;
}

-(void)hideUserProfileImage {
    [self.userProfilePicView setHidden:YES];
    
    // TODO: self.frame won't be up-to-date before layout is done
    CGFloat availableLength = [UIScreen mainScreen].bounds.size.width/*self.frame.size.width*/ - self.itemTitle.frame.origin.x * 2;
    
    _itemTitleWidth.constant = availableLength;
    
    _authorTitleLeading.constant = -self.userImage.frame.size.width;
    _authorTitleWidth.constant = availableLength;
}

-(void)initCellWithGalleryItem:(GalleryItemDO*)item
{
    
    if (item.type == eEmptyRoom) {
        self.userImage.hidden = YES;
    }else{
        [self clearImages];
    }
    self.m_item=item;
    if (item.type==eArticle && IS_IPAD)
    {
        self.itemTitle.text=@"";
    }
    else
    {
        self.itemTitle.text=  item.title;
    }
    
    if([self.m_item.author length]>0)
    {
        self.authorTitle.text= [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"by_prefix", "") ,self.m_item.author];
        
    }else
        self.authorTitle.text=@"";
    
    self.likesCount.text=[NSString numberHandle:[item getLikesCountForDesign]];
  
    self.commnetsCount.text=[NSString numberHandle:[[item  getTotalCommentsCount] intValue]];
    
    self.typeIcon.hidden=(item.type==e3DItem)?NO:YES;
    
    //load design image
    CGSize designSize = self.frame.size;
    NSValue *valSize = [NSValue valueWithCGSize:designSize];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (item.url)?item.url:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.designImage};
    
    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
               {
                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.designImage];
                   
                   if (currentUid == uid)
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          [self cellImageUpadewithImage:image];
                                      });
                   }
               }];
    
    if (item.type != eArticle && item.type != eEmptyRoom) {
        [self showUserProfileImage];
    }else{
        [self hideUserProfileImage];
    }
    
    BOOL hidden = self.m_item.type == eEmptyRoom;
    self.commnetsCount.hidden = hidden;
    self.likesCount.hidden = hidden;
    self.commentButton.hidden = hidden;
    self.likeButtonLiked.hidden = hidden;
    self.likeButton.hidden = hidden;
    self.shareButton.hidden = hidden;
    
    if (!hidden) {
        [self setButtonLiked:[self isItemLiked]];
    }

    isLikeRequestPending = NO;
}

-(void)loadUserProfileImageForIndexPath:(NSIndexPath*)path{
    self.userImage.image = [UIImage imageNamed:@"iph_profile_settings_image.png"];
    NSString* imageUrlStr = @"";
    if ([self.m_item.uthumb rangeOfString:@"facebook"].location != NSNotFound) {
        imageUrlStr = [NSString stringWithFormat:@"%@?type=large",self.m_item.uthumb];
    }else{
        imageUrlStr = self.m_item.uthumb;
    }
    
    if ([imageUrlStr isEqualToString:@""]==false)
    {
        //load design image
        CGSize designSize = self.userImage.bounds.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL:(imageUrlStr)?imageUrlStr:@"",
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.userImage};

        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                   {
                       NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.userImage];
                       
                       if (currentUid == uid)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              if (image) {
                                                  self.userImage.image = image;
                                              }
                                              else {
                                                  self.userImage.image=[UIImage imageNamed:@"iph_profile_settings_image.png"];
                                              }
                                          });
                       }
                   }];
    }
    else
    {
        self.userProfilePicView.hidden=NO;
        self.userImage.image=[UIImage imageNamed:@"iph_profile_settings_image.png"];
        
    }
}

-(void)cellImageUpadewithImage:(UIImage*)image{
    self.designImage.alpha=0.0;
    [self.designImage setImage:image];
    [UIView animateWithDuration:0.4 animations:^{
        self.designImage.alpha = 1.0;
    }];
}

- (IBAction)likeAction:(id)sender
{
    
    
    
    if ([self isLoggedIn])
    {
        [self likePressed];
    }
    else
    {
        
        //sent to log which type of list send the request
        NSString * itemTypeKey=@"";
        switch (self.m_item.type) {
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
//        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:@{EVENT_PARAM_SIGNUP_TRIGGER:itemTypeKey, EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_LOAD_ORIGIN_LIKE,
//                                                                                  EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_LOAD_ORIGIN_LIKE}];
        
        
        [[UIMenuManager sharedInstance] loginRequestedIphone:[self.delegate superViewContoller] withCompletionBlock:^(BOOL success) {
            if (success == YES) {
                [self likePressed];
            }
        } loadOrigin:EVENT_PARAM_LOAD_ORIGIN_LIKE ];
    }
}



- (IBAction)openFullScreenWithComments:(id)sender {
    
    if (self.delegate) {
        [self.delegate commentButtonPressedForDesign:self.m_item];
    }
}

-(void)GalleryStreamItemImageDownloaded2:(NSNotification*)notification{
    
    NSMutableDictionary * dict=[NSMutableDictionary dictionaryWithDictionary:[notification userInfo]];
    
    self.shareImagePath = [dict objectForKey:@"path"];
}

- (IBAction)shareAction:(id)sender
{
    if (![ConfigManager isAnyNetworkAvailable]) {
        [ConfigManager showMessageIfDisconnected];
        return;
    }
    
    //cancel share action if the image of current design is not loaded yet
    if (![self isDesignImageLoaded]) {
        return;
    }
    
    HSCompletionBlock updateBlock=^(id serverResponse, id error) {
        
        UIImage * screen=(UIImage*)serverResponse;

        if (self.delegate && [self.delegate respondsToSelector:@selector(shareButtonPressedForDesign:withDesignImage:)]) {
            [self.delegate shareButtonPressedForDesign:self.m_item withDesignImage:screen];
        }
    };
    
    //load design image
    CGSize designSize = self.frame.size;
    NSValue *valSize = [NSValue valueWithCGSize:designSize];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (self.m_item.url)?self.m_item.url:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.designImage};
    
    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
               {
                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.designImage];
                   
                   if (currentUid == uid)
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          updateBlock(image,nil);
                                      });
                   }
               }];
    
}

- (IBAction)userProfileActionClick:(id)sender {
    
    if (self.delegate && ![self.m_item.uid isEqualToString:[ConfigManager getCompanyDesignerUid]]) {
        
        [self.delegate profileButtonPressedForDesign:self.m_item];
    }
}

#pragma mark - Like Logic

- (void)likePressed
{
    if (isLikeRequestPending)
    {
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
    
    if (([self isItemLiked] && [self isButtonLiked]) || (![self isItemLiked] && ![self isButtonLiked])) //dont do anything if the like state is already as requested
    {
        isLikeRequestPending = NO;
        return;
    }
    
    if (![ConfigManager isAnyNetworkAvailable]) {
        [ConfigManager showMessageIfDisconnected];
        
        isLikeRequestPending = NO;
        return;
    }
    
    [[DesignsManager sharedInstance] likeDesign:self.m_item : ![self isItemLiked] :[self.delegate superViewContoller] :NO withCompletionBlock:^(id serverResponse)
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

#pragma mark - Like Animation

- (void)performLikeAnimation
{
    HSAnimatingView *animView = [[HSAnimatingView alloc] initWithFrame:self.likeButton.frame andAnimationHeight:100];
    animView.image = [UIImage imageNamed:@"like_active"];
    
    [self.likeButton.superview addSubview:animView];
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [animView animate];
                   });
}

-(void)performUnLikeAnimation {
    HSBrokenAnimatingView  *animView = [[HSBrokenAnimatingView alloc] initWithFrame:self.statsContainer.frame andBrokenAnimationBtn:self.likeButton.frame];
    [self addSubview:animView];
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [animView animate];
                   });
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
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(didTapOnCell:)]))
    {
        [self.delegate didTapOnCell:self];
    }
}


#pragma mark - Sharing Logic

- (BOOL)isDesignImageLoaded
{
    return (self.designImage.image != nil);
}

#pragma mark - Like Flow

- (BOOL)isLoggedIn
{
    return [[UserManager sharedInstance] isLoggedIn];
}

- (void)setButtonLiked:(BOOL)liked
{
    self.likeButtonLiked.hidden = !liked;
    self.likeButton.hidden = liked;
}

- (void)setLikesCountNumber:(int)likesCountNum
{
    self.likesCount.text = [NSString numberHandle:likesCountNum];
}

- (int)getLikesCountNumber
{
    return [self.m_item getLikesCountForDesign];
}

- (void)refreshLikeButton
{
    [self setButtonLiked:[self isItemLiked]];
    [self setLikesCountNumber:[self getLikesCountNumber]];
}

- (BOOL)isButtonLiked
{
    return (self.likeButtonLiked.isHidden == NO);
}

- (BOOL)isItemLiked
{
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:_m_item._id];
    
    return [likeDO isUserLiked];
}

- (void)likeStatusChanged:(NSNotification *)notificaiton
{
    NSString *itemId = [[notificaiton userInfo] objectForKey:kNotificationKeyItemId];
    
    if ([itemId isEqualToString:_m_item._id])
    {
        [self refreshLikeButton];
    }
}

- (void)dealloc
{
    NSLog(@"dealloc - DesignStreamCell");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end




