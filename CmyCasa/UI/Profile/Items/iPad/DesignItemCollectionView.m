//
//  DesignItemView.m
//  Homestyler
//
//  Created by Yiftach Ringel on 18/06/13.
//
//

#import "DesignItemCollectionView.h"
#import "NotificationNames.h"
#import "MyDesignDO.h"
#import "UIView+Alignment.h"
#import "UIView+Effects.h"
#import "ImageFetcher.h"
#import "UILabel+NUI.h"
#import "HSAnimatingView.h"
#import "HSBrokenAnimatingView.h"
#import "NSString+CommentsAndLikesNum.h"
#import "NewBaseProfileViewController.h"

@interface DesignItemCollectionView ()

- (IBAction)designPressed;
- (IBAction)editPressed;
- (void)setLikeButtonImage;
- (BOOL)isDesignLiked:(NSString*)designId;
- (NSInteger)getCurrentLikeCount:(NSString*)designId;
@end

@implementation DesignItemCollectionView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(designStatusChanged:) name:kNotificationMyDesignDOStatusChanged object:nil];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.containerView.hidden = YES;
    self.ribbonButton.hidden = YES;
    self.designImage.image = nil;
    self.ivFeatureBadge.hidden = YES;
    
    self.btnComment.hidden = YES;
    self.btnLike.hidden = YES;
    self.btnLikeLiked.hidden = YES;
    
    [self.btnComment setEnabled:YES];
    [self.btnLike setEnabled:YES];
    [self.btnLikeLiked setEnabled:YES];
    
    self.titleLabel.text = nil;
    self.lblCommentCount.text = nil;
    self.lblLikeCount.text = nil;
}

- (void)setDesign:(MyDesignDO *)design
{
    _design = design;

    if (design)
    {
        self.containerView.hidden = NO;
        self.ribbonButton.hidden = !self.isCurrentUserDesign;
        
        // The edit button should not be displayed if a design is published
        if (self.isCurrentUserDesign) {
            self.ribbonButton.hidden = [design isDesignPublished];
        }
        
        // Show the featured badge if item is featured
        if (STATUS_PUBLISHED != self.design.publishStatus)
        {
            self.ivFeatureBadge.hidden = YES;
        }
        else
        {
            self.ivFeatureBadge.hidden = NO;
        }
        
        // If the item is private or an autosave, disable commenting or like actions
        if (!self.design.publishStatus || STATUS_PRIVATE == self.design.publishStatus)
        {
            self.btnComment.hidden = NO;
            [self setLikeButtonImage];
            
            [self.btnComment setEnabled:YES];
            [self.btnLike setEnabled:NO];
            [self.btnLikeLiked setEnabled:NO];
            
            self.lblCommentCount.hidden = NO;
            self.lblLikeCount.hidden = NO;
        }else{
            self.btnComment.hidden = NO;
            self.btnLike.hidden = NO;
            self.btnLikeLiked.hidden = NO;
            
            [self.btnComment setEnabled:YES];
            [self.btnLike setEnabled:YES];
            [self.btnLikeLiked setEnabled:YES];
            
            self.lblCommentCount.hidden = NO;
            self.lblLikeCount.hidden = NO;
        }
        
        self.lblCommentCount.text = [NSString numberHandle:[self.design.commentsCount intValue]];
        self.lblLikeCount.text = [NSString numberHandle:[self.design.tempLikeCount intValue]];
        
        if (_design.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
            SavedDesign * autoDesign = [[DesignsManager sharedInstance] workingDesign];
            
            self.statusLabel.text = NSLocalizedString(@"auto_saved_design_title", @"");
            self.autosaveLayer.hidden = NO;
            if (!autoDesign.image) {
                [autoDesign loadPreviewImageOnlyIntoUIImage];
            }
            [self.designImage setImage:autoDesign.image];
            
        }else if (_design.eSaveDesignStatus == SAVED_DESIGN_STATUS_WAITING_FOR_SYNC){
            SavedDesign * offlineDesign = [[DesignsManager sharedInstance] generateDesignDOFromMyDesignDO:_design.autoSavedDesignRefID];
            [offlineDesign loadPreviewImageOnlyIntoUIImage];
            [self.designImage setImage:offlineDesign.image];
        }
        else
        {
            self.titleLabel.text = design.title;

            self.autosaveLayer.hidden = YES;
            
            CGSize designSize = self.designImage.frame.size;
            NSValue *valSize = [NSValue valueWithCGSize:designSize];
            NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (design.url)?design.url:@"",
                                  IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                                  IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                                  IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : _designImage,
                                  IMAGE_FETCHER_INFO_KEY_SMARTFIT : [NSNumber numberWithBool:NO]
                                  };
            
            NSInteger lastUid = -1;
            lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                       {
                           NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:_designImage];
                           
                           if (currentUid == uid)
                           {
                               dispatch_async(dispatch_get_main_queue(), ^
                                              {
                                                  self.designImage.image = image;
                                              });
                           }
                       }];
       
        }
        [self.containerView strokeWithWidth:1.0 cornerRadius:0.0 color:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15]];
        
        if (self.design.publishStatus != STATUS_PRIVATE) {
            [self setLikeButtonImage];
        }
      
        [self refreshDesignStatus];
    }
    else
    {
        self.containerView.hidden = YES;
    }
}

