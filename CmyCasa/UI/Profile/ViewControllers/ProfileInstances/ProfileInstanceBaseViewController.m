//
// Created by Berenson Sergei on 12/23/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ProfilePageBaseViewController.h"
#import "ProfileInstanceBaseViewController.h"
#import "ControllersFactory.h"
#import "HSSharingConstants.h"
#import "UserProfileBaseTableViewController.h"
#import "UserProfileBaseCollectionViewController.h"

@interface ProfileInstanceBaseViewController ()

@end

@implementation ProfileInstanceBaseViewController


-(instancetype)initWithRect:(CGRect)rect{

    self = [super init];
    if (self) {
        self.view.frame = rect;
        [self initContentViewer];
    }

    return self;
}

-(void)dealloc{
    NSLog(@"dealloc - ProfileInstanceBaseViewController");
}

-(void)refreshContent{
    // implement in son's
}

-(ProfilePageBaseViewController *)getContentVC{

    return self.contentViewer;
}

-(void)initContentViewer{

    if(self.contentViewer == nil)
    {
        self.contentViewer = [ControllersFactory instantiateViewControllerWithIdentifier:@"UserProfileTableViewVC" inStoryboard:kNewProfileStoryboard];

        if (IS_IPAD) {
            UIView * containerView_ = self.containerView != nil ? self.containerView : self.view;
            self.contentViewer.view.frame = containerView_.bounds;
        } else {
            self.contentViewer.view.frame = [UIScreen mainScreen].bounds;
        }
        
        if (self.contentViewer) {
            self.contentViewer.dataDelegate = self;
            [self addChildViewController:self.contentViewer];

            if (IS_IPAD) {
                UIView * containerView_ = self.containerView != nil ? self.containerView : self.view;
                [containerView_ addSubview:self.contentViewer.view];
                [containerView_ sendSubviewToBack:self.contentViewer.view];
            } else {
                [self.view addSubview:self.contentViewer.view];
                [self.view sendSubviewToBack:self.contentViewer.view];
            }
        }
    }
}

-(void)initContent{
    //implement in sons
}

-(void)insertTableViewHeader:(UIViewController*)headerController{

    //remove any parent controllers, otherwise collectionview/tableview will crash
    [headerController removeFromParentViewController];
    
    if ([self.contentViewer isKindOfClass:[UserProfileBaseTableViewController  class]])
    {
        UserProfileBaseTableViewController * tbl = (UserProfileBaseTableViewController *)self.contentViewer;
        
        [tbl insertHeaderView:headerController.view];
    }
    
    if ([self.contentViewer isKindOfClass:[UserProfileBaseCollectionViewController class]])
    {
        UserProfileBaseCollectionViewController * tbl = (UserProfileBaseCollectionViewController *)self.contentViewer;

        [tbl insertHeaderView: headerController.view];
    }
}

#pragma mark- ProfilePageCollectionDelegate
-(ProfileUserType)getViewedProfileUserType{
    if (self.isLoggedInUserProfile)
        return kUserProfileTypeLoggedInUser;

    return kUserProfileTypePublicUser;
}

-(NSString *)getMessageForEmptyData:(BOOL)isCurrentUser{
    return @"";
}

-(Class)getCollectionCellClass{
    return nil;
}

-(UIEdgeInsets) getCellEdgeInsets{
    UIEdgeInsets edge = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    return edge;
}

-(CollectionViewRowsSize)getCollectionGridSize{
    CollectionViewRowsSize size;
    size.collumnsCount = 0;
    size.minRowsCount = 0;
    return size;
}

-(CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeZero;
}

-(CGFloat)minimumLineSpacingForSection{
    return 0.0;
}

#pragma mark ProfilePageTableViewDelegate
-(NSString*)getCellIdentifierForIndexpath:(NSIndexPath *)path{
    return nil;
}

-(UITableViewCell *)getTableViewCellForIndexpath:(NSIndexPath *)path{
    return nil;
}

-(NSInteger)heightForRowAtIndexpath:(NSIndexPath *)path{
    return 0;
}


-(void)rowSelectedAtIndex:(NSIndexPath*)indexPath{
    // implement in son's
}

-(void)reachedRowAtIndex:(NSInteger)rowIndex fromTotalCount:(NSInteger)totalCount{
    // implement in son's
}

@end
