//
//  ArticleItemView.m
//  Homestyler
//
//  Created by Yiftach Ringel on 18/06/13.
//
//

#import "ArticleItemView.h"
#import "ImageFetcher.h"
#import "NotificationNames.h"
#import "HSAnimatingView.h"
#import "UILabel+NUI.h"

@interface ArticleItemView ()
{
    BOOL isLikeRequestPending;
}

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *articleImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnlikeLiked;
@property (weak, nonatomic) IBOutlet UIButton *btnComment;
@property (weak, nonatomic) IBOutlet UILabel *lblLikeCount;
@property (weak, nonatomic) IBOutlet UILabel *lblCommentCount;
@property (weak, nonatomic) IBOutlet UIImageView *ivArticle;

- (IBAction)btnCommentPressed:(id)sender;
- (IBAction)btnLikePressed:(id)sender;

@end

@implementation ArticleItemView

- (id)init
{
    self = [[NSBundle mainBundle] loadNibNamed:@"ArticleItemView" owner:self options:nil][0];
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    isLikeRequestPending = NO;

    self.containerView.hidden = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.articleImage.image = nil;
    
    [self setLikesCountNumber:0];
    [self setCommentsCountNumber:0];
}

- (void)setArticle:(GalleryItemDO *)article
{
    _article = article;
    
    if (article != nil)
    {
        self.containerView.hidden = NO;
        
        CGSize designSize = self.articleImage.frame.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (article.url)?article.url:@"",
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : _articleImage};
        
        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                   {
                       NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:_articleImage];
                       
                       if (currentUid == uid)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              if (image) {
                                                  _articleImage.image = image;
                                              }
                                          });
                       }
                   }];
        
        
        self.titleLabel.text = article.title;
        if (self.containerView)
        {
            self.authorLabel.text = article.author;
        }
        else
        {
            self.authorLabel.text =[NSString stringWithFormat:NSLocalizedString(@"author_title", @"author_title"), article.author];
        }
        
        isLikeRequestPending = NO;
        [self refreshLikeButton];
        [self refreshCommentsButton];
    }
    else
    {
        self.containerView.hidden = YES;
    }
    
    self.btnLike.userInteractionEnabled = YES;
    self.btnLike.enabled = YES;
}

- (IBAction)articlePressed
{
    [self.delegate articlePressed:self.article fromArticles:nil];
}



#pragma mark - ProfileCellUnifiedInitDelegate
- (void)initWithData:(id)data andDelegate:(id)delegate  andProfileUserType:(ProfileUserType)profileType{
    self.article = data;
    self.delegate = delegate;
}


- (BOOL)isDesignLiked:(NSString*)designId
{
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:designId];
    
    return [likeDO isUserLiked];
}

- (IBAction)btnCommentPressed:(id)sender
{
        [self.delegate openCommentScreenForDesign:self.article._id withType:self.article.type];
}

- (IBAction)btnLikePressed:(id)sender
{
    [self likePressed];
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
    
    
    [self.delegate performLikeForItem:self.article likeState:![self isItemLiked] sender:nil shouldUsePushDelegate:YES andCompletionBlock:^(BOOL success)
     {
         if (success)
         {
             
         }
         else
         {
             
         }
         
         [self refreshLikeButton];
         isLikeRequestPending = NO;
     }];
}

#pragma mark - Like Flow

- (BOOL)isLoggedIn
{
    return [[UserManager sharedInstance] isLoggedIn];
}

- (void)setButtonLiked:(BOOL)liked
{
    self.btnLike.hidden = liked;
    self.btnlikeLiked.hidden = !liked;
}

- (void)setLikesCountNumber:(int)likesCountNum
{
    self.lblLikeCount.text = [NSString stringWithFormat:@"%d", likesCountNum];
}

- (int)getLikesCountNumber
{
    NSMutableDictionary *likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary;
    LikeDesignDO *likeDO = [likeDict objectForKey:self.article._id];
    
    if (likeDO)
    {
        return [likeDO.likesCount intValue];
    }
    
    return 0;
}

- (void)refreshLikeButton
{
    [self setButtonLiked:[self isItemLiked]];
    [self setLikesCountNumber:[self getLikesCountNumber]];
}

- (BOOL)isButtonLiked
{
    return (self.btnlikeLiked.isHidden == NO);
}

- (BOOL)isItemLiked
{
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:self.article._id];
    
    return [likeDO isUserLiked];
}

- (void)likeStatusChanged:(NSNotification *)notificaiton
{
    NSString *itemId = [[notificaiton userInfo] objectForKey:kNotificationKeyItemId];
    
    if ([itemId isEqualToString:self.article._id])
    {
        [self refreshLikeButton];
    }
}

#pragma marks - Comment

- (void)refreshCommentsButton
{
    [self setCommentsCountNumber:[[self.article  getTotalCommentsCount] intValue]];
}

- (void)setCommentsCountNumber:(int)commentsCountNum
{
    self.lblCommentCount.text = [NSString stringWithFormat:@"%d", commentsCountNum];
}

#pragma mark - Like Animation

- (void)performLikeAnimation
{
    return;
}


@end