- (void)designStatusChanged:(NSNotification *)notification
{
    NSString *designId = [[notification userInfo] objectForKey:kNotificationKeyItemId];
    
    if ([designId isEqualToString:self.design._id])
    {
        [self refreshDesignStatus];
    }
}

- (void)refreshDesignStatus
{
    if (_design)
    {
        if (_design.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
             self.statusLabel.text = NSLocalizedString(@"auto_saved_design_title", @"");
            return;
        }else if(_design.eSaveDesignStatus == SAVED_DESIGN_STATUS_WAITING_FOR_SYNC){
            self.statusLabel.text = NSLocalizedString(@"waitting_to_sync", @"");
            return;
        }
        
        switch (_design.publishStatus) {
            case STATUS_PRIVATE:
                self.statusLabel.text = NSLocalizedString(@"design_private", @"Private design");
                self.statusLabel.textColor = [UIColor colorWithRed:198/255.0 green:34/255.0 blue:41/255.0 alpha:1];
                break;
            case STATUS_PUBLIC:
                self.statusLabel.text = @"";
                self.statusLabel.textColor = [UIColor colorWithWhite:89/255.0 alpha:1];
                break;
            case STATUS_PUBLISHED:
                self.statusLabel.text = @"";
                self.statusLabel.textColor = [UIColor colorWithRed:99/255.0 green:170/255.0 blue:2/255.0 alpha:1];
                break;
            default:
                break;
        }
    }
}

- (IBAction)designPressed
{
    [self.delegate designPressed:self.design];
}

- (IBAction)editPressed
{
    [self.delegate designEditPressed:self.design];
}

- (IBAction)commentPressed:(id)sender
{
    [self.delegate openCommentScreenForDesign:self.design._id withType:self.design.type];
}

- (BOOL)isDesignLiked:(NSString*)designId
{
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:designId];
    
    return [likeDO isUserLiked];
}

- (NSInteger)getCurrentLikeCount:(NSString*)designId{
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:designId];
    
    NSInteger likeCount = 0;
    if (likeDO) {
    likeCount = [[likeDO likesCount] integerValue];
    }
    return likeCount;
}

- (void)setLikeButtonImage
{    
    BOOL isLiked = [self isDesignLiked:self.design._id];
    
    self.btnLike.hidden = isLiked;
    self.btnLikeLiked.hidden = !isLiked;
}

- (IBAction)likePressed:(id)sender
{
    NewBaseProfileViewController *currentVC = (NewBaseProfileViewController *)self.delegate;
    
    if (![[UserManager sharedInstance] isLoggedIn]) {
        [[UIMenuManager sharedInstance] loginRequestedIphone:currentVC withCompletionBlock:^(BOOL success) {
            if (success == YES) {
                [self likePressed:nil];
            }
        }                                         loadOrigin:EVENT_PARAM_LOAD_ORIGIN_LIKE];
    }else{
        BOOL isLiked = [self isDesignLiked:self.design._id];
        if (!isLiked) {
            [self performLikeAnimation];
            self.btnLikeLiked.hidden = NO;
            self.btnLike.hidden = YES;
            self.lblLikeCount.text = [NSString numberHandle:(int)[self getCurrentLikeCount:self.design._id] + 1];
        }else{
            [self performUnLikeAnimation];
            self.btnLikeLiked.hidden = YES;
            self.btnLike.hidden = NO;
            self.lblLikeCount.text = [NSString numberHandle:(int)[self getCurrentLikeCount:self.design._id] - 1];
        }
        
        self.userInteractionEnabled = NO;
        [self.delegate performLikeForItemId:self.design._id
                               withItemType:self.design.type
                                  likeState:![self isDesignLiked:self.design._id]
                                     sender:nil
                      shouldUsePushDelegate:YES
                         andCompletionBlock:^(BOOL success) {
                             if (success) {
                                 
                             }else{
                                 [self setLikeButtonImage];
                                 self.lblLikeCount.text = [NSString numberHandle:(int)[self getCurrentLikeCount:self.design._id]];
                             }
                             self.userInteractionEnabled = YES;
                         }];
    }
}

#pragma mark - Like Animation

- (void)performLikeAnimation
{
    HSAnimatingView *animView = [[HSAnimatingView alloc] initWithFrame:_btnLike.frame andAnimationHeight:100];
    animView.image = [UIImage imageNamed:@"like_active"];
    animView.center = [self convertPoint:_btnLike.center fromView:_btnLike.superview];
    [self addSubview:animView];
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [animView animate];
                   });
}

-(void)performUnLikeAnimation {
    HSBrokenAnimatingView  *animView = [[HSBrokenAnimatingView alloc] initWithFrame:self.statsContainer.bounds andBrokenAnimationBtn:CGRectMake(self.btnLike.frame.origin.x, 0, self.btnLike.frame.size.width, self.btnLike.frame.size.height)];
    [self.statsContainer addSubview:animView];
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [animView animate];
                   });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - ProfileCellUnifiedInitDelegate
- (void)initWithData:(id)data andDelegate:(id)delegate  andProfileUserType:(ProfileUserType)profileType{
    self.isCurrentUserDesign=profileType== kUserProfileTypeLoggedInUser;
    self.design = data;
    self.delegate = delegate;
}

@end
