//
//  CoSearchDesignerViewController.m
//  Consumer
//
//  Created by xuezy on 16/8/11.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoSearchDesignerViewController.h"
#import "CoSearchDesignerView.h"
#import "MPOrderEmptyView.h"
#import "MPDesignerBaseModel.h"
#import "MPDesignerInfoModel.h"
#import "ESNIMManager.h"

@interface CoSearchDesignerViewController ()<CoSearchDesignerViewDelegate>
{
    CoSearchDesignerView *_searchView;   //!< _listView the view for table.
    BOOL _isLoadMore;                   //!< _isLoadMore load more or not.
    NSMutableArray * _designerArray;       //!< _designerArray array for datasource.
    NSInteger _offset;                  //!< _offset offset how many.
    NSInteger _limit;                   //!< _limit limlt how many.
    NSString *_ageString;               //!< _ageString selected age value.
    NSString *_priceString;               //!< _priceString unit value selection.
    NSString *_styleString;              //!< styleString select the style value.
    NSString *typeStr;                  //!< typeStr select the type of value.
    MPOrderEmptyView *_emptyView;       //!< _emptyView the view f
    
    NSString *_start_experience;
    NSString *_end_experience;
    NSString *_searchName;
}
@end

@implementation CoSearchDesignerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initData];
    _ageString = [[NSString alloc] init];
    _styleString = [[NSString alloc] init];
    typeStr = [[NSString alloc] init];
    _priceString = [[NSString alloc] init];
    
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CoSearchDesignerType" ofType:@"plist"];
//    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    self.navgationImageview.hidden = YES;
    //_searchView = [[[NSBundle mainBundle] loadNibNamed:@"MPSearchBiddingView" owner:self options:nil] firstObject];
    
    _searchView = [[CoSearchDesignerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _searchView.delegate = self;
    
    [self.view addSubview:_searchView];
    [self constraintSearchView:_searchView];
    
//    [self requestData];
}
- (void)initData {
    _designerArray = [NSMutableArray array];
    
    _offset = 0;
    _limit = 10;
    _isLoadMore = NO;
    
    _priceString = @"-1";
    _start_experience = @"";
    _end_experience = @"";
    _styleString = @"";
    _searchName = @"";
}

-(void)constraintSearchView:(CoSearchDesignerView*)searchView
{
    searchView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:searchView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:searchView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:searchView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:searchView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:NAVBAR_HEIGHT-STATUSBAR_HEIGHT+20]];
}

- (void)requestData {
    WS(weakSelf);
    [MPDesignerBaseModel getDataWithParameters:@{@"limit":@(_limit),@"offset":@(_offset),@"styles":_styleString,@"start_experience":_start_experience,@"end_experience":_end_experience,@"design_price_code":_priceString,@"nick_name":_searchName} success:^(NSArray *array) {
        
        if (!_isLoadMore)
            [_designerArray removeAllObjects];
        
        [weakSelf endRefreshView:_isLoadMore];
        [_designerArray addObjectsFromArray:array];
        
        if (_designerArray.count==0) {
            if (_emptyView) return;
            _emptyView = [[[NSBundle mainBundle] loadNibNamed:@"MPOrderEmptyView" owner:self options:nil] lastObject];
            _emptyView.frame = CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBAR_HEIGHT);
            _emptyView.infoLabel.text = @"暂无结果";
            _emptyView.imageView.image = [UIImage imageNamed:@"search_case_logo"];
            [self.view addSubview:_emptyView];
            
        }else{
            if (_emptyView) {
                [_emptyView removeFromSuperview];
                _emptyView = nil;
            }
            
        }

        [_searchView refreshSearchDesignerViewUI];
        
    } failure:^(NSError *error) {
        
        [weakSelf endRefreshView:_isLoadMore];
        [SHAlertView showAlertForNetError];
    }];
}

#pragma mark - MPFindDesignersViewDelegate methods

- (NSInteger) getDesignerCellCount {
    return [_designerArray count];
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    
    MPDesignerInfoModel *modelInfo = _designerArray[index];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:modelInfo.jmember_id forKey:@"designId"];
    [MGJRouter openURL:@"/Design/DesignerDetail" withUserInfo:dict completion:nil];
}

- (void)searchDesignerViewRefreshLoadNewData:(void (^)(void))finish {
    self.refreshForLoadNew = finish;
    _offset = 0;
    _isLoadMore = NO;
    [self requestData];
}

- (void)searchDesignerViewRefreshLoadMoreData:(void (^)(void))finish {
    self.refreshForLoadMore = finish;
    _offset += _limit;
    _isLoadMore = YES;
    [self requestData];
}

#pragma mark - MPFindDesignersTableViewCellDelegate methods

- (MPDesignerInfoModel *)getDesignerLibraryModelForIndex:(NSUInteger) index
{
    MPDesignerInfoModel *model = nil;
    
    if ([_designerArray count])
        return [_designerArray objectAtIndex:index];
    
    return model;
}


-(void) startChatWithDesignerForIndex:(NSUInteger) index
{
    MPDesignerInfoModel *model = [_designerArray objectAtIndex:index];
    if ([ESLoginManager sharedManager].isLogin) {
        [ESNIMManager startP2PSessionFromVc:self withJMemberId:model.jmember_id andSource:ESIMSourceNone];
        
    } else {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
    }
}

- (void)stringSelectType:(NSString *)typeString withTitleString:(NSString *)titleString {
    
    
    _ageString = @"";
    _priceString = @"-1";
    _styleString = @"";
    _searchName = @"";
    _end_experience = @"";
    _start_experience = @"";
    
    _isLoadMore = NO;
    _offset = 0;
    _limit = 10;
    [_designerArray removeAllObjects];
    
    if ([typeString isEqualToString:@"从业年限"]) {
        _ageString = titleString;
        
        if (_ageString != nil) {
            NSArray *yearArray = [_ageString componentsSeparatedByString:@"-"];
            
            if (yearArray.count > 2) {
                _start_experience = [NSString stringWithFormat:@"%@",yearArray[0]];
                _end_experience = [NSString stringWithFormat:@"%@",yearArray[1]];
            }
            
        }

    }else if ([typeString isEqualToString:@"价格"]){
        _priceString = titleString;
    }else if ([typeString isEqualToString:@"风格"]){
        _styleString = titleString;

    }
    
    [self requestData];
}
#pragma mark MPSearchViewDelegate


-(void)onSearchTrigerred:(NSString*) searchKey
{
    _searchName = [searchKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    MPCaseLibraryViewController *controller = [[MPCaseLibraryViewController alloc] init];
    //    //self.tabBarController.tabBar.hidden = YES;
    //    [self.navigationController pushViewController:controller animated:YES];
    _priceString = @"-1";
    _ageString = @"";
    _styleString = @"";
    [self requestData];
    
}


-(void)onSearchViewDismiss
{
    [_searchView removeKeyBoardObserver];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
