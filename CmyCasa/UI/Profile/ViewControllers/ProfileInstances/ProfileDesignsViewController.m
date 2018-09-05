//
//  ProfileDesignsViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/23/13.
//
//

#import "ProfileDesignsViewController.h"
#import "ControllersFactory.h"
#import "DesignItemCollectionView.h"
#import "NotificationNames.h"

@interface ProfileDesignsViewController ()
@end

@implementation ProfileDesignsViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    //new autosave design
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContent) name:kNotificationDesignManagerChanged object:nil];
}

//Forces Table/Collection to reload Data
-(void)refreshContent{
    
    [self.contentViewer refreshContent];
    
    if([self.rootDesignDelegate respondsToSelector:@selector(updateProfileCounter:ForTab:)]){
        NSArray * designArray = [[DesignsManager sharedInstance] designsArray];
        [self.rootDesignDelegate updateProfileCounter:(int)designArray.count ForTab:ProfileTabDesign];
    }
}

-(void)initContentViewer{
    if(self.contentViewer== nil)
    {
        if(IS_IPAD)
        {  self.contentViewer=[ControllersFactory instantiateViewControllerWithIdentifier:@"UserProfileCollectionVC" inStoryboard:kProfileStoryboard];
        self.contentViewer.view.frame=CGRectMake(11, 18, self.view.frame.size.width-18, self.view.frame.size.height-36);
            self.contentViewer.view.clipsToBounds = NO;
        }
        else
        {
            self.contentViewer=[ControllersFactory instantiateViewControllerWithIdentifier:@"UserProfileTableViewVC" inStoryboard:kProfileStoryboard];
            self.contentViewer.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
        
        [self.contentViewer startLoadingIndicator];

        self.contentViewer.dataDelegate = self;
        [self addChildViewController:self.contentViewer];
        [self.view addSubview:self.contentViewer.view];
    }
}


-(void)populateViewController:(NSArray*)designFromServer isSignInUser:(BOOL)isSignInUser{
    NSArray * designArray = nil;
    
    if (isSignInUser) {
        //if signin user
        designArray = [[DesignsManager sharedInstance] designsArray];
    }else{
        //else not signin user
        designArray = designFromServer;
    }
    
    [self.contentViewer initDisplay:designArray];
    
    [self.contentViewer stopLoadingIndicator];
    
    if([self.rootDesignDelegate respondsToSelector:@selector(updateProfileCounter:ForTab:)]){
        [self.rootDesignDelegate updateProfileCounter:(int)designArray.count ForTab:ProfileTabDesign];
    }
}

#pragma mark - DesignItemDelegate
- (void)designPressed:(MyDesignDO *)asset
{
    if ([self.rootDesignDelegate respondsToSelector:@selector(designPressed:)]) {
        [self.rootDesignDelegate designPressed:asset];
    }
}

- (void)designEditPressed:(MyDesignDO *)asset
{
    if ([self.rootDesignDelegate respondsToSelector:@selector(designEditPressed:)]) {
        [self.rootDesignDelegate designEditPressed:asset];
    }
}

#pragma mark - LikeDesignDelegate
- (void)performLikeForItemId:(NSString *)itemId withItemType:(ItemType)itemType likeState:(BOOL)isLiked sender:(UIViewController *)sender shouldUsePushDelegate:(BOOL)shouldUsePush andCompletionBlock:(void (^)(BOOL))completion
{
    if ([self.rootDesignDelegate respondsToSelector:@selector(performLikeForItemId:withItemType:likeState:sender:shouldUsePushDelegate:andCompletionBlock:)])
    {
        [self.rootDesignDelegate performLikeForItemId:itemId
                                         withItemType:itemType
                                            likeState:isLiked
                                               sender:sender
                                shouldUsePushDelegate:shouldUsePush
                                   andCompletionBlock:completion];
    }
}

-(BOOL)performLikeForItem:(DesignBaseClass *)item likeState:(BOOL)isLiked sender:(UIViewController *)sender shouldUsePushDelegate:(BOOL)shouldUsePush andCompletionBlock:(void (^)(BOOL))completio
{
    return NO;
}

#pragma mark - CommentDesignDelegate
- (void)openCommentScreenForDesign:(NSString *)designId withType:(ItemType)type
{
    if ([self.rootDesignDelegate respondsToSelector:@selector(openCommentScreenForDesign:withType:)])
    {
        return [self.rootDesignDelegate openCommentScreenForDesign:designId withType:type];
    }
}

- (NSString *)getCommentForActivityId:(NSString *)strId timestamp:(NSTimeInterval)ts
{
    if ([self.rootDesignDelegate respondsToSelector:@selector(getCommentForActivityId:timestamp:)])
    {
        return [self.rootDesignDelegate getCommentForActivityId:strId timestamp:ts];
    }
    
    return nil;
}

#pragma mark - ProfilePageCollectionViewDelegate
-(Class)getCollectionCellClass{
    return  [DesignItemCollectionView class];
}

-(CollectionViewRowsSize)getCollectionGridSize{
    CollectionViewRowsSize size;
    size.collumnsCount = 3;
    size.minRowsCount = 1;
    return  size;
}

-(UIEdgeInsets) getCellEdgeInsets{
    return UIEdgeInsetsMake(0, 5, 4, 10);
}

-(CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(230, 244);
}

-(CGFloat)minimumLineSpacingForSection
{
    return 20.0;
}

-(NSString *)getMessageForEmptyData:(BOOL)isCurrentUser{

    if (isCurrentUser)
        return NSLocalizedString(@"myhome_no_designs_copy", "");
    else
        return NSLocalizedString(@"myhome_no_designs_copy_other", "");
}

-(NSString*)getCellIdentifierForIndexpath:(NSIndexPath *)path{
    return  DESIGN_ITEM_CELL_IDENTIFIER;
}

-(UITableViewCell *)getTableViewCellForIndexpath:(NSIndexPath*)indexPath{
    return [[DesignItemView alloc] init];
}

- (NSInteger)heightForRowAtIndexpath:(NSIndexPath *)path{
    return DESIGN_ITEM_CELL_HEIGHT;
}

@end
