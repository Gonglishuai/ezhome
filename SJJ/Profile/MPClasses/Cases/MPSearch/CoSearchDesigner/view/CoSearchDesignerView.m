//
//  CoSearchDesignerView.m
//  Consumer
//
//  Created by xuezy on 16/8/11.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoSearchDesignerView.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "MPTranslate.h"
#import "ESDiyRefreshHeader.h"
#import "MPFindDesignersTableViewCell.h"

@interface CoSearchDesignerView()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    UITableView *_searchTableView;   //!< Association condition tableview.
    NSMutableArray *searchResults;   //!< searchResults array for datasource.
    UITableView *_searchDesignerTableView;  //!< _biddingTableView result bidding tableview.
    float keyboardHeight;            //!< keyboard height.
    
    UISearchBar *searchBiddingBar;   //!< search bar.
    UIButton *fadeButton;            //!< keyboard close button.
}

@end

@implementation CoSearchDesignerView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createFindView];
        [self createSearchBiddingHallView];
    }
    return self;
}

- (void)createSearchBiddingHallView {
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, NAVBAR_HEIGHT)];
    topView.backgroundColor = [UIColor colorWithRed:0.975
                                              green:0.975
                                               blue:0.975
                                              alpha:1];
    [self addSubview:topView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(8, STATUSBAR_HEIGHT, 32, 32);
    [backButton setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(moveBack:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    fadeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fadeButton.frame = CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT);
    [fadeButton addTarget:self action:@selector(dismissFading:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:fadeButton];
    
    searchBiddingBar = [[UISearchBar alloc] initWithFrame:CGRectMake(40, STATUSBAR_HEIGHT-6, SCREEN_WIDTH-48, 44)];
    searchBiddingBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBiddingBar.tintColor = [UIColor blackColor];
    searchBiddingBar.placeholder = @"请输入关键字搜索";
    searchBiddingBar.delegate = self;
    [topView addSubview:searchBiddingBar];
    
}
/// Create find designers view.
- (void)createFindView {
    
    if (_searchDesignerTableView==nil) {
        _searchDesignerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT)];
        _searchDesignerTableView.delegate = self;
        _searchDesignerTableView.dataSource = self;
        [_searchDesignerTableView registerNib:[UINib nibWithNibName:@"MPFindDesignersTableViewCell" bundle:nil] forCellReuseIdentifier:@"MPFindDesigners"];
        _searchDesignerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_searchDesignerTableView];
        [self addDesignerLibraryRefresh];

    }
    
}

- (void)addDesignerLibraryRefresh {
    WS(weakSelf);
    _searchDesignerTableView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        
        if ([weakSelf.delegate respondsToSelector:@selector(searchDesignerViewRefreshLoadNewData:)]) {
            [weakSelf endFooterRefresh];
            [weakSelf.delegate searchDesignerViewRefreshLoadNewData:^{
                [weakSelf endHeaderRefresh];
            }];
        }
    }];
    
    _searchDesignerTableView.mj_header.automaticallyChangeAlpha = NO;

    _searchDesignerTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        
        if ([weakSelf.delegate respondsToSelector:@selector(searchDesignerViewRefreshLoadMoreData:)]) {
            [weakSelf endHeaderRefresh];
            [weakSelf.delegate searchDesignerViewRefreshLoadMoreData:^{
                [weakSelf endFooterRefresh];
            }];
        }
    }];
    //[_searchDesignerTableView.mj_header beginRefreshing];
}

/// end header refresh
- (void)endHeaderRefresh {
    [_searchDesignerTableView.mj_header endRefreshing];
}

/// end footer refresh
- (void)endFooterRefresh {
    [_searchDesignerTableView.mj_footer endRefreshing];
}

- (void)createSearchTableView {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
//    if (_searchTableView==nil) {
//        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height)];
//        _searchTableView.delegate = self;
//        _searchTableView.dataSource = self;
//        _searchTableView.backgroundColor = [UIColor whiteColor];
//        _searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        [fadeButton addSubview:_searchTableView];
//        
//    }
    
}

- (void)removeKeyBoardObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}
#pragma UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _searchTableView) {
        return 50;
    }else{
        return 92.0f*SCREEN_SCALE;;
    }
    return 50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == _searchDesignerTableView) {
        if([self.delegate respondsToSelector:@selector(getDesignerCellCount)])
            return [self.delegate getDesignerCellCount];
        
    }else{
        return searchResults.count;
        
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==_searchDesignerTableView) {
        MPFindDesignersTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:@"MPFindDesigners" forIndexPath:indexPath];
        _cell.delegate = (id)self.delegate;
        [_cell updateCellForIndex:indexPath.row];
        return _cell;
        
    }else{
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = searchResults[indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor blackColor];
        return cell;
        
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissFading:nil];
    if ([self.delegate respondsToSelector:@selector(didSelectItemAtIndex:)]) {
        [self.delegate didSelectItemAtIndex:indexPath.row];
    }
}


- (void)deleteduplicateArray {
    NSMutableArray *categoryArray = [[NSMutableArray alloc] init];
    
    for (unsigned i = 0; i < [searchResults count]; i++){
        
        if ([categoryArray containsObject:[searchResults objectAtIndex:i]] == NO){
            
            [categoryArray addObject:[searchResults objectAtIndex:i]];
            
        }
        
        
        
    }
    
    searchResults = categoryArray;
}

- (void)refreshSearchDesignerViewUI {
    [_searchDesignerTableView reloadData];
}
#pragma UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
}

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
    if (searchBar.text.length > 0)
    {
        [self dismissFading:nil];
        
        if ([self.delegate respondsToSelector:@selector(onSearchTrigerred:)])
            [self.delegate onSearchTrigerred:searchBar.text];
    }
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissFading:nil];
}


#pragma mark- UIButton Actions

-(void)moveBack:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onSearchViewDismiss)])
        [self.delegate onSearchViewDismiss];
}


-(void)dismissFading:(id)sender
{
    [searchBiddingBar resignFirstResponder];
    [self endEditing:YES];
    [searchBiddingBar setShowsCancelButton:NO];
    [UIView animateWithDuration:0.3 animations:
     ^(void){
         fadeButton.alpha = 0;
     } completion:^(BOOL finished) {
         
     }];
    
}



#pragma mark- Private methods

-(void) showFading
{
    [UIView animateWithDuration:0.3 animations:
     ^(void){
         fadeButton.alpha = 1.0;
     } completion:^(BOOL finished) {
         
     }];
}


@end
