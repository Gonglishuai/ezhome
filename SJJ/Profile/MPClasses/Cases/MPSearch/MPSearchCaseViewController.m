/**
 * @file    MPSearchCaseViewController.m
 * @brief   Search the viewcontroller.
 * @author  Xue.
 * @version 1.0.
 * @date    2015-12-15.
 */

#import "MPSearchCaseViewController.h"
#import "MPSearchView.h"
#import "MPCaseModel.h"
#import "MP3DCaseBaseModel.h"
#import "MPCaseBaseModel.h"
#import "MPOrderEmptyView.h"
#import "MBProgressHUD.h"
#import "CoCaseDetailController.h"
#import "ESCaseDetailViewController.h"
#import "ESDesignCaseList.h"
#import <ESNetworking/SHAlertView.h>

@interface MPSearchCaseViewController() <MPSearchViewDelegate>
{
    MPSearchView *_searchView;          //!< _listView the view for table.
    BOOL _isLoadMore;                   //!< _isLoadMore load more or not.
    NSMutableArray <ESDesignCaseList *>*_consumerArray;     //!< _consumerArray array for datasource.
    NSInteger _offset;                  //!< _offset offset how many.
    NSInteger _limit;                   //!< _limit limlt how many.
    NSString *keywordsStr;              //!< keyword string.
    MPOrderEmptyView *_emptyView;       //!< _emptyView the view for no cases.
}

@end

@implementation MPSearchCaseViewController


-(id)init
{
    self = [super init];
    return self;
}



-(void)viewDidLoad
{    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initData];
    keywordsStr = [[NSString alloc] init];
    self.navgationImageview.hidden = YES;
    _searchView = [[[NSBundle mainBundle] loadNibNamed:@"MPSearchView" owner:self options:nil] firstObject];
    _searchView.frame = CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT);
    _searchView.delegate = self;
    _searchView.searchType = _searchType;
    
    [self.view addSubview:_searchView];
    [self constraintSearchView:_searchView];
}
- (void)initData {
    _consumerArray= [NSMutableArray array];
    _isLoadMore = NO;
    _offset = 0;
    _limit = 10;
}
- (void)requestData {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    WS(weakSelf);
    
    if ([_searchType isEqualToString:@"2D"]) {
        [MPCaseBaseModel get2DCasesListWithOffset:[NSString stringWithFormat:@"%ld",(long)_offset] withLimit:[NSString stringWithFormat:@"%ld",(long)_limit] withSearchTerm:keywordsStr withFacet:@"" withSuccess:^(NSArray<ESDesignCaseList *> *array) {
            [weakSelf onSuccess:array];
        } andFailure:^(NSError *error) {
            [weakSelf onFailure:error];
        }];

    }else if ([_searchType isEqualToString:@"3D"]){
        [MP3DCaseBaseModel get3DCasesListWithOffset:[NSString stringWithFormat:@"%ld",(long)_offset] withLimit:[NSString stringWithFormat:@"%ld",(long)_limit] withSearchTerm:keywordsStr withFacet:@"" withSuccess:^(NSArray<ESDesignCaseList *> *array) {
            [weakSelf onSuccess: array];
        } andFailure:^(NSError *error) {
            [weakSelf onFailure:error];
        }];
    }
}

- (void)onSuccess:(NSArray<ESDesignCaseList *> *)array {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    });
    
    if (!_isLoadMore)
        [_consumerArray removeAllObjects];
    [self endRefreshView:_isLoadMore];
    [_consumerArray addObjectsFromArray:array];
    if (_consumerArray.count==0) {
        
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
    [_searchView refreshFindDesignersUI];
    if(!_isLoadMore){
        [_searchView scrollCollectionViewToTop];
    }
}

- (void)onFailure:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    });
    [SHAlertView showAlertForNetError];
    [self endRefreshView:_isLoadMore];
}

- (void)refreshLoadNewData:(void (^)(void))finish {
    self.refreshForLoadNew = finish;
    _isLoadMore = NO;
    _offset = 0;
    [self requestData];
    
}

- (void)refreshLoadMoreData:(void (^)(void))finish {
    self.refreshForLoadMore = finish;
    _isLoadMore = YES;
    _offset += _limit;
    [self requestData];
}
#pragma mark -------MPHomeViewDelegate, MPHomeViewCellDelegate--------

- (ESDesignCaseList *) getDatamodelForIndex:(NSUInteger) index
{
    if (_consumerArray.count != 0) {
         return [_consumerArray objectAtIndex:index];
    }
    return nil;
 }

-(ESDesignCaseList *)get3DDatamodelForIndex:(NSUInteger) index
{
    if (_consumerArray.count != 0) {
        return [_consumerArray objectAtIndex:index];
    }
    return nil;
}

- (void) designerIconClickedAtIndex:(NSUInteger) consumer
{
    ESDesignCaseList *caseModel = _consumerArray[consumer];

    NSDictionary *dict = [NSDictionary dictionaryWithObject:caseModel.designerId forKey:@"designId"];
    [MGJRouter openURL:@"/Design/DesignerDetail" withUserInfo:dict completion:nil];
}

- (void)designer3DIconClickedAtIndex:(NSUInteger)index {
    ESDesignCaseList *caseModel = _consumerArray[index];
    

    NSDictionary *dict = [NSDictionary dictionaryWithObject:caseModel.designerId forKey:@"designId"];
    [MGJRouter openURL:@"/Design/DesignerDetail" withUserInfo:dict completion:nil];
}

- (void)didSelectedItemAtIndex:(NSUInteger)index {
    
    ESDesignCaseList * model = [_consumerArray objectAtIndex:index];
    UIViewController *caseDetailVC = nil;

    if ([_searchType isEqualToString:@"2D"]) {
        if (model.isNew) {
            ESCaseDetailViewController *vc = [[ESCaseDetailViewController alloc] init];
            [vc setCaseId:model.assetId caseStyle:CaseStyleType2D caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryNormal];
            caseDetailVC = vc;
        }else {
            caseDetailVC = [[CoCaseDetailController alloc] initWithCaseID:model.assetId];
        }
    }else if ([_searchType isEqualToString:@"3D"]) {
      
        ESCaseDetailViewController *vc = [[ESCaseDetailViewController alloc] init];
        [vc setCaseId:model.assetId caseStyle:CaseStyleType3D caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryNormal];
        caseDetailVC = vc;
    }
    
    [self customPushViewController:caseDetailVC animated:YES];
}


- (NSUInteger) getNumberOfItemsInCollection {
    return _consumerArray.count;
}

-(void)constraintSearchView:(MPSearchView*)searchView
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
                                                           constant:0]];
}


#pragma mark MPSearchViewDelegate

-(void)onSearchTrigerred:(NSString*) searchKey
{
    SHLog(@"搜索到条件:%@",searchKey);
    keywordsStr = [searchKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _isLoadMore = NO;
    _offset = 0;
    [self requestData];

}

- (void)refreshLoadMoreDataWithOffset:(NSInteger)offset andLimit:(NSInteger)limit andKeyWord:(NSString *)keyword finish:(void (^)(void))finish{
    SHLog(@"搜索条件:%@---%zd----%zd",keyword,offset,limit);
    self.refreshForLoadMore = finish;
    keywordsStr = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _isLoadMore = YES;
    _offset = offset;
    _limit = limit;
    [self requestData];
}

-(void)onSearchViewDismiss
{
    [_searchView removeKeyBoardObserver];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)bringSearchViewToFront{
    [self.view bringSubviewToFront:_searchView];
}

@end
