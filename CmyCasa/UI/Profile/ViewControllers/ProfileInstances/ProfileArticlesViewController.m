//
//  ProfileArticlesViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/23/13.
//
//

#import "ProfileArticlesViewController.h"
#import "ArticleItemCollectionView.h"
#import "UserLikesDO.h"
#import "ArticleItemView.h"
#import "ControllersFactory.h"

@interface ProfileArticlesViewController ()

@property (strong, nonatomic) NSMutableArray* articles;

@end

@implementation ProfileArticlesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view
}

- (void)dealloc
{
    
}

- (void)updateDataWithUserFavoriteArticles
{
    if (self.isLoggedInUserProfile) //this is here for the spesific case in which a user had unfavored an article, and now we want to refresh the display so it would not show it anymore
    {
        self.articles = [[[AppCore sharedInstance] getHomeManager].myArticles mutableCopy];
        [self.contentViewer initDisplay:self.articles];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateDataWithUserFavoriteArticles];
}

//Forces Table/Collection to reload Data
-(void)refreshContent{
    [self.contentViewer refreshContent];
}

-(void)initContent {
    if (self.isLoggedInUserProfile) {
        self.articles = [[[AppCore sharedInstance] getHomeManager].myArticles mutableCopy];
        
    }else{
        self.articles = [NSMutableArray array];
    }
    [self loadFavoriteArticles];
    [self.contentViewer initDisplay:self.articles];
}

