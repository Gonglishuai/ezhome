/**
 * @file    MPSearchView.m
 * @brief   Search  the view.
 * @author  Xue.
 * @version 1.0.
 * @date    2015-12-15.
 */

#import "MPSearchView.h"
#import "ESDiyRefreshHeader.h"
#import "MPHomeViewCell.h"
#import "MPHome3DViewCell.h"

@interface MPSearchView()<UISearchBarDelegate,UICollectionViewDataSource, UICollectionViewDelegate>
{
    UICollectionView *_homeCollectionView;  //!< _homeCollectionView the view of CollectionView.

    float keyboardHeight;                   //!< keyboard height.
    NSInteger _offset;
    NSInteger _limit;
}
@property(nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property(nonatomic, strong) IBOutlet UIButton *fadeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewHeightLayoutConstraint;

@end

#define CELL_HEIGHT 40

@implementation MPSearchView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _searchViewHeightLayoutConstraint.constant = NAVBAR_HEIGHT;
    [_searchBar becomeFirstResponder];
    
    @try {
        UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
        if (searchField
            && [searchField isKindOfClass:[UITextField class]])
        {
            [searchField setValue:[UIFont systemFontOfSize:13] forKeyPath:@"_placeholderLabel.font"];
            [searchField setValue:[UIFont systemFontOfSize:13] forKeyPath:@"font"];
        }
    } @catch (NSException *exception) {

    }
}

- (void)setSearchType:(NSString *)searchType
{
    _searchType = searchType;
    if ([@"3D" isEqualToString:_searchType]){
        _searchBar.placeholder = @"请输入3D案例名称关键字";
    }
}

- (void)createCollectionView
{
    if (_homeCollectionView==nil) {
        UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(self.bounds.size.width, SCREEN_WIDTH * CASE_IMAGE_RATIO + 37);
        flowLayout.sectionInset = UIEdgeInsetsZero;
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        _homeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBAR_HEIGHT) collectionViewLayout:flowLayout];
        [self addSubview:_homeCollectionView];
        [self sendSubviewToBack:_homeCollectionView];

        _homeCollectionView.delegate = self;
        _homeCollectionView.dataSource = self;
        _homeCollectionView.showsVerticalScrollIndicator = NO;
        _homeCollectionView.backgroundColor = [UIColor clearColor];
        [_homeCollectionView registerNib:[UINib nibWithNibName:@"MPHomeViewCell" bundle:nil] forCellWithReuseIdentifier:@"MPHomeViewCell"];
        [_homeCollectionView registerNib:[UINib nibWithNibName:@"MPHome3DViewCell" bundle:nil] forCellWithReuseIdentifier:@"MPHome3DViewCell"];
        _homeCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addRefresh];

    }
}

/// add refresh load more data & load new data
- (void)addRefresh {
    WS(weakSelf);
    /// add head refresh.
    _homeCollectionView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(refreshLoadNewData:)]) {
            _offset = 0;
            [weakSelf endFooterRefresh];
            [weakSelf.delegate refreshLoadNewData:^() {
                [weakSelf endHeaderRefresh];
            }];
        }
    }];
    _homeCollectionView.mj_header.automaticallyChangeAlpha = NO;
    _homeCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        _limit = 10;
        _offset += _limit;
        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(refreshLoadMoreDataWithOffset:andLimit:andKeyWord:finish:)]){
            [weakSelf endHeaderRefresh];
            [weakSelf.delegate refreshLoadMoreDataWithOffset:_offset andLimit:_limit andKeyWord:_searchBar.text finish:^{
                [weakSelf endFooterRefresh];
            }];
        }
    }];
//    [_homeCollectionView.mj_header beginRefreshing];
}

/// end header refresh
- (void)endHeaderRefresh {
    [_homeCollectionView.mj_header endRefreshing];
}

/// end footer refresh
- (void)endFooterRefresh {
    [_homeCollectionView.mj_footer endRefreshing];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.delegate getNumberOfItemsInCollection];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_searchType isEqualToString:@"2D"]) {
        MPHomeViewCell* cell = (MPHomeViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"MPHomeViewCell" forIndexPath:indexPath];
        cell.delegate = (id)self.delegate;
        [cell updateCellUIForIndex:indexPath.item];
        return cell;

    }
    MPHome3DViewCell* cell = (MPHome3DViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"MPHome3DViewCell" forIndexPath:indexPath];
    cell.delegate = (id)self.delegate;
    [cell update3DCellUIForIndex:indexPath.item];
    return cell;

  }


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    [self.delegate didSelectedItemAtIndex:indexPath.item];
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void) refreshFindDesignersUI {
    [_homeCollectionView reloadData];
}

- (void)scrollCollectionViewToTop{
    if([_homeCollectionView numberOfItemsInSection:0] > 5){
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        [_homeCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

- (void)createSearchTableView {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)removeKeyBoardObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

#pragma UISearchDisplayDelegate

- (void) keyboardWasShown:(NSNotification *) notif

{
    
    NSDictionary *info = [notif userInfo];
    
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    
    CGSize keyboardSize = [value CGRectValue].size;
    
    keyboardHeight = keyboardSize.height;
    
    SHLog(@"keyBoard:%f", keyboardSize.height);  //216
    
    ///keyboardWasShown = YES;
    
}

#pragma mark - UISearchbar datasource methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    SHLog(@"********");
    [searchBar setShowsCancelButton:YES];
    [self showFading];
    [self createSearchTableView];
    return YES;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    _offset = 0;
    if (searchBar.text.length > 0)
    {
        [self dismissFading:nil];
        [self createCollectionView];

        if ([self.delegate respondsToSelector:@selector(onSearchTrigerred:)])
            [self.delegate onSearchTrigerred:searchBar.text];
    }
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissFading:nil];
}


#pragma mark- UIButton Actions

-(IBAction)moveBack:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onSearchViewDismiss)])
        [self.delegate onSearchViewDismiss];
}


-(IBAction)dismissFading:(id)sender
{
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO];
    
    [UIView animateWithDuration:0.3 animations:
     ^(void){
         self.fadeButton.alpha = 0;
     } completion:^(BOOL finished) {
         
     }];
    
}

#pragma mark- Private methods

-(void) showFading
{
    [UIView animateWithDuration:0.3 animations:
     ^(void){
         self.fadeButton.alpha = 1.0;
        
     } completion:^(BOOL finished) {
         
     }];
}

@end
