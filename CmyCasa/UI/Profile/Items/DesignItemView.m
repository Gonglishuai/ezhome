//
//  DesignItemView.m
//  Homestyler
//
//  Created by Yiftach Ringel on 18/06/13.
//
//

#import "DesignItemView.h"
#import "NotificationNames.h"
#import "ImageFetcher.h"
#import "UILabel+NUI.h"
#import "HSAnimatingView.h"
#import "HSBrokenAnimatingView.h"
#import "NSString+CommentsAndLikesNum.h"
#import "NewBaseProfileViewController.h"

@interface DesignItemView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *designImage;
@property (weak, nonatomic) IBOutlet UIButton *ribbonButton;
@property (weak, nonatomic) IBOutlet UILabel *lblLikeCount;
@property (weak, nonatomic) IBOutlet UILabel *lblCommentCount;
@property (weak, nonatomic) IBOutlet UIButton *btnComment;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIImageView *ivFeatureBadge;
@property (weak, nonatomic) IBOutlet UIView *statsContainer;


- (IBAction)designPressed;
@end

@implementation DesignItemView

- (id)init
{
    self = [[NSBundle mainBundle] loadNibNamed:@"DesignItemView" owner:self options:nil][0];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.ribbonButton.hidden = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(designStatusChanged:) name:kNotificationMyDesignDOStatusChanged object:nil];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setDesignImage];
    });
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.ribbonButton.hidden = YES;
    self.designImage.image = nil;
    
    self.btnComment.hidden = YES;
    self.btnLike.hidden = YES;
    
    [self.btnComment setEnabled:NO];
    [self.btnLike setEnabled:NO];
    
    self.titleLabel.text = nil;
    self.lblCommentCount.text = nil;
    self.lblLikeCount.text = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(designStatusChanged:) name:kNotificationMyDesignDOStatusChanged object:nil];
}

- (void)setDesign:(MyDesignDO *)design
{
    _design = design;
    
    if (design)
    {
        self.ribbonButton.hidden = !self.isCurrentUserDesign;
        
        // The edit button should not be displayed if a design is published
        if (self.isCurrentUserDesign)
        {
            self.ribbonButton.hidden = [design isDesignPublished];
        }
        
        // If the item is private or an autosave, disable commenting or like actions
        if (!self.design.publishStatus || STATUS_PRIVATE == self.design.publishStatus)
        {
            self.btnComment.hidden = NO;
            self.btnLike.hidden = NO;
            
            [self.btnComment setEnabled:NO];
            [self.btnLike setEnabled:NO];
            
            self.lblCommentCount.hidden = NO;
            self.lblLikeCount.hidden = NO;
        }else{
            self.btnComment.hidden = NO;
            self.btnLike.hidden = NO;
            
            [self.btnComment setEnabled:YES];
            [self.btnLike setEnabled:YES];
            
            self.lblCommentCount.hidden = NO;
            self.lblLikeCount.hidden = NO;
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
        
        self.titleLabel.text = design.title;
        
        self.lblCommentCount.text = [NSString numberHandle:[[self.design getTotalCommentsCount] intValue]];
        
        self.lblLikeCount.text = [NSString numberHandle:[self getLikesCountNumber]];

        if (_design.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
            SavedDesign * autoDesign = [[DesignsManager sharedInstance] workingDesign];
            [self.designImage setImage:autoDesign.image];
            self.autosaveLayer.hidden = NO;
            self.statusLabel.text = NSLocalizedString(@"auto_saved_design_title", @"");
        }
        else
        {
            self.autosaveLayer.hidden = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self isItemLiked]) {
                [self.btnLike setImage:[UIImage imageNamed:@"like_active"] forState:UIControlStateNormal];
            }else{
                [self.btnLike setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
            }

            [self refreshDesignStatus];
        });
    }
}

-(void)setDesignImage {
    CGSize designSize = self.designImage.frame.size;
    NSValue *valSize = [NSValue valueWithCGSize:designSize];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (_design.url)?_design.url:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : _designImage,
                          IMAGE_FETCHER_INFO_KEY_SMARTFIT : [NSNumber numberWithBool:NO]};
    
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)btnCommentPressed:(id)sender
{
    [self.delegate designPressed:self.design];  
//    [self.delegate openCommentScreenForDesign:self.design._id withType:self.design.type];
}

- (BOOL)isDesignLiked:(NSString*)designId
{
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:designId];
    
    return [likeDO isUserLiked];
}

- (IBAction)btnLikePressed:(id)sender
{
    NewBaseProfileViewController *currentVC = (NewBaseProfileViewController *)self.delegate;
    
    if (![[UserManager sharedInstance] isLoggedIn]) {
        [[UIMenuManager sharedInstance] loginRequestedIphone:currentVC withCompletionBlock:^(BOOL success) {
            if (success == YES) {
                [self btnLikePressed:nil];
            }
        }                                         loadOrigin:EVENT_PARAM_LOAD_ORIGIN_LIKE];
    }else{
        if (![self isItemLiked]) {
            [self performLikeAnimation];
            [self setLikesCountNumber:[self getLikesCountNumber] + 1];
            [self.btnLike setImage:[UIImage imageNamed:@"like_active"] forState:UIControlStateNormal];
        }else{
            [self performUnLikeAnimation];
            [self setLikesCountNumber:[self getLikesCountNumber] - 1];
            [self.btnLike setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        }
        
        self.btnLike.userInteractionEnabled = NO;
        
        [self.delegate performLikeForItemId:self.design._id
                               withItemType:self.design.type
                                  likeState:![self isDesignLiked:self.design._id]
                                     sender:nil
                      shouldUsePushDelegate:YES
                         andCompletionBlock:^(BOOL success){
                             
                             if (success) {
                                 
                             }else{
                                 [self setLikesCountNumber:[self getLikesCountNumber]];
                                 
                                 if ([self isItemLiked]) //we were in unliked state
                                 {
                                     [self.btnLike setImage:[UIImage imageNamed:@"like_active"] forState:UIControlStateNormal];
                                 }else{
                                     [self.btnLike setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
                                 }
                             }
                             
                             
                             self.btnLike.userInteractionEnabled = YES;
                         }];
    }
}

- (BOOL)isItemLiked
{
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:self.design._id];
    
    return [likeDO isUserLiked];
}

- (int)getLikesCountNumber
{
    NSMutableDictionary *likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary;
    LikeDesignDO *likeDO = [likeDict objectForKey:self.design._id];
    int likes = [[likeDO likesCount] intValue];
    
    return likes;
}

- (void)setLikesCountNumber:(int)likesCountNum
{
    self.lblLikeCount.text = [NSString numberHandle:likesCountNum];
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
    HSBrokenAnimatingView  *animView = [[HSBrokenAnimatingView alloc] initWithFrame:self.statsContainer.bounds andBrokenAnimationBtn:self.btnLike.frame];
    [self.statsContainer addSubview:animView];
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [animView animate];
                   });
}

#pragma mark - ProfileCellUnifiedInitDelegate
- (void)initWithData:(id)data andDelegate:(id)delegate  andProfileUserType:(ProfileUserType)profileType{
    self.isCurrentUserDesign=profileType== kUserProfileTypeLoggedInUser;
    self.design = data;
    self.delegate = delegate;
}

@end