-(void)initContentViewer{
    if(self.contentViewer== nil)
    {
        if(IS_IPAD)
        {  self.contentViewer=[ControllersFactory instantiateViewControllerWithIdentifier:@"UserProfileCollectionVC" inStoryboard:kProfileStoryboard];
            self.contentViewer.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self.contentViewer.view.clipsToBounds=NO;
        }
        else
        {
            self.contentViewer=[ControllersFactory instantiateViewControllerWithIdentifier:@"UserProfileTableViewVC" inStoryboard:kProfileStoryboard];
            
            self.contentViewer.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            
        }
        
        [self.contentViewer startLoadingIndicator];
        
        self.contentViewer.dataDelegate=self;
        [self addChildViewController:self.contentViewer];
        [self.view addSubview:self.contentViewer.view];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ArticleItemDelegate
- (void)articlePressed:(GalleryItemDO*)article fromArticles:(NSArray*)allArticles
{
    
    if (self.rootArticlesDelegate && [self.rootArticlesDelegate respondsToSelector:@selector(articlePressed:fromArticles:)]) {
        [self.rootArticlesDelegate articlePressed:article fromArticles:self.articles];
    }

}

-(void)loadFavoriteArticles{
    if (self.isLoggedInUserProfile) {
        [[[AppCore sharedInstance] getHomeManager]
                getMyHomeArticlesWithCompletion:^{
                    [self updateDataWithUserFavoriteArticles];

                    dispatch_async(dispatch_get_main_queue(),^(void){

                        [self.contentViewer stopLoadingIndicator];
                        [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
                        if(self.rootArticlesDelegate && [self.rootArticlesDelegate respondsToSelector:@selector(updateProfileCounter:ForTab:)]){

                            [self.rootArticlesDelegate updateProfileCounter:(int)self.articles.count ForTab:ProfileTabArticles];
                        }
                    });
                } failureBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(),^(void){
                [self.contentViewer stopLoadingIndicator];

                [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
            });
        }];
    }else{
        NSString * userId;
        if (self.rootArticlesDelegate && [self.rootArticlesDelegate respondsToSelector:@selector(getUserIDForCurrentProfile)])
        {
            userId= [self.rootArticlesDelegate getUserIDForCurrentProfile];
        }

        if (!userId)
        {
            [self.contentViewer stopLoadingIndicator];
            return;
        }

        [[[AppCore sharedInstance] getHomeManager]getArticlesForUser:userId witchComplition:^(id serverResponse, id error) {


            if (!error) {
                BaseResponse * response=(BaseResponse*)serverResponse;
                if (response && response.errorCode==-1) {

                    UserLikesDO* likes=(UserLikesDO*)serverResponse;

                    [self.articles removeAllObjects];
                    [self.articles addObjectsFromArray:[likes.designs copy]];
                }
            }
            
            [self.contentViewer stopLoadingIndicator];

            [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
            if(self.rootArticlesDelegate && [self.rootArticlesDelegate respondsToSelector:@selector(updateProfileCounter:ForTab:)]){

                [self.rootArticlesDelegate updateProfileCounter:(int)self.articles.count ForTab:ProfileTabArticles];
            }
        } queue:dispatch_get_main_queue()];
    }
}

#pragma mark - ProfilePageCollectionViewDelegate
-(Class)getCollectionCellClass{
    return  [ArticleItemCollectionView class];
}

-(CollectionViewRowsSize)getCollectionGridSize{
    CollectionViewRowsSize size;
    size.collumnsCount = 5;
    size.minRowsCount = 1;
    return  size;
}

-(CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    return CGSizeMake(759, 235);
}

-(UIEdgeInsets) getCellEdgeInsets{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
-(NSString *)getMessageForEmptyData:(BOOL)isCurrentUser{

    if (isCurrentUser)
        return [NSString stringWithFormat:NSLocalizedString(@"myhome_no_articles_copy", "") , [ConfigManager getAppName]];
    else
        return [NSString stringWithFormat:NSLocalizedString(@"myhome_no_articles_copy_other", ""), [ConfigManager getAppName]];
}

-(CGFloat)minimumLineSpacingForSection
{
    return 0.0;
}

#pragma mark - LikeDesignDelegate
- (BOOL) performLikeForItem:(DesignBaseClass*)item likeState:(BOOL) isLiked sender:(UIViewController*) sender  shouldUsePushDelegate:(BOOL) shouldUsePush andCompletionBlock:(void(^)(BOOL success))completion
{
    if (self.rootArticlesDelegate && [self.rootArticlesDelegate respondsToSelector:@selector(performLikeForItemId:withItemType:likeState:sender:shouldUsePushDelegate:andCompletionBlock:)])
    {
        [self.rootArticlesDelegate performLikeForItem:item
                                           likeState:isLiked
                                                 sender:sender
                                  shouldUsePushDelegate:shouldUsePush
                                     andCompletionBlock:completion];
    }
    
    return NO;
}

- (void)performLikeForItemId:(NSString *)itemId withItemType:(ItemType)itemType likeState:(BOOL)isLiked sender:(UIViewController *)sender shouldUsePushDelegate:(BOOL)shouldUsePush andCompletionBlock:(void (^)(BOOL))completion
{
    if (self.rootArticlesDelegate && [self.rootArticlesDelegate respondsToSelector:@selector(performLikeForItemId:withItemType:likeState:sender:shouldUsePushDelegate:andCompletionBlock:)])
    {
        [self.rootArticlesDelegate performLikeForItemId:itemId
                                         withItemType:itemType
                                            likeState:isLiked
                                               sender:sender
                                shouldUsePushDelegate:shouldUsePush
                                   andCompletionBlock:completion];
    }
}

#pragma mark - CommentDesignDelegate
- (void)openCommentScreenForDesign:(NSString *)designId withType:(ItemType)type
{
    if (self.rootArticlesDelegate && [self.rootArticlesDelegate respondsToSelector:@selector(openCommentScreenForDesign:withType:)])
    {
        return [self.rootArticlesDelegate openCommentScreenForDesign:designId withType:type];
    }
}

- (NSString *)getCommentForActivityId:(NSString *)strId timestamp:(NSTimeInterval)ts
{
    if (self.rootArticlesDelegate && [self.rootArticlesDelegate respondsToSelector:@selector(getCommentForActivityId:timestamp:)])
    {
        return [self.rootArticlesDelegate getCommentForActivityId:strId timestamp:ts];
    }
    
    return nil;
}

#pragma mark - ProfessionalCellDelegate
-(void)rowSelectedAtIndex:(NSIndexPath*)indexPath{

    if (indexPath.row < self.articles.count)
    {
        [self articlePressed:self.articles[indexPath.row] fromArticles:self.articles];
    }
}

-(NSString*)getCellIdentifierForIndexpath:(NSIndexPath *)path{
    return ARTICLE_ITEM_CELL_IDENTIFIER;
}

-(UITableViewCell *)getTableViewCellForIndexpath:(NSIndexPath *)path{
    return [[ArticleItemView alloc] init];
}

- (NSInteger)heightForRowAtIndexpath:(NSIndexPath *)path{
    return (IS_IPAD)?334:ARTICLE_ITEM_CELL_HEIGHT;
}

@end
