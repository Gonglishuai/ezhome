//
//  ArticleItemView.m
//  Homestyler
//
//  Created by Yiftach Ringel on 18/06/13.
//
//

#import "ArticleItemCollectionView.h"
#import "GalleryItemDO.h"
#import "UIView+Effects.h"
#import "ImageFetcher.h"
#import "UILabel+NUI.h"

@interface ArticleItemCollectionView ()

- (IBAction)articlePressed;
- (NSInteger)getCurrentLikeCount:(NSString*)designId;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *articleImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ArticleItemCollectionView

- (id)init
{
    self = [[NSBundle mainBundle] loadNibNamed:@"ArticleItemCollectionView" owner:self options:nil][0];
    
        return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
     self.articleImage.image = nil;
    self.containerView.hidden = YES;
}

- (void)setArticle:(GalleryItemDO *)article
{
    _article = article;

    if (article != nil)
    {
        self.containerView.hidden = NO;
        
        self.lblCommentCount.text = [NSString stringWithFormat:@"%@",article.commentsCount];
        self.lblLikeCount.text = [NSString stringWithFormat:@"%@",article.tempLikeCount];
        [self setLikeButtonImage];
        CGSize designSize = self.articleImage.frame.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (article.url)?article.url:@"",
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : _articleImage};
        
        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary * imageMeta)
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

        self.titleLabel.text = [article.title uppercaseString];
        self.lblDescription.text = article._description;
    }
    else
    {
        self.containerView.hidden = YES;
    }
}

- (BOOL)isArticleLiked:(NSString*)designId
{
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:designId];
    
    return [likeDO isUserLiked];
}

- (void)setLikeButtonImage
{
    BOOL isLiked = [self isArticleLiked:self.article._id];
    
    self.btnLike.hidden = isLiked;
    self.btnLikeLiked.hidden = !isLiked;
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

- (IBAction)articlePressed
{
    [self.delegate articlePressed:self.article fromArticles:nil];
}

- (IBAction)commentPressed:(id)sender
{
    [self.delegate openCommentScreenForDesign:self.article._id withType:eArticle];
}

- (IBAction)likePressed:(id)sender
{
    [self.delegate performLikeForItem:self.article likeState:![self isArticleLiked:self.article._id] sender:nil shouldUsePushDelegate:YES andCompletionBlock:^(BOOL success) {
        [self setLikeButtonImage];
        self.lblLikeCount.text = [NSString stringWithFormat:@"%ld",(long)[self getCurrentLikeCount:self.article._id]];
    }];
}

#pragma mark - ProfileCellUnifiedInitDelegate
- (void)initWithData:(id)data andDelegate:(id)delegate  andProfileUserType:(ProfileUserType)profileType{
    self.article = data;
    self.delegate = delegate;
}

@end
