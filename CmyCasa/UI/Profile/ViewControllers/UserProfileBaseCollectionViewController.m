//
// Created by Berenson Sergei on 12/22/13.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "UserProfileBaseCollectionViewController.h"
#import "ArticleItemCollectionView.h"
#import "FollowUserItemCollectionView.h"
#import "DesignItemCollectionView.h"
#import "ProfileMenuReusableView_iPhone.h"

@interface UserProfileBaseCollectionViewController ()

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

// Content
@property (nonatomic,weak) ProfileMenuReusableView_iPhone *headerView;
@property (nonatomic) NSUInteger displayedItemsPerRow;
@property (nonatomic) NSUInteger displayedMinimumRows;


@end

@implementation UserProfileBaseCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ArticleItemCollectionView" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([ArticleItemCollectionView class])];
    [self.collectionView registerNib:[UINib nibWithNibName:@"DesignItemCollectionView" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([DesignItemCollectionView class])];
    [self.collectionView registerNib:[UINib nibWithNibName:@"FollowUserItemCollectionView" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([FollowUserItemCollectionView class])];
    [self.collectionView registerNib:[UINib nibWithNibName:@"FollowUserSingle" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([FollowUserSingle class])];
    [self.collectionView registerClass:[ProfileMenuReusableView_iPhone class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileMasterHeaderView"];
}

-(void)insertHeaderView:(UIView*)headerView{
    
    self.masterMenuHeaderView = headerView;
}

- (void)updateDisplay:(BOOL)isLoggedInUserProfile{
    
    if (self.presentingData != nil)
    {
        self.collectionView.scrollEnabled = (self.presentingData.count > 0);
    }
    
    [super updateDisplay:isLoggedInUserProfile];

    [self refreshContent];
}

-(void) refreshContent{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

#pragma mark - Subclass overrides

- (void)startLoadingIndicator
{
    [self.tableLoadingIndicator startAnimating];
}

- (void)stopLoadingIndicator
{
    [self.tableLoadingIndicator stopAnimating];
}

- (void)initDisplay:(NSArray *)data{
    
    [self setPresentingData:data];

    if (self.dataDelegate)
    {
        if([self.dataDelegate respondsToSelector:@selector(getCollectionGridSize)])
        {
            CollectionViewRowsSize gsize= [self.dataDelegate getCollectionGridSize];
            self.displayedItemsPerRow=gsize.collumnsCount;
            self.displayedMinimumRows=gsize.minRowsCount;
        }
        UICollectionViewFlowLayout *collectionViewLayout = nil;
        
        if([self.dataDelegate respondsToSelector:@selector(getCellEdgeInsets)])
        {
            collectionViewLayout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
            collectionViewLayout.sectionInset =[self.dataDelegate getCellEdgeInsets];
        }
    }
}

#pragma mark - Collection View
- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        ProfileMenuReusableView_iPhone *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileMasterHeaderView" forIndexPath:indexPath];
        
        if (self.masterMenuHeaderView) {
            [self.masterMenuHeaderView removeFromSuperview];
            [headerView.menuContainer addSubview:self.masterMenuHeaderView];
        }
        reusableview = headerView;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    CGSize headerViewSize = CGSizeMake(0, 0);
    if(self.masterMenuHeaderView){
        CGSize size=  self.masterMenuHeaderView.frame.size;
        
        return size;
    }
    
    return headerViewSize;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.presentingData.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = nil;
    
    // Get the content
    id content = nil;
    if (indexPath.row < self.presentingData.count)
    {
        content = self.presentingData[indexPath.row];
    }
    else
    {
        content = nil;
    }
    
    if(self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(getCollectionCellClass)])
    {
        Class  cellClass = [self.dataDelegate getCollectionCellClass];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(cellClass) forIndexPath:indexPath];
        
        if(cell && [cell respondsToSelector:@selector(initWithData:andDelegate:andProfileUserType:)])
        {
            id<ProfileCellUnifiedInitProtocol>  protocolCell=(id<ProfileCellUnifiedInitProtocol>)cell;
            
            ProfileUserType puserType= [self.dataDelegate getViewedProfileUserType];
            
            [protocolCell initWithData:content andDelegate:self.dataDelegate  andProfileUserType:puserType];
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    CGFloat fSpacing = 0.0;
    
    if([self.dataDelegate respondsToSelector:@selector(minimumLineSpacingForSection)])
    {
        fSpacing = [self.dataDelegate minimumLineSpacingForSection];
    }
    
    return fSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeZero;
    
    if (self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(sizeForItemAtIndexPath:)]) {
        size= [self.dataDelegate sizeForItemAtIndexPath:indexPath];
    }
    
    
    return size;
}

- (BOOL)scrollToTop
{
    [super scrollToTop];
    
    if (self.collectionView == nil)
        return NO;
    
    [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    return YES;
    
}

@end